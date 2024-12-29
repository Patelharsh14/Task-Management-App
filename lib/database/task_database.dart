// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import '../models/task.dart';

class TaskDatabase {
  Database? _database;

  // Initialize the database
  Future<void> init() async {
    if (_database != null) return; // Avoid re-initializing if already done
    try {
      _database = await openDatabase(
        join(await getDatabasesPath(), 'tasks.db'),
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, description TEXT, isCompleted INTEGER, dueDate TEXT, priority INTEGER)",
          );
        },
        version: 1,
      );
    } catch (e) {
      print("Error initializing database: $e");
      throw Exception("Failed to initialize the database: $e");
    }
  }

  // Helper method to get the database instance
  Future<Database> _getDatabase() async {
    if (_database == null) {
      await init(); // Ensure the database is initialized
    }
    return _database!;
  }

  // Insert a task into the database
  Future<void> insertTask(Task task) async {
    try {
      final db = await _getDatabase();
      await db.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting task: $e");
      throw Exception("Failed to insert task: $e");
    }
  }

  // Get all tasks from the database (with optional sorting)
  Future<List<Task>> getTasks({String? sortBy}) async {
    try {
      final db = await _getDatabase();
      String orderBy = 'id'; // Default sorting by id
      if (sortBy == 'date') {
        orderBy = 'dueDate';
      } else if (sortBy == 'priority') {
        orderBy = 'priority';
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        orderBy: orderBy,
      );

      return List.generate(maps.length, (i) {
        return Task(
          id: maps[i]['id'],
          title: maps[i]['title'] ?? '', // Default to empty string if null
          description: maps[i]['description'] ?? '', // Default to empty string if null
          isCompleted: maps[i]['isCompleted'] == 1,
          dueDate: maps[i]['dueDate'] != null ? DateTime.parse(maps[i]['dueDate']) : DateTime.now(), // Default to current date if null
          priority: maps[i]['priority'] ?? 0, // Default to 0 if null
        );
      });
    } catch (e) {
      print("Error fetching tasks: $e");
      throw Exception("Failed to fetch tasks: $e");
    }
  }

  // Get tasks by completion status (Pending or Completed)
  Future<List<Task>> getTasksByCompletionStatus(bool isCompleted) async {
    try {
      final db = await _getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'isCompleted = ?',
        whereArgs: [isCompleted ? 1 : 0],
      );

      return List.generate(maps.length, (i) {
        return Task(
          id: maps[i]['id'],
          title: maps[i]['title'] ?? '',
          description: maps[i]['description'] ?? '',
          isCompleted: maps[i]['isCompleted'] == 1,
          dueDate: maps[i]['dueDate'] != null ? DateTime.parse(maps[i]['dueDate']) : DateTime.now(),
          priority: maps[i]['priority'] ?? 0,
        );
      });
    } catch (e) {
      print("Error fetching tasks by completion status: $e");
      throw Exception("Failed to fetch tasks by completion status: $e");
    }
  }

  // Get Pending tasks (isCompleted == 0)
  Future<List<Task>> getPendingTasks() async {
    return await getTasksByCompletionStatus(false);
  }

  // Get Completed tasks (isCompleted == 1)
  Future<List<Task>> getCompletedTasks() async {
    return await getTasksByCompletionStatus(true);
  }

  // Update a task in the database
  Future<void> updateTask(Task task) async {
    try {
      final db = await _getDatabase();
      await db.update(
        'tasks',
        task.toMap(),
        where: "id = ?",
        whereArgs: [task.id],
      );
    } catch (e) {
      print("Error updating task: $e");
      throw Exception("Failed to update task: $e");
    }
  }

  // Toggle the 'isCompleted' status of a task
  Future<void> toggleCompletionStatus(int taskId) async {
    try {
      final db = await _getDatabase();
      await db.rawUpdate(
        'UPDATE tasks SET isCompleted = CASE WHEN isCompleted = 1 THEN 0 ELSE 1 END WHERE id = ?',
        [taskId],
      );
    } catch (e) {
      print("Error toggling completion status: $e");
      throw Exception("Failed to toggle task completion status: $e");
    }
  }

  // Delete a task from the database
  Future<void> deleteTask(int id) async {
    try {
      final db = await _getDatabase();
      await db.delete(
        'tasks',
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (e) {
      print("Error deleting task: $e");
      throw Exception("Failed to delete task: $e");
    }
  }
}
