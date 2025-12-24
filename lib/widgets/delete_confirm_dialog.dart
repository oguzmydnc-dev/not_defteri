import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Shows a delete confirmation dialog.
/// Returns true if user confirms, false otherwise.
Future<bool> showDeleteConfirmDialog(BuildContext context) async {
  final settings = context.read<SettingsProvider>();
  bool dontAskAgain = false;

  // If "askBeforeDelete" is false, skip the dialog
  if (!settings.askBeforeDelete) return true;

  return await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Not silinsin mi?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bu işlem geri alınamaz.'),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (_, setState) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: dontAskAgain,
                      onChanged: (v) => setState(() => dontAskAgain = v!),
                      title: const Text('Bunu bir daha sorma'),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () {
                  if (dontAskAgain) {
                    settings.setAskBeforeDelete(false);
                  }
                  Navigator.pop(ctx, true);
                },
                child: const Text(
                  'Sil',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      ) ??
      false;
}
