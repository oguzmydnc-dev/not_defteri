// widgets/not_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/settings_provider.dart';

enum NoteDialogResultType { save, delete, cancel }

class NoteDialogResult {
  final NoteDialogResultType type;
  final Note? note;

  NoteDialogResult(this.type, [this.note]);
}

class NoteDialog extends StatefulWidget {
  final Note? note;

  const NoteDialog({super.key, this.note});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late TextEditingController titleCtrl;
  late TextEditingController contentCtrl;
  late bool pinned;
  late Color color;

  final colors = [
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    pinned = widget.note?.pinned ?? false;
    color = widget.note?.color ?? Colors.yellow;
  }

  @override
  Widget build(BuildContext context) {
    final askBeforeDelete =
        context.watch<SettingsProvider>().askBeforeDelete;

    return AlertDialog(
      title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(hintText: 'Content'),
              maxLines: null,
            ),
            Row(
              children: [
                const Icon(Icons.push_pin),
                Checkbox(
                  value: pinned,
                  onChanged: (v) => setState(() => pinned = v!),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: colors.map((r) {
                return GestureDetector(
                  onTap: () => setState(() => color = r),
                  child: CircleAvatar(
                    backgroundColor: r,
                    child: color == r
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        // Cancel
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              NoteDialogResult(NoteDialogResultType.cancel),
            );
          },
          child: const Text('Cancel'),
        ),

        // Delete only if editing existing note
        if (widget.note != null)
          TextButton(
            onPressed: () async {
              bool confirmed = true;

              if (askBeforeDelete) {
                confirmed = await _confirmDelete(context);
              }

              if (!context.mounted || !confirmed) return;

              Navigator.pop(
                context,
                NoteDialogResult(NoteDialogResultType.delete),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),

        // Save
        TextButton(
          onPressed: () {
            final title = titleCtrl.text.trim();
            final content = contentCtrl.text.trim();

            // Prevent saving empty note
            if (title.isEmpty || content.isEmpty) return;

            final newNote = widget.note == null
                ? Note.create(
                    title: title,
                    content: content,
                    color: color,
                    pinned: pinned,
                  )
                : widget.note!.copyWith(
                    title: title,
                    content: content,
                    color: color,
                    pinned: pinned,
                  );

            Navigator.pop(
              context,
              NoteDialogResult(NoteDialogResultType.save, newNote),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Note?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
