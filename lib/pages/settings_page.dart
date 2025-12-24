import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/settings_provider.dart';
import '../services/hive_service.dart';
import '../providers/note_provider.dart';

// pages/settings_page.dart
// Simple settings screen exposing application-level toggles.
//
// Currently provides:
// - Ask before deleting notes (persisted via SettingsProvider)
//
// Keep this page minimal and focused. Additional settings can be
// appended as new list tiles with the same pattern.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  

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
          _buildThemeTile(settings),
          const Divider(),
          _buildFontTiles(settings),
          const Divider(),
          _buildLocaleTile(settings),
          const Divider(),
          _buildBackgroundTile(settings, context),
          const Divider(),
          _buildStorageTile(settings, context),
          const Divider(),
          _buildViewModeTile(settings),
          const Divider(),
          _buildAskBeforeDeleteTile(settings),
        ],
      ),
    );
  }

  Future<void> _showPreviewDialog(String path) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        Widget preview;
        if (path.startsWith('http://') || path.startsWith('https://')) {
          preview = Image.network(
            path,
            fit: BoxFit.cover,
            loadingBuilder: (c, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
            errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 48)),
          );
        } else {
          preview = Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 48)),
          );
        }

        return AlertDialog(
          title: const Text('Preview background'),
          content: SizedBox(width: 300, height: 180, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: preview)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                await context.read<SettingsProvider>().setBackgroundImage(path);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeTile(SettingsProvider settings) {
    return ListTile(
      title: const Text('Theme'),
      subtitle: Text(settings.theme.name),
      trailing: DropdownButton<ThemeOption>(
        value: settings.theme,
        items: ThemeOption.values
            .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
            .toList(),
        onChanged: (v) {
          if (v != null) settings.setTheme(v);
        },
      ),
    );
  }

  Widget _buildFontTiles(SettingsProvider settings) {
    final fonts = ['Roboto', 'OpenSans', 'Merriweather'];
    return Column(
      children: [
        ListTile(
          title: const Text('Title font'),
          trailing: DropdownButton<String>(
            value: settings.titleFont,
            items: fonts.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (v) => v != null ? settings.setTitleFont(v) : null,
          ),
        ),
        ListTile(
          title: const Text('Content font'),
          trailing: DropdownButton<String>(
            value: settings.contentFont,
            items: fonts.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (v) => v != null ? settings.setContentFont(v) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLocaleTile(SettingsProvider settings) {
    final locales = {'en': 'English', 'tr': 'Türkçe'};
    return ListTile(
      title: const Text('Language'),
      trailing: DropdownButton<String>(
        value: settings.locale,
        items: locales.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
        onChanged: (v) => v != null ? settings.setLocale(v) : null,
      ),
    );
  }

  Widget _buildBackgroundTile(SettingsProvider settings, BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Background'),
          subtitle: Text(settings.backgroundType == 'default' ? 'Grid (default)' : (settings.backgroundPath ?? 'Custom image')),
          trailing: ElevatedButton(
            onPressed: () async {
              // Offer both gallery picker and manual path entry.
              final picker = ImagePicker();
              final pick = await showModalBottomSheet<String?>(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Pick from gallery'),
                        onTap: () async {
                          Navigator.pop(context, 'gallery');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: const Text('Enter URL or path'),
                        onTap: () => Navigator.pop(context, 'manual'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.close),
                        title: const Text('Cancel'),
                        onTap: () => Navigator.pop(context, null),
                      ),
                    ],
                  ),
                ),
              );

              if (pick == null) return;
              if (pick == 'gallery') {
                try {
                  final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (file == null) return;
                  await _showPreviewDialog(file.path);
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
                }
              } else if (pick == 'camera') {
                if (kIsWeb) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera not supported on web')));
                } else {
                  try {
                    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                    if (file == null) return;
                    await _showPreviewDialog(file.path);
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to capture image')));
                  }
                }
              } else if (pick == 'manual') {
                final controller = TextEditingController(text: settings.backgroundPath ?? '');
                final result = await showDialog<String?>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Set background image path or URL'),
                    content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Enter image path or URL')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Preview')),
                    ],
                  ),
                );
                if (result == null || result.isEmpty) return;

                final trimmed = result.trim();
                // Basic validation: accept http/https URLs or existing local files (non-web).
                if (trimmed.startsWith('http://') || trimmed.startsWith('https://') || (!kIsWeb && File(trimmed).existsSync())) {
                  await _showPreviewDialog(trimmed);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid path or URL')));
                }
              }
            },
            child: const Text('Choose'),
          ),
        ),
        TextButton(onPressed: () => settings.setBackgroundToDefault(), child: const Text('Use default background')),
      ],
    );
  }

  Widget _buildViewModeTile(SettingsProvider settings) {
    return ListTile(
      title: const Text('Note view'),
      subtitle: Text(settings.viewMode.name),
      trailing: DropdownButton<ViewMode>(
        value: settings.viewMode,
        items: ViewMode.values.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(),
        onChanged: (v) {
          if (v != null) settings.setViewMode(v);
        },
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

  Widget _buildStorageTile(SettingsProvider settings, BuildContext context) {
    return ListTile(
      title: const Text('Storage'),
      subtitle: Text(settings.useHive ? 'Hive' : 'SharedPreferences'),
      trailing: Switch(
        value: settings.useHive,
        onChanged: (v) async {
          if (v) {
            // enable Hive: migrate and switch provider storage
            final hive = HiveService();
            try {
              await hive.init();
              await hive.migrateFromSharedPrefs();
              await context.read<NoteProvider>().replaceStorage(hive, migrate: false);
              await settings.setUseHive(true);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Migrated to Hive storage')));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Migration failed')));
            }
          } else {
            // switch back to SharedPreferences
            await context.read<NoteProvider>().replaceStorage(getDefaultNoteStorage());
            await settings.setUseHive(false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Using SharedPreferences')));
          }
        },
      ),
    );
  }
}
