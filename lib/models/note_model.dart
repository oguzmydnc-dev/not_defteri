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

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.color = Colors.yellow,
    this.pinned = false,
  });

  /// Factory for creating a new note
  factory Note.create({
    required String title,
    required String content,
    Color color = Colors.yellow,
    bool pinned = false,
  }) {
    return Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      color: color,
      pinned: pinned,
    );
  }

  /// Returns a copy of the note with updated fields
  Note copyWith({
    String? title,
    String? content,
    Color? color,
    bool? pinned,
  }) {
    return Note(
      id: id, // ID should never change
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      pinned: pinned ?? this.pinned,
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Note && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
