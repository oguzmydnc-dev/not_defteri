import 'package:flutter/material.dart';
import '../models/note_model.dart';

/// Animated preview widget for dragging notes.
/// Supports single and multiple selection.
class AnimatedNotePreview extends StatelessWidget {
  final Not not;
  final bool isSelected;
  final bool selectionMode;

  const AnimatedNotePreview({
    super.key,
    required this.not,
    required this.isSelected,
    required this.selectionMode,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      child: Card(
        color: not.renk,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 160,
          height: 120,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (not.sabit)
                const Icon(Icons.push_pin, size: 16),
              Text(
                not.baslik,
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
                  not.icerik,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selectionMode)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
