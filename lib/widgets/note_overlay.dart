// widgets/not_overlay.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/note.dart';
import 'note_action_button.dart';
import '../providers/settings_provider.dart';

class NoteOverlay extends StatelessWidget {
  final Note note;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final void Function(String? folder)? onMoveToFolder;
  final VoidCallback? onArchive;
  final bool selectionMode;

  const NoteOverlay({
    super.key,
    required this.note,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
    this.onArchive,
    this.onMoveToFolder,
    this.selectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black45),
          ),
        ),
        Center(
          child: Card(
            color: Color(note.color),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _header(context),
                    const SizedBox(height: 12),
                    if (note.title.isNotEmpty)
                      Text(
                        note.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 8),
                    Text(note.content, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        NoteActionButton(
          icon: note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
          tooltip: 'Pin',
          onPressed: onTogglePin,
          disabled: selectionMode,
        ),
        NoteActionButton(
          icon: Icons.edit,
          tooltip: 'Edit',
          onPressed: onEdit,
          disabled: selectionMode,
        ),
        NoteActionButton(
          icon: Icons.delete,
          tooltip: 'Delete',
          onPressed: () async {
            final askBeforeDelete = context.read<SettingsProvider>().askBeforeDelete;

            bool confirmed = true;
            if (askBeforeDelete) {
              confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete note?'),
                      content: const Text('This action cannot be undone. Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ) ??
                  false;
            }

            if (confirmed && !selectionMode) onDelete();
          },
          color: Colors.red,
          disabled: selectionMode,
        ),
        NoteActionButton(
          icon: note.archived ? Icons.unarchive : Icons.archive,
          tooltip: note.archived ? 'Unarchive' : 'Archive',
          onPressed: () {
            if (selectionMode) return;
            if (onArchive != null) onArchive!();
          },
          disabled: selectionMode,
        ),
        NoteActionButton(
          icon: Icons.folder_open,
          tooltip: 'Move to folder',
          onPressed: () async {
            if (selectionMode) return;
            final controller = TextEditingController(text: note.folder ?? '');
            final result = await showDialog<String?>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Move to folder'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Folder name (leave empty to clear)'),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(context, ''), child: const Text('Clear')),
                  TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
                ],
              ),
            );

            if (result == null) return; // cancelled
            if (onMoveToFolder != null) onMoveToFolder!(result.isEmpty ? null : result);
          },
          disabled: selectionMode,
        ),
        NoteActionButton(
          icon: Icons.info_outline,
          tooltip: 'Details',
          onPressed: () {
            // Show metadata dialog
            showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Note Details'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Created: ${note.createdAt.toLocal()}'),
                    const SizedBox(height: 6),
                    Text('Updated: ${note.updatedAt.toLocal()}'),
                    const SizedBox(height: 8),
                    Text('ID: ${note.id}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ],
              ),
            );
          },
          disabled: selectionMode,
        ),
        NoteActionButton(
          icon: Icons.close,
          tooltip: 'Close',
          onPressed: onClose,
          disabled: false,
        ),
      ],
    );
  }
}
