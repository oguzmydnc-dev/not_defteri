// pages/note_detail_page.dart
// Page that shows a single Note in full detail.
//
// Notes:
// - Uses the note's color as a subtle background (low alpha)
// - Shows the title (if present) and the full content in a scrollable view
// - This is a read-only detail view; editing is handled elsewhere.

import 'package:flutter/material.dart';
import '../models/note_model.dart';

/// Detailed note page with scrollable content.
class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    // Compose a subtle background color using the note's color with low alpha.
    final backgroundColor = note.color.withAlpha((0.15 * 255).round());

    return Scaffold(
      appBar: AppBar(
        // Use the note title in the AppBar if available; otherwise a generic label.
        title: Text(
          note.title.isEmpty ? 'Note Detail' : note.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          // Column holds the title (if any) and the full content text.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
