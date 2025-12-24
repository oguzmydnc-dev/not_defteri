// pages/note_detail_page.dart
import 'package:flutter/material.dart';
import '../models/note_model.dart';

/// Detailed note page with scrollable content
class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          note.title.isEmpty ? 'Note Detail' : note.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(
        color: note.color.withAlpha((0.15 * 255).round()),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align left
            children: [
              if (note.title.isNotEmpty)
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                note.content,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
