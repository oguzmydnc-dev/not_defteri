// data/datasources/shared_prefs_note_storage.dart
// SharedPreferences-based note storage service for Memind app
// This service is responsible for all SharedPreferences operations related to notes and folders.
// It implements the NoteStorage abstraction for reusability and testability.
//
// Author: [Your Name]
// Date: 2026-01-11

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'hive_note_storage.dart'; // For NoteStorage interface

/// SharedPreferences-backed implementation of NoteStorage.
/// Handles all note and folder persistence using SharedPreferences.
class SharedPrefsNoteStorage implements NoteStorage {
  static const String _storageKey = 'notes_json';
  static const String _foldersKey = 'note_folders';

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

  @override
  Future<List<String>> loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_foldersKey) ?? <String>[];
  }

  @override
  Future<void> saveFolders(List<String> folders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_foldersKey, folders);
  }
}
