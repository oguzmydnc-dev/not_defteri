// This widget currently has no hardcoded text. If you add any UI text, use:
//   LanguageManager.instance.t(LangKey.key)
// for localization.
import 'package:flutter/material.dart';
import '../domain/models/note.dart';

/// Animated preview widget for dragging notes.
/// Supports single and multiple selection.
class AnimatedNotePreview extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final bool selectionMode;

  const AnimatedNotePreview({
    super.key,
    required this.note,
    required this.isSelected,
    required this.selectionMode,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      child: Card(
        color: Color(note.color),
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
              if (note.pinned)
                const Icon(Icons.push_pin, size: 16),
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
