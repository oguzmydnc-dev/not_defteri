// services/hive_service.dart
// Storage abstraction for notes. Provides a SharedPreferences-backed
// implementation (used by the app today) and a Hive-backed stub that
// documents how to migrate to Hive without changing existing code.
//
// This file is intentionally non-breaking: the provider continues to
// use SharedPreferences until you opt-in to replace it with Hive.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
}

/// Hive-backed implementation (stub).
///
/// To migrate:
/// 1. Add `hive` and `hive_flutter` to `pubspec.yaml`.
/// 2. Register adapters for `Note` (or store raw maps) and open a Box.
/// 3. Implement `loadNotesJson` / `saveNotesJson` using the Box API.
///
/// This stub keeps the method signatures so switching implementations
/// in `NoteProvider` is straightforward and non-breaking.
class HiveService implements NoteStorage {
  HiveService() {
    // Intentionally empty: implement initialization where you call this
    // class from main() after calling `Hive.initFlutter()`.
  }

  @override
  Future<List<Map<String, dynamic>>> loadNotesJson() async {
    throw UnimplementedError('HiveService.loadNotesJson is not implemented.');
  }

  @override
  Future<void> saveNotesJson(List<Map<String, dynamic>> notes) async {
    throw UnimplementedError('HiveService.saveNotesJson is not implemented.');
  }
}

/// Factory: returns the SharedPreferences-backed storage by default.
NoteStorage getDefaultNoteStorage() => SharedPrefsStorage();
