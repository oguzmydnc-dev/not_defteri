import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';

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

  // Toggle for asking before deleting notes
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
