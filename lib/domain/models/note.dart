// domain/models/note.dart
// Pure Dart Note model for Memind app (no UI dependencies)
// This model is designed for use in the domain layer and is compatible with Hive.
// All color information is stored as an integer (ARGB32) to avoid Flutter UI dependencies.
//
// Author: [Your Name]
// Date: 2026-01-11

import 'package:uuid/uuid.dart';

/// Represents a single note in the Memind app.
///
/// This model is pure Dart and contains no UI dependencies.
/// Color is stored as an ARGB integer for persistence and cross-platform compatibility.
class Note {
  /// Unique identifier for the note (UUID v4)
  final String id;

  /// Title of the note
  final String title;

  /// Content/body of the note
  final String content;

  /// Color as ARGB integer (e.g., 0xFFFFEE58 for yellow)
  final int color;

  /// Whether the note is pinned
  final bool pinned;

  /// Creation timestamp (ISO8601 string in JSON)
  final DateTime createdAt;

  /// Last updated timestamp
  final DateTime updatedAt;

  /// Whether the note is archived
  final bool archived;

  /// Optional folder name (null if not assigned)
  final String? folder;

  /// Main constructor for Note
  Note({
    required this.id,
    required this.title,
    required this.content,
    this.color = 0xFFFFFF00, // Default: yellow
    this.pinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archived = false,
    this.folder,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Factory for creating a new note with a generated UUID
  factory Note.create({
    required String title,
    required String content,
    int color = 0xFFFFFF00, // Default: yellow
    bool pinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool archived = false,
    String? folder,
  }) {
    return Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      color: color,
      pinned: pinned,
      createdAt: createdAt,
      updatedAt: updatedAt,
      archived: archived,
      folder: folder,
    );
  }

  /// Returns a copy of the note with updated fields
  Note copyWith({
    String? title,
    String? content,
    int? color,
    bool? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
    String? folder,
  }) {
    return Note(
      id: id, // ID should never change
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
      folder: folder ?? this.folder,
    );
  }

  /// Convert note to JSON for persistence (Hive/REST)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color, // ARGB int
      'pinned': pinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'archived': archived,
      'folder': folder,
    };
  }

  /// Factory to create a note from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      color: json['color'] as int,
      pinned: json['pinned'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      archived: json['archived'] ?? false,
      folder: json['folder'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Note && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
