import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

// pages/settings_page.dart
// Simple settings screen exposing application-level toggles.
//
// Currently provides:
// - Ask before deleting notes (persisted via SettingsProvider)
//
// Keep this page minimal and focused. Additional settings can be
// appended as new list tiles with the same pattern.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAskBeforeDeleteTile(settings),
        ],
      ),
    );
  }

  // Animated switch tile that toggles whether the app asks the user
  // for confirmation before deleting notes. The value is stored in
  // `SettingsProvider.setAskBeforeDelete` so it persists across sessions.
  Widget _buildAskBeforeDeleteTile(SettingsProvider settings) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: SwitchListTile(
        key: ValueKey(settings.askBeforeDelete),
        title: const Text('Ask before deleting notes'),
        value: settings.askBeforeDelete,
        onChanged: (value) => settings.setAskBeforeDelete(value),
      ),
    );
  }
}
