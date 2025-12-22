import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);

    if (value == 'dark') {
      _mode = ThemeMode.dark;
    } else {
      _mode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _mode =
        _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      _mode == ThemeMode.dark ? 'dark' : 'light',
    );

    notifyListeners();
  }
}
