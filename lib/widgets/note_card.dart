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
    // Use LongPressDraggable to allow reordering notes by long-pressing
    // the card. While dragging we show a lightweight feedback Card and
    // use a DragTarget to accept drops and call the provided onMove.
    //
    // Drag/drop notes behavior summary:
    // - Drag starts on long press (LongPressDraggable). The draggable
    //   `data` payload is the `index` so the parent can identify which
    //   item moved.
    // - While dragging, the original card is hidden (`childWhenDragging`).
    // - Drop targets are implemented by wrapping the child in a
    //   `DragTarget<int>` that accepts drops and calls `onMove(from,to)`.
    // - This pattern keeps existing reordering logic intact and works
    //   the same when `isMini` is true.
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
                  // Main content area. If `isMini` is true we intentionally
                  // hide all textual elements (title, content) and instead
                  // render a compact color preview. This keeps the layout
                  // stable while conveying a compact preview of the note.
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: isMini
                        ? SizedBox(
                            height: 48,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Pinned icon still visible in mini mode to
                                // indicate important notes.
                                if (note.pinned) const Icon(Icons.push_pin, size: 14),
                                // Spacer color block to visually represent
                                // the note color in compact form.
                                const SizedBox(width: 8),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: note.color,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Drag handle: clearly indicates the card is
                                // draggable in mini state. We show a small
                                // handle icon and slightly increase opacity on hover
                                // when supported by the platform.
                                const Icon(Icons.drag_handle, size: 18, color: Colors.white70),
                              ],
                            ),
                          )
                        : Column(
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
                  // Visual affordance for draggable state. When not in
                  // mini mode we don't show an explicit drag handle because
                  // the card shows content; in mini mode the small handle
                  // above acts as the affordance. Add a subtle overlay
                  // when the card is a candidate drop target.
                  if (candidateData.isNotEmpty)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.6), width: 2),
                        ),
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

