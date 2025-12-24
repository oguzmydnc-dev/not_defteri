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
import 'pages/home_page.dart';

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
      home: const HomePage(),
    );
  }
}


