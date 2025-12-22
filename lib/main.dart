import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import 'widgets/not_karti.dart';
import 'widgets/not_dialog.dart';
import 'models/not_model.dart';
import 'providers/not_provider.dart';
import 'providers/theme_provider.dart';
import 'widgets/grid_background.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotProvider()..yukle()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
  @override
  Widget build(BuildContext context) {
    final notlar = context.watch<NotProvider>().notlar;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Not Defteri"),
        actions: [
        IconButton(
          icon: const Icon(Icons.brightness_6),
          onPressed: () {
            context.read<ThemeProvider>().toggleTheme();
          },
        ),
        ],
      ),
      body: Stack(
        children: [
          const GridBackground(
            child: SizedBox.expand(),
          ),
          ReorderableGridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: notlar.length,
            onReorder: (oldIndex, newIndex) {
              context.read<NotProvider>().yerDegistir(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              return NotKarti(
                key: ValueKey(notlar[index]),
                not: notlar[index],
                index: index,
                onEdit: () => _notDuzenle(index),
                onMove: (from, to) {
                  context.read<NotProvider>().yerDegistir(from, to);
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _yeniNotEkle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _yeniNotEkle() async {
    final sonuc = await showDialog<Not>(
      context: context,
      builder: (_) => const NotDialog(),
    );

    if (!mounted || sonuc == null) return;

    context.read<NotProvider>().ekle(sonuc);
  }

  Future<void> _notDuzenle(int index) async {
    final provider = context.read<NotProvider>();

    final sonuc = await showDialog<Not>(
      context: context,
      builder: (_) => NotDialog(not: provider.notlar[index]),
    );

    if (!mounted || sonuc == null) return;

    provider.guncelle(index, sonuc);

  }
}

