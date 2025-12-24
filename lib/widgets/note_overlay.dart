// widgets/not_overlay.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import 'note_action_button.dart';
import '../providers/settings_provider.dart';

class NoteOverlay extends StatelessWidget {
  final Not not;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;

  const NoteOverlay({
    super.key,
    required this.not,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
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
            color: not.renk,
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
                    if (not.baslik.isNotEmpty)
                      Text(
                        not.baslik,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 8),
                    Text(not.icerik, style: const TextStyle(fontSize: 16)),
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
          icon: not.sabit ? Icons.push_pin : Icons.push_pin_outlined,
          tooltip: 'Pin',
          onPressed: onTogglePin,
        ),
        NoteActionButton(
          icon: Icons.edit,
          tooltip: 'Edit',
          onPressed: onEdit,
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

            if (confirmed) onDelete();
          },
          color: Colors.red,
        ),
        NoteActionButton(
          icon: Icons.close,
          tooltip: 'Close',
          onPressed: onClose,
        ),
      ],
    );
  }
}
