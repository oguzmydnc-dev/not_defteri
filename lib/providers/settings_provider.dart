import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _askBeforeDeleteKey = 'ask_before_delete';

  bool _askBeforeDelete = true;
  bool get askBeforeDelete => _askBeforeDelete;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _askBeforeDelete = prefs.getBool(_askBeforeDeleteKey) ?? true;
    notifyListeners();
  }

  Future<void> setAskBeforeDelete(bool value) async {
    _askBeforeDelete = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askBeforeDeleteKey, value);
    notifyListeners();
  }
}
