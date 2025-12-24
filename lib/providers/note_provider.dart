// providers/not_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NotProvider extends ChangeNotifier {
  static const _storageKey = 'notlar_json';

  final List<Not> _notlar = [];

  List<Not> get notlar => List.unmodifiable(_notlar);

  /// Load notes from local storage
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

  /// Save notes to local storage
  Future<void> _kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(_notlar.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Add new note
  void ekle(Not not) {
    if (not.baslik.trim().isEmpty || not.icerik.trim().isEmpty) return;

    _notlar.add(not);
    _sirala();
    _kaydet();
    notifyListeners();
  }

  /// Update existing note
  void guncelle(Not guncel) {
    if (guncel.baslik.trim().isEmpty || guncel.icerik.trim().isEmpty) return;

    final index = _notlar.indexWhere((n) => n.id == guncel.id);
    if (index == -1) return;

    _notlar[index] = guncel;
    _sirala();
    _kaydet();
    notifyListeners();
  }

  /// Delete a note
  void sil(String id) {
    _notlar.removeWhere((n) => n.id == id);
    _kaydet();
    notifyListeners();
  }

  Not? getById(String id) {
    try {
      return _notlar.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Toggle pinned status
  void toggleSabitle(String id) {
    final index = _notlar.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final not = _notlar[index];
    _notlar[index] = not.copyWith(sabit: !not.sabit);

    _sirala();
    _kaydet();
    notifyListeners();
  }

  /// Sort notes by pinned first
  void _sirala() {
    _notlar.sort((a, b) {
      if (a.sabit == b.sabit) return 0;
      return a.sabit ? -1 : 1;
    });
  }

  /// Reorder notes with safe pin handling
  void yerDegistir({required String fromId, required String toId}) {
    final fromIndex = _notlar.indexWhere((n) => n.id == fromId);
    final toIndex = _notlar.indexWhere((n) => n.id == toId);

    if (fromIndex == -1 || toIndex == -1) return;

    final movingNote = _notlar[fromIndex];
    if (movingNote.sabit) return;

    final sabitCount = _notlar.where((n) => n.sabit).length;

    var newIndex = toIndex.clamp(sabitCount, _notlar.length - 1);

    if (fromIndex < newIndex) newIndex -= 1;

    _notlar.removeAt(fromIndex);
    _notlar.insert(newIndex, movingNote);

    _kaydet();
    notifyListeners();
  }
}
