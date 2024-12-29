import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/preferences_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider); // Corrected to ref.watch()

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Theme Toggle
            ListTile(
              title: Text(
                'Theme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              trailing: Switch(
                value: preferences.isDarkMode,
                onChanged: (value) {
                  ref.read(preferencesProvider.notifier).toggleTheme(); // Corrected to ref.read()
                },
              ),
            ),
            const Divider(),
            // Sort Tasks By
            ListTile(
              title: Text(
                'Sort Tasks By',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(preferences.sortOrder == 'date' ? 'Date' : 'Priority'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Sort Tasks'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('By Date'),
                            onTap: () {
                              ref.read(preferencesProvider.notifier).setSortOrder('date');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('By Priority'),
                            onTap: () {
                              ref.read(preferencesProvider.notifier).setSortOrder('priority');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const Divider(),
            // Reset Settings Option
            ListTile(
              title: const Text('Reset to Default Settings'),
              leading: const Icon(Icons.restore),
              onTap: () {
                // Reset theme and sort order to defaults
                ref.read(preferencesProvider.notifier).resetPreferences();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to default')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension on PreferencesNotifier {
  void resetPreferences() {}
}
