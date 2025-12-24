// widgets/note_card.dart
// A compact card widget that displays a single Note.
//
// Responsibilities:
// - Render note title and preview content
// - Show pinned indicator and selection state
// - Support drag-and-drop reordering via LongPressDraggable + DragTarget
// - Forward edit/select/move callbacks to the parent
//
// This file intentionally preserves original behavior; comments are added
// to make the widget easier to understand for maintainers.

import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final int index;
  final VoidCallback onEdit;
  final void Function(int from, int to) onMove;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onSelectToggle;
  // When `isMini` is true the card renders in a compact "mini" preview
  // state. In mini state we hide all textual content (title/snippet)
  // and only show a color/shape preview. This is useful for gallery
  // previews, widgets, or compact UIs. Drag & drop behavior remains
  // supported in both normal and mini modes; when mini the UI shows a
  // small drag handle to clearly indicate the card is draggable.
  final bool isMini;

  const NoteCard({
    super.key,
    required this.note,
    required this.index,
    required this.onEdit,
    required this.onMove,
    required this.selectionMode,
    required this.isSelected,
    required this.onSelectToggle,
    this.isMini = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use the ReorderableGridView's built-in drag mechanics instead of
    // manually composing LongPressDraggable + DragTarget. The grid view
    // handles reordering animation and gestures; we only expose a
    // `ReorderableDragStartListener` affordance in mini mode so users
    // clearly see how to drag items.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: Card(
        color: note.color,
        elevation: note.pinned ? 8 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: selectionMode ? onSelectToggle : onEdit,
          onLongPress: selectionMode ? null : onSelectToggle,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.pinned) const Icon(Icons.push_pin, size: 16),
                    // In mini mode we DO NOT hide text; instead we use a
                    // slightly more compact layout while preserving title
                    // and content visibility per user request.
                    Text(
                      note.title,
                      maxLines: isMini ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!isMini)
                      Expanded(
                        child: Text(
                          note.content,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (selectionMode)
                Positioned(
                  right: 6,
                  bottom: 6,
                  // Selection indicator shown in selection mode.
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: Colors.white,
                  ),
                ),
              // Drag handle visible in mini mode: use ReorderableDragStartListener
              // so the parent ReorderableGridView starts the built-in drag.
              if (isMini)
                Positioned(
                  right: 8,
                  top: 8,
                  child: ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.drag_handle, size: 18, color: Colors.white70),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dragFeedback() {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      child: Card(
        color: note.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const SizedBox(
          width: 160,
          height: 120,
        ),
      ),
    );
  }
}

