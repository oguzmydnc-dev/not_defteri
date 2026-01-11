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

import 'localization/language_manager.dart';
import 'localization/language_keys.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageManager.instance.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()..load()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider<LanguageManager>.value(value: LanguageManager.instance),
      ],
      child: const NotesApp(),
    ),
  );
}
class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for language changes and rebuild MaterialApp instantly
    return Consumer<LanguageManager>(
      builder: (context, langManager, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: context.watch<ThemeProvider>().mode,
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          home: const HomePage(),
        );
      },
    );
  }
}


