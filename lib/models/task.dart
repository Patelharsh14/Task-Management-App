class Task {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int priority;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  // Convert a Task object to a Map object for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0, // SQLite stores booleans as integers
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
    };
  }

  // Create a Task object from a Map, handling null values
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? 0,  // Default to 0 if 'id' is null
      title: map['title'] ?? '',  // Default to empty string if 'title' is null
      description: map['description'] ?? '',  // Default to empty string if 'description' is null
      isCompleted: map['isCompleted'] == 1,  // Handle boolean conversion from 0 or 1
      dueDate: map['dueDate'] != null
          ? DateTime.tryParse(map['dueDate']) ?? DateTime.now()  // Default to current date if 'dueDate' is invalid or null
          : DateTime.now(),
      priority: map['priority'] ?? 0,  // Default to 0 if 'priority' is null
    );
  }

  // Helper method to get task status as string
  String get status {
    return isCompleted ? 'Completed' : 'Pending';
  }

  void toggleCompleted() {
    isCompleted = !isCompleted;
  }
}
