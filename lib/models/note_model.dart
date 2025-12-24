// models/note_model.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Note model represents a single note with id, title, content, color, and pinned status.
class Note {
  final String id;
  final String title;
  final String content;
  final Color color;
  final bool pinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;
  final String? folder;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.color = Colors.yellow,
    this.pinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archived = false,
    this.folder,
  }) :
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  /// Factory for creating a new note
  factory Note.create({
    required String title,
    required String content,
    Color color = Colors.yellow,
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
    Color? color,
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

  /// Convert note to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      // Store ARGB32 explicitly using the new component accessors.
      'color': (
        ((color.a * 255.0).round().clamp(0, 255)) << 24 |
        ((color.r * 255.0).round().clamp(0, 255)) << 16 |
        ((color.g * 255.0).round().clamp(0, 255)) << 8 |
        ((color.b * 255.0).round().clamp(0, 255))
      ),
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
      color: Color(json['color'] as int),
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
