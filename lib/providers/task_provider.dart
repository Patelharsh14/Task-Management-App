import 'package:riverpod/riverpod.dart';
import 'package:task/providers/preferences_provider.dart';
import '../models/task.dart';
import '../database/task_database.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final taskDatabase = TaskDatabase();
  return TaskNotifier(taskDatabase, ref);
});

class TaskNotifier extends StateNotifier<List<Task>> {
  final TaskDatabase _taskDatabase;
  final Ref _ref;

  TaskNotifier(this._taskDatabase, this._ref) : super([]) {
    _initializeDatabase();
  }

  // Initialize the database
  Future<void> _initializeDatabase() async {
    try {
      await _taskDatabase.init();  // Ensure the database is initialized once
    } catch (e) {
      throw Exception("Failed to initialize the database: $e");
    }
  }

  // Fetch all tasks from the database and sort them based on user preferences
  Future<void> fetchTasks({String? statusFilter}) async {
    try {
      List<Task> tasks = await _taskDatabase.getTasks();

      // Filter tasks based on completion status if a filter is provided
      if (statusFilter != null) {
        if (statusFilter == 'Completed') {
          tasks = tasks.where((task) => task.isCompleted).toList();
        } else if (statusFilter == 'Pending') {
          tasks = tasks.where((task) => !task.isCompleted).toList();
        }
      }

      // Retrieve the sorting preference from Hive or other storage
      final preferences = _ref.read(preferencesProvider); // Assuming a preferences provider exists for user settings
      if (preferences.sortOrder == 'priority') {
        tasks.sort((a, b) => b.priority.compareTo(a.priority));  // Sort by priority
      } else if (preferences.sortOrder == 'date') {
        tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));  // Sort by due date
      }

      state = tasks;
    } catch (e) {
      throw Exception("Failed to fetch tasks: $e");
    }
  }

  // Add a new task to the database
  Future<void> addTask(Task task) async {
    try {
      await _taskDatabase.insertTask(task);
      state = [...state, task];
    } catch (e) {
      throw Exception("Failed to add task: $e");
    }
  }

  // Update an existing task in the database
  Future<void> updateTask(Task task) async {
    try {
      await _taskDatabase.updateTask(task);
      state = state.map((e) => e.id == task.id ? task : e).toList();
    } catch (e) {
      throw Exception("Failed to update task: $e");
    }
  }

  // Toggle the completion status of a task
  Future<void> toggleCompletionStatus(int taskId) async {
    try {
      await _taskDatabase.toggleCompletionStatus(taskId);
      await fetchTasks(); // Reload tasks after status change
    } catch (e) {
      throw Exception("Failed to toggle completion status: $e");
    }
  }

  // Delete a task from the database
  Future<void> deleteTask(int id) async {
    try {
      await _taskDatabase.deleteTask(id);
      state = state.where((e) => e.id != id).toList();
    } catch (e) {
      throw Exception("Failed to delete task: $e");
    }
  }
}
