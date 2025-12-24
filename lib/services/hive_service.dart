// services/hive_service.dart
// Storage abstraction for notes. Provides a SharedPreferences-backed
// implementation (used by the app today) and a Hive-backed stub that
// documents how to migrate to Hive without changing existing code.
//
// This file is intentionally non-breaking: the provider continues to
// use SharedPreferences until you opt-in to replace it with Hive.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Abstract storage interface for persisting notes as JSON-compatible maps.
abstract class NoteStorage {
  /// Load a list of note JSON objects from storage.
  Future<List<Map<String, dynamic>>> loadNotesJson();

  /// Save a list of note JSON objects to storage.
  Future<void> saveNotesJson(List<Map<String, dynamic>> notes);
}

/// Current default implementation: SharedPreferences-based storage.
class SharedPrefsStorage implements NoteStorage {
  static const _storageKey = 'notes_json';
  static const _foldersKey = 'note_folders';

  @override
  Future<List<Map<String, dynamic>>> loadNotesJson() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> saveNotesJson(List<Map<String, dynamic>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(notes);
    await prefs.setString(_storageKey, jsonString);
  }

  Future<List<String>> loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_foldersKey) ?? <String>[];
  }

  Future<void> saveFolders(List<String> folders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_foldersKey, folders);
  }
}

/// Hive-backed implementation.
class HiveService implements NoteStorage {
  static const _boxName = 'notes_box';
  static const _notesKey = 'notes_json';
  static const _foldersKey = 'note_folders';

  Box<dynamic>? _box;

  HiveService();

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

  Future<void> saveFolders(List<String> folders) async {
    if (_box == null) await init();
    await _box!.put(_foldersKey, folders);
  }

  /// Migrate data from SharedPreferences (used by SharedPrefsStorage)
  Future<void> migrateFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(SharedPrefsStorage._storageKey);
    List<Map<String, dynamic>> notes = [];
    if (jsonString != null && jsonString.isNotEmpty) {
      final decoded = jsonDecode(jsonString) as List;
      notes = decoded.cast<Map<String, dynamic>>();
    }

    final folders = prefs.getStringList(SharedPrefsStorage._foldersKey) ?? <String>[];

    await init();
    await saveNotesJson(notes);
    await saveFolders(folders);
  }
}

/// Factory: returns the SharedPreferences-backed storage by default.
NoteStorage getDefaultNoteStorage() => SharedPrefsStorage();
