// widgets/note_card.dart
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
    return LongPressDraggable<int>(
      data: index,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _dragFeedback(),
      childWhenDragging: const SizedBox.shrink(),
      onDragCompleted: () {},
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) => !selectionMode && details.data != index,
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

