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

import 'settings_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotProvider()..yukle()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const NotDefteriApp(),
    ),
  );
}

class NotDefteriApp extends StatelessWidget {
  const NotDefteriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<ThemeProvider>().mode,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const NotListesiSayfasi(),
    );
  }
}

class NotListesiSayfasi extends StatefulWidget {
  const NotListesiSayfasi({super.key});

  @override
  State<NotListesiSayfasi> createState() => _NotListesiSayfasiState();
}

class _NotListesiSayfasiState extends State<NotListesiSayfasi> {
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
    final notlar = context.watch<NotProvider>().notlar;

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
            _buildGrid(notlar),
            if (activeNoteId != null)
              Builder(
                builder: (ctx) {
                  final not =
                      context.read<NotProvider>().getById(activeNoteId!);
                  if (not == null) return const SizedBox.shrink();

                  return NoteOverlay(
                    not: not,
                    onClose: _closeNote,
                    onEdit: () async {
                      _closeNote();

                      final result = await showGeneralDialog<NotDialogResult>(
                        context: ctx,
                        barrierDismissible: true,
                        barrierLabel: 'Dismiss',
                        pageBuilder: (_, __, ___) => NotDialog(not: not),
                        transitionBuilder: (_, anim, __, child) {
                          return FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(
                              scale: anim,
                              child: child,
                            ),
                          );
                        },
                      );

                      if (!mounted || result == null) return;

                      if (result.type == NotDialogResultType.save &&
                          result.not != null) {
                        context.read<NotProvider>().guncelle(result.not!);
                      }

                      if (result.type == NotDialogResultType.delete) {
                        context.read<NotProvider>().sil(not.id);
                      }
                    },
                    onDelete: () {
                      context.read<NotProvider>().sil(not.id);
                      _closeNote();
                    },
                    onTogglePin: () {
                      context.read<NotProvider>().toggleSabitle(not.id);
                    },
                  );
                },
              ),
            if (selectionMode) _buildBottomBar(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _yeniNotEkle,
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
          : const Text('Not Defteri'),
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

  Widget _buildGrid(List notlar) {
    return ReorderableGridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: notlar.length,
      onReorder: selectionMode
          ? (oldIndex, newIndex) {
              context.read<NotProvider>().yerDegistir(
                    fromId: notlar[oldIndex].id,
                    toId: notlar[newIndex].id,
                  );
            }
          : (_, _) {},
      itemBuilder: (context, index) {
        final not = notlar[index];
        return NotKarti(
          key: ValueKey(not.id),
          not: not,
          index: index,
          onEdit: () => _openNote(not.id),
          onMove: (from, to) {
            context.read<NotProvider>().yerDegistir(
                  fromId: notlar[from].id,
                  toId: notlar[to].id,
                );
          },
          selectionMode: selectionMode,
          isSelected: selectedNoteIds.contains(not.id),
          onSelectToggle: () {
            setState(() {
              if (!selectedNoteIds.add(not.id)) {
                selectedNoteIds.remove(not.id);
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
            color: Colors.black.withOpacity(0.85),
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

  Future<void> _yeniNotEkle() async {
    final result = await showGeneralDialog<NotDialogResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      pageBuilder: (_, __, ___) => const NotDialog(),
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: anim,
            child: child,
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    if (result.type == NotDialogResultType.save && result.not != null) {
      context.read<NotProvider>().ekle(result.not!);
    }
  }
}
