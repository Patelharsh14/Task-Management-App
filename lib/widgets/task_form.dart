import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskForm extends ConsumerWidget {
  final Task? task;

  TaskForm({super.key, this.task});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pre-fill fields if editing an existing task
    if (task != null) {
      titleController.text = task!.title;
      descriptionController.text = task!.description;
      dueDateController.text = task!.dueDate.toLocal().toString().split(' ')[0]; // Format the date
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(task == null ? 'Create Task' : 'Edit Task'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title Field
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
                hintText: 'Enter the task title',
              ),
            ),
            const SizedBox(height: 16),

            // Description Field
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
                hintText: 'Enter task description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Due Date Field
            TextField(
              controller: dueDateController,
              decoration: const InputDecoration(
                labelText: 'Due Date',
                border: OutlineInputBorder(),
                hintText: 'Select due date',
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
                  dueDateController.text = selectedDate.toLocal().toString().split(' ')[0];
                }
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty || descriptionController.text.isEmpty || dueDateController.text.isEmpty) {
                  // Validation check
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                  return;
                }

                // Create or update the task
                final newTask = Task(
                  id: task!.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  isCompleted: task?.isCompleted ?? false,
                  priority: 2, // Set default or provide UI for priority selection
                  dueDate: DateTime.parse(dueDateController.text),
                );

                final taskNotifier = ref.read(taskProvider.notifier); // Corrected to ref.read()
                if (task == null) {
                  taskNotifier.addTask(newTask);
                } else {
                  taskNotifier.updateTask(newTask);
                }

                Navigator.pop(context); // Close the form screen
              },
              // ignore: sort_child_properties_last
              child: Text(task == null ? 'Add Task' : 'Update Task'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                minimumSize: const Size(double.infinity, 48), // Full width button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
