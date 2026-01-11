// data/datasources/hive_note_storage.dart
// Hive-based note storage service for Memind app
// This service is responsible for all Hive operations related to notes and folders.
// It implements the NoteStorage abstraction for reusability and testability.
//
// Author: [Your Name]
// Date: 2026-01-11

import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

/// Abstract storage interface for persisting notes as JSON-compatible maps.
/// This should be implemented by all note storage backends (Hive, SharedPrefs, etc).
abstract class NoteStorage {
  /// Load a list of note JSON objects from storage.
  Future<List<Map<String, dynamic>>> loadNotesJson();

  /// Save a list of note JSON objects to storage.
  Future<void> saveNotesJson(List<Map<String, dynamic>> notes);

  /// Load a list of folder names from storage.
  Future<List<String>> loadFolders();

  /// Save a list of folder names to storage.
  Future<void> saveFolders(List<String> folders);
}

/// Hive-backed implementation of NoteStorage.
/// Handles all note and folder persistence using Hive.
class HiveNoteStorage implements NoteStorage {
  static const String _boxName = 'notes_box';
  static const String _notesKey = 'notes_json';
  static const String _foldersKey = 'note_folders';

  Box<dynamic>? _box;

  HiveNoteStorage();

  /// Initialize Hive and open the box. Call once before using this service.
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<List<Map<String, dynamic>>> loadNotesJson() async {
    if (_box == null) await init();
    final raw = _box!.get(_notesKey);
    if (raw == null) return [];
    try {
      final List list = raw as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveNotesJson(List<Map<String, dynamic>> notes) async {
    if (_box == null) await init();
    await _box!.put(_notesKey, notes);
  }

  @override
  Future<List<String>> loadFolders() async {
    if (_box == null) await init();
    final raw = _box!.get(_foldersKey);
    if (raw == null) return [];
    try {
      return (raw as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveFolders(List<String> folders) async {
    if (_box == null) await init();
    await _box!.put(_foldersKey, folders);
  }

  /// Migrate data from another storage backend (e.g., SharedPreferences)
  /// This method should be called only during migration.
  Future<void> migrateFrom(Map<String, dynamic> data) async {
    await init();
    await saveNotesJson(data['notes'] as List<Map<String, dynamic>>);
    await saveFolders(data['folders'] as List<String>);
  }
}
