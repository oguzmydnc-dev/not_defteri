// state/note_actions.dart
// Encapsulates note actions (delete, pin, update, archive, reorder) for Memind app.
// This keeps the UI dumb and centralizes all note-related business logic.
//
// Author: [Your Name]
// Date: 2026-01-11

import '../providers/note_provider.dart';
import '../domain/models/note.dart';

/// Helper class for note actions, to be used by UI or controllers.
class NoteActions {
  final NoteProvider noteProvider;

  NoteActions(this.noteProvider);

  /// Delete a note by ID.
  void delete(String id) => noteProvider.delete(id);

  /// Pin or unpin a note by ID.
  void togglePin(String id) => noteProvider.togglePin(id);

  /// Update a note.
  void update(Note note) => noteProvider.update(note);

  /// Archive a note by ID.
  void archive(String id) => noteProvider.archiveNote(id);

  /// Unarchive a note by ID.
  void unarchive(String id) => noteProvider.unarchiveNote(id);

  /// Move a note to a folder.
  void moveToFolder(String id, String? folder) => noteProvider.moveToFolder(id, folder);

  /// Reorder notes (by ID).
  void reorder({required String fromId, required String toId}) => noteProvider.reorder(fromId: fromId, toId: toId);
}
