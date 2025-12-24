// providers/not_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NoteProvider extends ChangeNotifier {
  static const _storageKey = 'notes_json';

  final List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);

  /// Load notes from local storage
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return;

    final List decoded = jsonDecode(jsonString);
    _notes
      ..clear()
      ..addAll(decoded.map((e) => Note.fromJson(e)));

    _sort();
    notifyListeners();
  }

  /// Save notes to local storage
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_notes.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Add new note
  void add(Note note) {
    if (note.title.trim().isEmpty || note.content.trim().isEmpty) return;

    _notes.add(note);
    _sort();
    _save();
    notifyListeners();
  }

  /// Update existing note
  void update(Note updated) {
    if (updated.title.trim().isEmpty || updated.content.trim().isEmpty) return;

    final index = _notes.indexWhere((n) => n.id == updated.id);
    if (index == -1) return;

    _notes[index] = updated;
    _sort();
    _save();
    notifyListeners();
  }

  /// Delete a note
  void delete(String id) {
    _notes.removeWhere((n) => n.id == id);
    _save();
    notifyListeners();
  }

  Note? getById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Toggle pinned status
  void togglePin(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final note = _notes[index];
    _notes[index] = note.copyWith(pinned: !note.pinned, updatedAt: DateTime.now());

    _sort();
    _save();
    notifyListeners();
  }

  /// Sort notes by pinned first
  void _sort() {
    _notes.sort((a, b) {
      if (a.pinned == b.pinned) return 0;
      return a.pinned ? -1 : 1;
    });
  }

  /// Reorder notes with safe pin handling
  void reorder({required String fromId, required String toId}) {
    final fromIndex = _notes.indexWhere((n) => n.id == fromId);
    final toIndex = _notes.indexWhere((n) => n.id == toId);

    if (fromIndex == -1 || toIndex == -1) return;

    final movingNote = _notes[fromIndex];
    if (movingNote.pinned) return;

    final pinnedCount = _notes.where((n) => n.pinned).length;

    var newIndex = toIndex.clamp(pinnedCount, _notes.length - 1);

    if (fromIndex < newIndex) newIndex -= 1;

    _notes.removeAt(fromIndex);
    _notes.insert(newIndex, movingNote);

    _save();
    notifyListeners();
  }
}
