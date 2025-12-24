// models/not_model.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Note model represents a single note with id, title, content, color, and pinned status.
class Not {
  final String id;
  final String baslik;
  final String icerik;
  final Color renk;
  final bool sabit;

  const Not({
    required this.id,
    required this.baslik,
    required this.icerik,
    this.renk = Colors.yellow,
    this.sabit = false,
  });

  /// Factory for creating a new note
  factory Not.yeni({
    required String baslik,
    required String icerik,
    Color renk = Colors.yellow,
    bool sabit = false,
  }) {
    return Not(
      id: const Uuid().v4(),
      baslik: baslik,
      icerik: icerik,
      renk: renk,
      sabit: sabit,
    );
  }

  /// Returns a copy of the note with updated fields
  Not copyWith({
    String? baslik,
    String? icerik,
    Color? renk,
    bool? sabit,
  }) {
    return Not(
      id: id, // ID should never change
      baslik: baslik ?? this.baslik,
      icerik: icerik ?? this.icerik,
      renk: renk ?? this.renk,
      sabit: sabit ?? this.sabit,
    );
  }

  /// Convert note to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baslik': baslik,
      'icerik': icerik,
      'renk': renk.value,
      'sabit': sabit,
    };
  }

  /// Factory to create a note from JSON
  factory Not.fromJson(Map<String, dynamic> json) {
    return Not(
      id: json['id'] as String,
      baslik: json['baslik'] as String,
      icerik: json['icerik'] as String,
      renk: Color(json['renk'] as int),
      sabit: json['sabit'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Not && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
