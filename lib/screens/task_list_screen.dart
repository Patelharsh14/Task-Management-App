import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:task/screens/settings_screen.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/task_details_screen.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Task> _filteredTasks = [];
  String _filterStatus = 'All'; // 'All', 'Completed', 'Pending'
  String _sortOption = 'Due Date'; // 'Due Date', 'Priority', 'Title'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterTasks(_searchController.text);
    });
  }

  void _updateTaskStatus() {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    final tasks = ref.read(taskProvider.notifier).state;
    final now = DateTime.now();

    for (var task in tasks) {
      // Only mark the task as completed if it is not already completed
      if (!task.isCompleted && task.dueDate.isBefore(now)) {
        task.isCompleted = true;  // Set task as completed if due date is passed
      }
    }

    setState(() {});  // Trigger UI update after modifying the task list
  }

  // Filter tasks based on query and status
  void _filterTasks(String query) {
    final tasks = ref.read(taskProvider);
    setState(() {
      _filteredTasks = tasks.where((task) {
        final matchesQuery = task.title.toLowerCase().contains(query.toLowerCase()) ||
            (task.description.toLowerCase().contains(query.toLowerCase()));
        final matchesStatus = _filterStatus == 'All' ||
            (_filterStatus == 'Completed' && task.isCompleted) ||
            (_filterStatus == 'Pending' && !task.isCompleted);

        return matchesQuery && matchesStatus;
      }).toList();
      _sortTasks();
    });
  }

  // Sort tasks based on the selected option
  void _sortTasks() {
    _filteredTasks.sort((a, b) {
      switch (_sortOption) {
        case 'Due Date':
          return a.dueDate.compareTo(b.dueDate);
        case 'Priority':
          return b.priority.compareTo(a.priority); // Higher priority first
        case 'Title':
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        default:
          return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final tasksToDisplay = _searchController.text.isEmpty ? tasks : _filteredTasks;

    _updateTaskStatus(); // Update tasks before rendering

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskDetailsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterTasks('');
                      },
                    )
                        : null,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: _filterStatus,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value!;
                        _filterTasks(_searchController.text);
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: _sortOption,
                    items: const [
                      DropdownMenuItem(value: 'Due Date', child: Text('Sort by Due Date')),
                      DropdownMenuItem(value: 'Priority', child: Text('Sort by Priority')),
                      DropdownMenuItem(value: 'Title', child: Text('Sort by Title')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortOption = value!;
                        _sortTasks();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: tasksToDisplay.isEmpty
            ? const Center(child: Text('No tasks available'))
            : ListView.builder(
          itemCount: tasksToDisplay.length,
          itemBuilder: (context, index) {
            final task = tasksToDisplay[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: task.isCompleted ? Colors.green : Colors.black,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  'Due: ${task.dueDate.toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailsScreen(task: task),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await ref.read(taskProvider.notifier).deleteTask(task.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailsScreen(task: task),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
