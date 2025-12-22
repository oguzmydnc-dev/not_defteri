import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/not_model.dart';

class NotProvider extends ChangeNotifier {
  static const _storageKey = 'notlar_json';

  final List<Not> _notlar = [];

  List<Not> get notlar => List.unmodifiable(_notlar);

  Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return;

    final List decoded = jsonDecode(jsonString);
    _notlar
      ..clear()
      ..addAll(decoded.map((e) => Not.fromJson(e)));

    _sirala();
    notifyListeners();
  }

  Future<void> _kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(_notlar.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  void ekle(Not not) {
    _notlar.add(not);
    _sirala();
    _kaydet();
    notifyListeners();
  }

  void guncelle(int index, Not not) {
    _notlar[index] = not;
    _sirala();
    _kaydet();
    notifyListeners();
  }

  void sil(int index) {
    _notlar.removeAt(index);
    _kaydet();
    notifyListeners();
  }

  void _sirala() {
    _notlar.sort((a, b) {
      if (a.sabit == b.sabit) return 0;
      return a.sabit ? -1 : 1;
    });
  }

  void yerDegistir(int oldIndex, int newIndex) {
    final movingNote = _notlar[oldIndex];
    if (movingNote.sabit) return;

    final sabitCount = _notlar.where((n) => n.sabit).length;
    newIndex = newIndex.clamp(sabitCount, _notlar.length - 1);

    if (oldIndex < newIndex) newIndex -= 1;

    _notlar.removeAt(oldIndex);
    _notlar.insert(newIndex, movingNote);

    _kaydet();
    notifyListeners();
  }
}
