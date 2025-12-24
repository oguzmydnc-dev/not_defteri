// home_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../providers/note_provider.dart';
import '../providers/theme_provider.dart';
import '../services/voice_service.dart';
import '../services/ai_service.dart';

import '../widgets/note_card.dart';
import '../widgets/note_dialog.dart';
import '../widgets/grid_background.dart';
import '../widgets/note_overlay.dart';

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

  final VoiceService _voiceService = VoiceService();
  final AiService _aiService = AiService();

  bool get selectionMode => selectedNoteIds.isNotEmpty;

  void _openNote(String id) {
    if (selectionMode) return;
    setState(() => activeNoteId = id);
  }

  void _closeNote() {
    setState(() => activeNoteId = null);
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NoteProvider>().notes;
    final query = _searchController.text.trim();
    final filteredNotes = query.isEmpty
        ? notes
        : notes.where((n) {
            final q = query.toLowerCase();
            return n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
          }).toList();

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
            _buildGrid(filteredNotes),
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
              : const Text('Notes')),
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
