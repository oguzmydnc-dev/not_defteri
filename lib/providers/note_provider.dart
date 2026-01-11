// providers/not_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/note.dart';
import '../services/hive_service.dart';

class NoteProvider extends ChangeNotifier {
  NoteStorage _storage = getDefaultNoteStorage();

  final List<Note> _notes = [];

  final Set<String> _folders = {};

  List<Note> get notes => List.unmodifiable(_notes);

  /// Notes that are not archived (default view)
  List<Note> get activeNotes => List.unmodifiable(_notes.where((n) => !n.archived));

  /// Notes that are archived
  List<Note> get archivedNotes => List.unmodifiable(_notes.where((n) => n.archived));

  /// Persisted list of folder names (allows empty folders)
  List<String> get folders => List.unmodifiable(_folders);


  /// Load notes from local storage
  Future<void> load() async {
    // Load notes using the configured storage backend
    try {
      final list = await _storage.loadNotesJson();
      _notes
        ..clear()
        ..addAll(list.map((e) => Note.fromJson(e)));
    } catch (_) {
      _notes.clear();
    }

    // Load folders: prefer storage that supports folders (HiveService), otherwise SharedPreferences
    try {
      if (_storage is HiveService) {
        final folders = await (_storage as HiveService).loadFolders();
        _folders
          ..clear()
          ..addAll(folders);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final folderList = prefs.getStringList('note_folders') ?? <String>[];
        _folders
          ..clear()
          ..addAll(folderList);
      }
    } catch (_) {
      _folders.clear();
    }

    _sort();
    notifyListeners();
  }

  /// Save notes to local storage
  Future<void> _save() async {
    try {
      await _storage.saveNotesJson(_notes.map((n) => n.toJson()).toList());
    } catch (_) {}

    try {
      if (_storage is HiveService) {
        await (_storage as HiveService).saveFolders(_folders.toList());
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('note_folders', _folders.toList());
      }
    } catch (_) {}
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

  /// Archive a note by id
  void archiveNote(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final note = _notes[index];
    _notes[index] = note.copyWith(archived: true, updatedAt: DateTime.now());

    _save();
    notifyListeners();
  }

  /// Unarchive a note by id
  void unarchiveNote(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final note = _notes[index];
    _notes[index] = note.copyWith(archived: false, updatedAt: DateTime.now());

    _sort();
    _save();
    notifyListeners();
  }

  /// Move a note to a folder (or clear folder when null)
  void moveToFolder(String id, String? folder) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final note = _notes[index];
    _notes[index] = note.copyWith(folder: folder, updatedAt: DateTime.now());

    // If assigning to a folder, ensure it exists in the folders set
    if (folder != null && folder.trim().isNotEmpty) {
      _folders.add(folder.trim());
    }

    _save();
    notifyListeners();
  }

  /// Add a new folder name (no-op if exists or empty)
  void addFolder(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (_folders.contains(trimmed)) return;
    _folders.add(trimmed);
    _save();
    notifyListeners();
  }

  /// Rename an existing folder and update notes that belonged to it
  void renameFolder(String oldName, String newName) {
    final o = oldName.trim();
    final n = newName.trim();
    if (o.isEmpty || n.isEmpty) return;
    if (!_folders.contains(o)) return;
    if (o == n) return;

    for (var i = 0; i < _notes.length; i++) {
      final note = _notes[i];
      if (note.folder == o) {
        _notes[i] = note.copyWith(folder: n, updatedAt: DateTime.now());
      }
    }

    _folders.remove(o);
    _folders.add(n);
    _sort();
    _save();
    notifyListeners();
  }

  /// Delete a folder. Notes in the folder will be cleared (no folder).
  void deleteFolder(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    if (!_folders.contains(n)) return;

    for (var i = 0; i < _notes.length; i++) {
      final note = _notes[i];
      if (note.folder == n) {
        _notes[i] = note.copyWith(folder: null, updatedAt: DateTime.now());
      }
    }

    _folders.remove(n);
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

  /// Replace the underlying storage backend. Optionally migrate existing
  /// SharedPreferences data into the new storage when `migrate` is true.
  Future<void> replaceStorage(NoteStorage storage, {bool migrate = false}) async {
    if (storage is HiveService) {
      await storage.init();
      if (migrate) {
        await storage.migrateFromSharedPrefs();
      }
    }

    _storage = storage;
    await load();
  }
}
