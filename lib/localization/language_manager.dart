// localization/language_manager.dart
// LanguageManager for Memind app: provides strongly-typed localization, runtime switching, and persistence via Hive.
// Widgets can listen to LanguageManager for instant UI updates.
//
// Author: [Your Name]
// Date: 2026-01-11

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'en.dart';
import 'tr.dart';
import 'language_keys.dart';

/// Supported languages for the app.
enum AppLanguage { tr, en }

/// Maps AppLanguage to the corresponding string map.
final Map<AppLanguage, Map<LangKey, String>> _localizedValues = {
  AppLanguage.tr: _trMap,
  AppLanguage.en: _enMap,
};

/// Converts the raw string-keyed maps to strongly-typed maps.
final Map<LangKey, String> _enMap = {
  for (final entry in en.entries)
    LangKey.values.firstWhere((e) => e.name == entry.key, orElse: () => throw Exception('Missing key: ${entry.key}')): entry.value,
};
final Map<LangKey, String> _trMap = {
  for (final entry in tr.entries)
    LangKey.values.firstWhere((e) => e.name == entry.key, orElse: () => throw Exception('Missing key: ${entry.key}')): entry.value,
};

/// Hive box name for language persistence.
const String _langBox = 'language_box';
const String _langKey = 'selected_language';

/// LanguageManager provides strongly-typed localization, runtime switching, and persistence.
class LanguageManager extends ChangeNotifier {
  static LanguageManager? _instance;
  late AppLanguage _current;
  late Box _box;

  /// Singleton instance
  static LanguageManager get instance => _instance ??= LanguageManager._();

  LanguageManager._();

  /// Initialize Hive and load persisted language (default: Turkish)
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_langBox);
    final saved = _box.get(_langKey) as String?;
    _current = AppLanguage.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppLanguage.tr,
    );
    notifyListeners();
  }

  /// Get the current language
  AppLanguage get current => _current;

  /// Get a localized string by key
  String t(LangKey key) => _localizedValues[_current]![key] ?? key.name;

  /// Switch language at runtime and persist selection
  Future<void> setLanguage(AppLanguage lang) async {
    if (_current == lang) return;
    _current = lang;
    await _box.put(_langKey, lang.name);
    notifyListeners();
  }
}
