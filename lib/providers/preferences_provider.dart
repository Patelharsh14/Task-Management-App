// ignore_for_file: avoid_print

import 'package:riverpod/riverpod.dart';
import '../models/preferences.dart';
import 'package:hive/hive.dart';

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, Preferences>((ref) {
  return PreferencesNotifier();
});

class PreferencesNotifier extends StateNotifier<Preferences> {
  PreferencesNotifier() : super(Preferences(isDarkMode: false, sortOrder: 'date')) {
    _loadPreferences();
  }

  // Open Hive box for storing preferences
  final Box<Preferences> _preferencesBox = Hive.box<Preferences>('preferences');

  // Load preferences from Hive storage
  Future<void> _loadPreferences() async {
    try {
      if (_preferencesBox.isNotEmpty) {
        final prefs = _preferencesBox.getAt(0);
        if (prefs != null) {
          state = prefs; // Load stored preferences if they exist
        }
      }
    } catch (e) {
      print("Error loading preferences: $e");
    }
  }

  // Toggle dark mode
  void toggleTheme() {
    state = Preferences(isDarkMode: !state.isDarkMode, sortOrder: state.sortOrder);
    _savePreferences(state);  // Save updated preferences to Hive
  }

  // Change task sorting order
  void setSortOrder(String order) {
    state = Preferences(isDarkMode: state.isDarkMode, sortOrder: order);
    _savePreferences(state);  // Save updated preferences to Hive
  }

  // Save preferences to Hive
  Future<void> _savePreferences(Preferences preferences) async {
    try {
      await _preferencesBox.putAt(0, preferences);  // Store the preferences at index 0
    } catch (e) {
      print("Error saving preferences: $e");
    }
  }
}
