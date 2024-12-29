import 'package:flutter/material.dart';
import 'package:task/providers/preferences_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:task/screens/settings_screen.dart';
import 'package:task/screens/task_details_screen.dart';
import 'screens/task_list_screen.dart';
import 'models/preferences.dart';
import 'database/task_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive box for preferences
  await Hive.openBox<Preferences>('preferences'); // Open Hive box for preferences

  // Initialize the task database
  final db = TaskDatabase();
  await db.init();

  // Run the app with Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);

    return MaterialApp(
      title: 'Task Management App',
      theme: preferences.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: const TaskListScreen(),
      routes: {
     //   '/': (context) => const TaskListScreen(),
        '/taskDetails': (context) => TaskDetailsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      // Optional: Add localization support if needed
      // locale: Locale('en', 'US'), // Example: for English (US)
      // supportedLocales: [
      //   Locale('en', 'US'),
      //   Locale('es', 'ES'),
      // ],
      // localizationsDelegates: [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      // ],
    );
  }
}
