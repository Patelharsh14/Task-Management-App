// ignore_for_file: file_names

import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

import '../models/preferences.dart';

class PreferencesNotifier extends StateNotifier<Preferences> {
  PreferencesNotifier() : super(Preferences(isDarkMode: false, sortOrder: 'date'));

  final Box<Preferences> _preferencesBox = Hive.box('preferences');

  // Load preferences from Hive storage
  // ignore: unused_element
  Future<void> _loadPreferences() async {
    if (_preferencesBox.isNotEmpty) {
      state = _preferencesBox.getAt(0) ?? state;
    }
  }

  // Toggle dark mode
  void toggleTheme() {
    state = Preferences(isDarkMode: !state.isDarkMode, sortOrder: state.sortOrder);
    _preferencesBox.putAt(0, state);
  }

  // Change task sorting order
  void setSortOrder(String order) {
    state = Preferences(isDarkMode: state.isDarkMode, sortOrder: order);
    _preferencesBox.putAt(0, state);
  }

  // Reset preferences to default values
  void resetPreferences() {
    state = Preferences(isDarkMode: false, sortOrder: 'date');  // Default values
    _preferencesBox.putAt(0, state);  // Update Hive storage with default preferences
  }
}
