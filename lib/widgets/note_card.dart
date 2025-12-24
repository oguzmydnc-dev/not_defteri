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
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final int index;
  final VoidCallback onEdit;
  final void Function(int from, int to) onMove;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onSelectToggle;

  const NoteCard({
    super.key,
    required this.note,
    required this.index,
    required this.onEdit,
    required this.onMove,
    required this.selectionMode,
    required this.isSelected,
    required this.onSelectToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Use LongPressDraggable to allow reordering notes by long-pressing
    // the card. While dragging we show a lightweight feedback Card and
    // use a DragTarget to accept drops and call the provided onMove.
    return LongPressDraggable<int>(
      data: index,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _dragFeedback(),
      childWhenDragging: const SizedBox.shrink(),
      onDragCompleted: () {},
      child: DragTarget<int>(
        // Only accept drops when not in selection mode and the dragged
        // index is different from this card's index.
        onWillAcceptWithDetails: (details) => !selectionMode && details.data != index,
        // When an item is dropped on this card, notify the parent
        // via `onMove(fromIndex, toIndex)` so it can update ordering.
        onAcceptWithDetails: (details) => onMove(details.data, index),
        builder: (context, candidateData, rejectedData) {
          return Card(
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
                        // Small pinned icon when note is pinned
                        if (note.pinned) const Icon(Icons.push_pin, size: 16),
                        Text(
                          note.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            note.content,
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                ],
              ),
            ),
          );
        },
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

