// home_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../providers/note_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../services/voice_service.dart';
import '../services/ai_service.dart';

import '../widgets/note_card.dart';
import '../widgets/note_dialog.dart';
import '../widgets/grid_background.dart';
import '../widgets/note_overlay.dart';
import '../widgets/delete_confirm_dialog.dart';

import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? activeNoteId;
  final Set<String> selectedNoteIds = {};
  final TextEditingController _searchController = TextEditingController();
  bool _searchActive = false;
  bool _showArchived = false;
  String? _selectedFolder; // null = all, '' = no-folder, otherwise folder name

  final VoiceService _voiceService = VoiceService();
  final AiService _aiService = AiService();

  bool get selectionMode => selectedNoteIds.isNotEmpty;

  void _openNote(String id) {
    if (selectionMode) return;
    setState(() => activeNoteId = id);
  }

  Future<void> _showManageFoldersDialog() async {
    final provider = context.read<NoteProvider>();
    final folders = provider.folders.toList();

    await showDialog<void>(
      context: context,
      builder: (_) {
        final TextEditingController addController = TextEditingController();
        return AlertDialog(
          title: const Text('Manage folders'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (folders.isEmpty) const Text('No folders yet'),
                ...folders.map((f) {
                  return ListTile(
                    title: Text(f),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final controller = TextEditingController(text: f);
                            final newName = await showDialog<String?>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Rename folder'),
                                content: TextField(controller: controller),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
                                ],
                              ),
                            );

                            if (newName != null && newName.isNotEmpty) {
                              provider.renameFolder(f, newName);
                              setState(() {});
                            }
                            Navigator.of(context).pop();
                            _showManageFoldersDialog();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete folder?'),
                                    content: const Text('Notes in this folder will be unassigned.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (confirmed) {
                              provider.deleteFolder(f);
                              setState(() {});
                            }
                            Navigator.of(context).pop();
                            _showManageFoldersDialog();
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: addController, decoration: const InputDecoration(hintText: 'New folder name'))),
                    TextButton(
                      onPressed: () {
                        final name = addController.text.trim();
                        if (name.isNotEmpty) {
                          provider.addFolder(name);
                          setState(() {});
                          Navigator.of(context).pop();
                          _showManageFoldersDialog();
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        );
      },
    );
  }

  void _closeNote() {
    setState(() => activeNoteId = null);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final notes = _showArchived ? provider.archivedNotes : provider.activeNotes;
    final query = _searchController.text.trim();
    var filteredNotes = query.isEmpty
        ? notes
        : notes.where((n) {
            final q = query.toLowerCase();
            return n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
          }).toList();

    // Apply folder filter if set
    if (_selectedFolder != null) {
      if (_selectedFolder == '') {
        filteredNotes = filteredNotes.where((n) => n.folder == null).toList();
      } else {
        filteredNotes = filteredNotes.where((n) => n.folder == _selectedFolder).toList();
      }
    }

    // Using WillPopScope for compatibility; new PopScope API may differ.
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (selectionMode) {
          setState(selectedNoteIds.clear);
          return false;
        }
        if (activeNoteId != null) {
          _closeNote();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            const GridBackground(child: SizedBox.expand()),
            _buildContent(filteredNotes, context.watch<SettingsProvider>().viewMode),
            if (activeNoteId != null)
              Builder(
                builder: (ctx) {
                  final note = context.read<NoteProvider>().getById(activeNoteId!);
                  if (note == null) return const SizedBox.shrink();

                  return NoteOverlay(
                    note: note,
                    selectionMode: selectionMode,
                    onClose: _closeNote,
                    onEdit: () async {
                      _closeNote();

                      final result = await showGeneralDialog<NoteDialogResult>(
                        context: ctx,
                        barrierDismissible: true,
                        barrierLabel: 'Dismiss',
                        pageBuilder: (context, animation, secondaryAnimation) => NoteDialog(note: note),
                        transitionBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                      );

                      if (!mounted || result == null) return;

                      if (result.type == NoteDialogResultType.save &&
                          result.note != null) {
                        context.read<NoteProvider>().update(result.note!);
                      }

                      if (result.type == NoteDialogResultType.delete) {
                        context.read<NoteProvider>().delete(note.id);
                      }
                    },
                    onDelete: () {
                      context.read<NoteProvider>().delete(note.id);
                      _closeNote();
                    },
                    onTogglePin: () {
                      context.read<NoteProvider>().togglePin(note.id);
                    },
                    onArchive: () {
                      if (note.archived) {
                        context.read<NoteProvider>().unarchiveNote(note.id);
                      } else {
                        context.read<NoteProvider>().archiveNote(note.id);
                      }
                      _closeNote();
                    },
                    onMoveToFolder: (folder) {
                      context.read<NoteProvider>().moveToFolder(note.id, folder);
                      _closeNote();
                    },
                  );
                },
              ),
            if (selectionMode) _buildBottomBar(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewNote,
          child: const Text('+', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: selectionMode
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(selectedNoteIds.clear),
            )
          : null,
      // If selection mode is active show selected count, otherwise show
      // either the title or a search field when search is toggled on.
      title: selectionMode
          ? Text('${selectedNoteIds.length} selected')
          : (_searchActive
              ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search notes...',
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notes'),
                    if (_selectedFolder != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Chip(
                          label: Text(_selectedFolder == '' ? 'No folder' : _selectedFolder!),
                          onDeleted: () => setState(() => _selectedFolder = null),
                        ),
                      ),
                  ],
                )),
      actions: selectionMode
          ? []
          : [
              // Search toggle
              IconButton(
                icon: Icon(_searchActive ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    if (_searchActive) {
                      _searchController.clear();
                    }
                    _searchActive = !_searchActive;
                  });
                },
              ),
              // Voice input (stubbed service)
              IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () async {
                  final available = await _voiceService.isAvailable();
                  if (!available) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice input not available')));
                    return;
                  }
                  await _voiceService.startListening((text) {
                    _searchController.text = text;
                    setState(() {});
                  });
                },
              ),
              // AI helper (generates summary for active note)
              IconButton(
                icon: const Icon(Icons.smart_toy),
                onPressed: () async {
                  if (activeNoteId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open a note to use AI')));
                    return;
                  }
                  final note = context.read<NoteProvider>().getById(activeNoteId!);
                  if (note == null) return;
                  final result = await _aiService.summarize(note);
                  if (!mounted) return;
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('AI Summary'),
                      content: Text(result),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: () => context.read<ThemeProvider>().toggleTheme(),
              ),
              IconButton(
                icon: Icon(_showArchived ? Icons.unarchive : Icons.archive),
                onPressed: () => setState(() => _showArchived = !_showArchived),
              ),
              PopupMenuButton<String>(
                tooltip: 'Folders',
                icon: const Icon(Icons.folder),
                onSelected: (value) {
                  if (value == '__ALL__') {
                    setState(() => _selectedFolder = null);
                  } else if (value == '__NO_FOLDER__') {
                    setState(() => _selectedFolder = '');
                  } else if (value == '__MANAGE__') {
                    _showManageFoldersDialog();
                  } else {
                    setState(() => _selectedFolder = value);
                  }
                },
                itemBuilder: (_) {
                  final folders = context.read<NoteProvider>().folders;
                  return [
                    const PopupMenuItem(value: '__ALL__', child: Text('All folders')),
                    const PopupMenuItem(value: '__NO_FOLDER__', child: Text('No folder')),
                    const PopupMenuDivider(),
                    ...folders.map((f) => PopupMenuItem(value: f, child: Text(f))),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: '__MANAGE__', child: Text('Manage folders')),
                  ];
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _openSettings,
              ),
            ],
    );
  }

  Widget _buildGrid(List notes) {
    return ReorderableGridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: notes.length,
      onReorder: selectionMode
          ? (oldIndex, newIndex) {
              context.read<NoteProvider>().reorder(
                    fromId: notes[oldIndex].id,
                    toId: notes[newIndex].id,
                  );
            }
          : (_, _) {},
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          key: ValueKey(note.id),
          note: note,
          index: index,
          onEdit: () => _openNote(note.id),
          onMove: (from, to) {
            context.read<NoteProvider>().reorder(
                  fromId: notes[from].id,
                  toId: notes[to].id,
                );
          },
          selectionMode: selectionMode,
          isSelected: selectedNoteIds.contains(note.id),
          onSelectToggle: () {
            setState(() {
              if (!selectedNoteIds.add(note.id)) {
                selectedNoteIds.remove(note.id);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildContent(List notes, ViewMode vm) {
    switch (vm) {
      case ViewMode.list:
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NoteCard(
                key: ValueKey(note.id),
                note: note,
                index: index,
                onEdit: () => _openNote(note.id),
                onMove: (from, to) {},
                selectionMode: selectionMode,
                isSelected: selectedNoteIds.contains(note.id),
                onSelectToggle: () {
                  setState(() {
                    if (!selectedNoteIds.add(note.id)) selectedNoteIds.remove(note.id);
                  });
                },
                isMini: false,
              ),
            );
          },
        );

      case ViewMode.mini:
        return ReorderableGridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: notes.length,
          onReorder: selectionMode
              ? (oldIndex, newIndex) {
                  context.read<NoteProvider>().reorder(
                        fromId: notes[oldIndex].id,
                        toId: notes[newIndex].id,
                      );
                }
              : (_, _) {},
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(
              key: ValueKey(note.id),
              note: note,
              index: index,
              onEdit: () => _openNote(note.id),
              onMove: (from, to) {
                context.read<NoteProvider>().reorder(fromId: notes[from].id, toId: notes[to].id);
              },
              selectionMode: selectionMode,
              isSelected: selectedNoteIds.contains(note.id),
              onSelectToggle: () {
                setState(() {
                  if (!selectedNoteIds.add(note.id)) selectedNoteIds.remove(note.id);
                });
              },
              isMini: true,
            );
          },
        );

      case ViewMode.card:
        return _buildGrid(notes);
    }
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.85 * 255).round()),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () async {
                  // Confirm bulk delete
                  final confirmed = await showDeleteConfirmDialog(context);
                  if (!confirmed) return;
                  final provider = context.read<NoteProvider>();
                  for (final id in selectedNoteIds.toList()) {
                    provider.delete(id);
                  }
                  setState(() => selectedNoteIds.clear());
                },
                icon: const Icon(Icons.delete, color: Colors.white),
                label: Text('${selectedNoteIds.length} Delete', style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () async {
                  final provider = context.read<NoteProvider>();
                  if (_showArchived) {
                    for (final id in selectedNoteIds.toList()) {
                      provider.unarchiveNote(id);
                    }
                  } else {
                    for (final id in selectedNoteIds.toList()) {
                      provider.archiveNote(id);
                    }
                  }
                  setState(() => selectedNoteIds.clear());
                },
                icon: Icon(_showArchived ? Icons.unarchive : Icons.archive, color: Colors.white),
                label: Text('${selectedNoteIds.length} ${_showArchived ? 'Unarchive' : 'Archive'}', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  Future<void> _addNewNote() async {
    final result = await showGeneralDialog<NoteDialogResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      pageBuilder: (context, animation, secondaryAnimation) => const NoteDialog(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    if (result.type == NoteDialogResultType.save && result.note != null) {
      context.read<NoteProvider>().add(result.note!);
    }
  }
}
