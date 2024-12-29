import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';

class TaskDetailsScreen extends ConsumerWidget {
  final Task? task;

  TaskDetailsScreen({super.key, this.task});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefill fields for existing task
    if (task != null) {
      titleController.text = task!.title;
      descriptionController.text = task!.description;
      dueDateController.text = DateFormat('yyyy-MM-dd').format(task!.dueDate);
      priorityController.text = task!.priority.toString();
    }

    // Validate and save the task
    void saveTask() {
      if (titleController.text.isEmpty || dueDateController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title and Due Date are required')),
        );
        return;
      }

      final int? priority = int.tryParse(priorityController.text);
      if (priority == null || priority < 1 || priority > 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Priority must be 1 (Low), 2 (Medium), or 3 (High)')),
        );
        return;
      }

      final DateTime? dueDate = DateTime.tryParse(dueDateController.text);
      if (dueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid date format. Use YYYY-MM-DD')),
        );
        return;
      }

      final newTask = Task(
        id: task?.id ?? DateTime.now().millisecondsSinceEpoch, // Unique ID for new task
        title: titleController.text,
        description: descriptionController.text,
        isCompleted: task?.isCompleted ?? false,
        priority: priority,
        dueDate: dueDate,
      );

      final taskNotifier = ref.read(taskProvider.notifier);
      if (task == null) {
        taskNotifier.addTask(newTask); // Add new task
      } else {
        taskNotifier.updateTask(newTask); // Update existing task
      }

      Navigator.pop(context);
    }

    // Reset the form fields
    void resetForm() {
      titleController.clear();
      descriptionController.clear();
      dueDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      priorityController.text = '2'; // Default to Medium priority
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(task == null ? 'New Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task == null ? 'Create a new task' : 'Edit task details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
                hintText: 'Enter task title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
                hintText: 'Enter task description',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dueDateController,
              decoration: const InputDecoration(
                labelText: 'Due Date',
                border: OutlineInputBorder(),
                hintText: 'Enter due date (YYYY-MM-DD)',
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: task?.dueDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  dueDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priorityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                hintText: 'Enter priority (1=Low, 2=Medium, 3=High)',
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: saveTask, // Save the task
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    task == null ? 'Add Task' : 'Update Task',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (task == null)
                  TextButton(
                    onPressed: resetForm,
                    child: const Text('Reset Form'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
