// state/selection_provider.dart
// Provider for managing selection and drag state in Memind app.
// This keeps the UI dumb and centralizes all selection/drag logic.
//
// Author: [Your Name]
// Date: 2026-01-11

import 'package:flutter/material.dart';

/// Provider for selection and drag state.
/// Use this to manage multi-select, selection mode, and drag state.
class SelectionProvider extends ChangeNotifier {
  /// Set of selected note IDs.
  final Set<String> _selectedNoteIds = {};

  /// Currently dragged note ID (if any).
  String? _draggedNoteId;

  /// Returns an unmodifiable view of selected note IDs.
  Set<String> get selectedNoteIds => Set.unmodifiable(_selectedNoteIds);

  /// Returns true if any notes are selected (selection mode active).
  bool get selectionMode => _selectedNoteIds.isNotEmpty;

  /// Returns the currently dragged note ID, or null if none.
  String? get draggedNoteId => _draggedNoteId;

  /// Select or deselect a note by ID.
  void toggleSelection(String noteId) {
    if (!_selectedNoteIds.add(noteId)) {
      _selectedNoteIds.remove(noteId);
    }
    notifyListeners();
  }

  /// Clear all selections.
  void clearSelection() {
    _selectedNoteIds.clear();
    notifyListeners();
  }

  /// Set the currently dragged note ID.
  void startDrag(String noteId) {
    _draggedNoteId = noteId;
    notifyListeners();
  }

  /// Clear the drag state.
  void endDrag() {
    _draggedNoteId = null;
    notifyListeners();
  }
}
