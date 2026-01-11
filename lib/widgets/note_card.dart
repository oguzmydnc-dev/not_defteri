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
import '../domain/models/note.dart';


/// A pure presentational widget that displays a single Note as a card.
///
/// This widget contains NO business or state logic. All state and callbacks
/// must be provided by the parent. It is fully reusable and only renders UI.
///
/// Parameters:
///   - [note]: The note to display (required)
///   - [index]: The index of the note in the list/grid (required)
///   - [onEdit]: Called when the card is tapped in non-selection mode
///   - [onMove]: Called when the card is reordered (drag & drop)
///   - [selectionMode]: If true, shows selection UI and toggles selection on tap
///   - [isSelected]: If true, shows the card as selected
///   - [onSelectToggle]: Called when selection is toggled
///   - [isMini]: If true, renders a compact preview (for gallery/grid)
class NoteCard extends StatelessWidget {
  final Note note;
  final int index;
  final VoidCallback onEdit;
  final void Function(int from, int to) onMove;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onSelectToggle;
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
    // Animated card for smooth UI transitions
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: Card(
        color: Color(note.color), // ARGB int to Color
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
                    // Show pin icon if note is pinned
                    if (note.pinned) const Icon(Icons.push_pin, size: 16),
                    // Title (compact in mini mode)
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
                    // Content preview (shorter in mini mode)
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
              // Selection indicator (only in selection mode)
              if (selectionMode)
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: Colors.white,
                  ),
                ),
              // Drag handle (mini mode only)
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

}

