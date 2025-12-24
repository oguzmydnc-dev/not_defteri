// main.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import 'providers/note_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';

import 'widgets/note_card.dart';
import 'widgets/note_dialog.dart';
import 'widgets/grid_background.dart';
import 'widgets/note_overlay.dart';

import 'pages/settings_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()..load()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const NotesApp(),
    ),
  );
}
class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<ThemeProvider>().mode,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const NoteListPage(),
    );
  }
}

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  String? activeNoteId;
  final Set<String> selectedNoteIds = {};

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
            _buildGrid(notes),
            if (activeNoteId != null)
              Builder(
                builder: (ctx) {
                  final note = context.read<NoteProvider>().getById(activeNoteId!);
                  if (note == null) return const SizedBox.shrink();

                  return NoteOverlay(
                    note: note,
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
          child: const Icon(Icons.add),
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
        title: selectionMode
          ? Text('${selectedNoteIds.length} selected')
          : const Text('Notes'),
      actions: selectionMode
          ? []
          : [
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
          child: const Icon(Icons.delete, color: Colors.white),
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
