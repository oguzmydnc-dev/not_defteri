// widgets/not_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/settings_provider.dart';

enum NotDialogResultType { save, delete, cancel }

class NotDialogResult {
  final NotDialogResultType type;
  final Not? not;

  NotDialogResult(this.type, [this.not]);
}

class NotDialog extends StatefulWidget {
  final Not? not;

  const NotDialog({super.key, this.not});

  @override
  State<NotDialog> createState() => _NotDialogState();
}

class _NotDialogState extends State<NotDialog> {
  late TextEditingController baslikCtrl;
  late TextEditingController icerikCtrl;
  late bool sabit;
  late Color renk;

  final renkler = [
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
    baslikCtrl = TextEditingController(text: widget.not?.baslik ?? '');
    icerikCtrl = TextEditingController(text: widget.not?.icerik ?? '');
    sabit = widget.not?.sabit ?? false;
    renk = widget.not?.renk ?? Colors.yellow;
  }

  @override
  Widget build(BuildContext context) {
    final askBeforeDelete =
        context.watch<SettingsProvider>().askBeforeDelete;

    return AlertDialog(
      title: Text(widget.not == null ? 'New Note' : 'Edit Note'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: baslikCtrl,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: icerikCtrl,
              decoration: const InputDecoration(hintText: 'Content'),
              maxLines: null,
            ),
            Row(
              children: [
                const Icon(Icons.push_pin),
                Checkbox(
                  value: sabit,
                  onChanged: (v) => setState(() => sabit = v!),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: renkler.map((r) {
                return GestureDetector(
                  onTap: () => setState(() => renk = r),
                  child: CircleAvatar(
                    backgroundColor: r,
                    child: renk == r
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
              NotDialogResult(NotDialogResultType.cancel),
            );
          },
          child: const Text('Cancel'),
        ),

        // Delete only if editing existing note
        if (widget.not != null)
          TextButton(
            onPressed: () async {
              bool confirmed = true;

              if (askBeforeDelete) {
                confirmed = await _confirmDelete(context);
              }

              if (!context.mounted || !confirmed) return;

              Navigator.pop(
                context,
                NotDialogResult(NotDialogResultType.delete),
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
            final title = baslikCtrl.text.trim();
            final content = icerikCtrl.text.trim();

            // Prevent saving empty note
            if (title.isEmpty || content.isEmpty) return;

            final newNote = widget.not == null
                ? Not.yeni(
                    baslik: title,
                    icerik: content,
                    renk: renk,
                    sabit: sabit,
                  )
                : widget.not!.copyWith(
                    baslik: title,
                    icerik: content,
                    renk: renk,
                    sabit: sabit,
                  );

            Navigator.pop(
              context,
              NotDialogResult(NotDialogResultType.save, newNote),
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
