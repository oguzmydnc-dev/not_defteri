// services/ai_service.dart
// Small AI integration stub with placeholders for future implementation.
// Implement actual API calls or on-device models as needed.

import '../models/note_model.dart';

class AiService {
  AiService();

  /// Generate a short summary for a note. Returns a placeholder string
  /// by default so the app can call this API without crashing.
  Future<String> summarize(Note note) async {
    // Replace with actual AI call; return a safe placeholder now.
    if (note.content.trim().isEmpty && note.title.trim().isEmpty) {
      return 'No content to summarize.';
    }
    return 'AI summary is not configured. Install AI integration to enable summaries.';
  }
}
