import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeOption { system, light, dark }
enum ViewMode { card, list, mini }

class SettingsProvider extends ChangeNotifier {
  static const _askBeforeDeleteKey = 'ask_before_delete';
  static const _themeKey = 'theme_option';
  static const _titleFontKey = 'title_font';
  static const _contentFontKey = 'content_font';
  static const _localeKey = 'locale';
  static const _backgroundTypeKey = 'background_type';
  static const _backgroundPathKey = 'background_path';
  static const _viewModeKey = 'view_mode';
  static const _useHiveKey = 'use_hive_storage';

  bool _askBeforeDelete = true;
  ThemeOption _theme = ThemeOption.system;
  String _titleFont = 'Roboto';
  String _contentFont = 'Roboto';
  String _locale = 'en';
  String _backgroundType = 'default'; // 'default' or 'image'
  String? _backgroundPath;
  ViewMode _viewMode = ViewMode.card;
  bool _useHive = false;

  bool get askBeforeDelete => _askBeforeDelete;
  ThemeOption get theme => _theme;
  String get titleFont => _titleFont;
  String get contentFont => _contentFont;
  String get locale => _locale;
  String get backgroundType => _backgroundType;
  String? get backgroundPath => _backgroundPath;
  ViewMode get viewMode => _viewMode;
  bool get useHive => _useHive;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _askBeforeDelete = prefs.getBool(_askBeforeDeleteKey) ?? true;
    final themeStr = prefs.getString(_themeKey);
    if (themeStr != null) {
      _theme = ThemeOption.values.firstWhere((e) => e.name == themeStr, orElse: () => ThemeOption.system);
    }
    _titleFont = prefs.getString(_titleFontKey) ?? _titleFont;
    _contentFont = prefs.getString(_contentFontKey) ?? _contentFont;
    _locale = prefs.getString(_localeKey) ?? _locale;
    _backgroundType = prefs.getString(_backgroundTypeKey) ?? _backgroundType;
    _backgroundPath = prefs.getString(_backgroundPathKey);
    final vm = prefs.getString(_viewModeKey);
    if (vm != null) {
      _viewMode = ViewMode.values.firstWhere((e) => e.name == vm, orElse: () => ViewMode.card);
    }
    _useHive = prefs.getBool(_useHiveKey) ?? false;
    notifyListeners();
  }

  Future<void> setAskBeforeDelete(bool value) async {
    _askBeforeDelete = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askBeforeDeleteKey, value);
    notifyListeners();
  }

  Future<void> setTheme(ThemeOption option) async {
    _theme = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, option.name);
    notifyListeners();
  }

  Future<void> setTitleFont(String font) async {
    _titleFont = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_titleFontKey, font);
    notifyListeners();
  }

  Future<void> setContentFont(String font) async {
    _contentFont = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contentFontKey, font);
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
    notifyListeners();
  }

  Future<void> setBackgroundToDefault() async {
    _backgroundType = 'default';
    _backgroundPath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundTypeKey, _backgroundType);
    await prefs.remove(_backgroundPathKey);
    notifyListeners();
  }

  Future<void> setBackgroundImage(String path) async {
    _backgroundType = 'image';
    _backgroundPath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundTypeKey, _backgroundType);
    await prefs.setString(_backgroundPathKey, path);
    notifyListeners();
  }

  Future<void> setViewMode(ViewMode vm) async {
    _viewMode = vm;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_viewModeKey, vm.name);
    notifyListeners();
  }

  Future<void> setUseHive(bool value) async {
    _useHive = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useHiveKey, value);
    notifyListeners();
  }
}
