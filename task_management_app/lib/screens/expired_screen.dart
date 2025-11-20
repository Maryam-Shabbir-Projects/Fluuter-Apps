import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class ExpiredScreen extends StatefulWidget {
  const ExpiredScreen({super.key});

  @override
  State<ExpiredScreen> createState() => _ExpiredScreenState();
}

class _ExpiredScreenState extends State<ExpiredScreen> {
  late TaskProvider _taskProvider;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _taskProvider = Provider.of<TaskProvider>(context, listen: false);
      _taskProvider.loadExpiredTasks(context);
      _isInitialized = true;
    }
  }

  Future<void> _editTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen(task: task)),
    );
    await _taskProvider.loadExpiredTasks(context);
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true && task.id != null) {
      await _taskProvider.deleteTask(task.id!, task.title, context);
      await _taskProvider.loadExpiredTasks(context);
    }
  }

  Future<void> _refresh() async {
    await _taskProvider.loadExpiredTasks(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (provider.tasks.isEmpty) {
          return const Center(child: Text('No expired tasks.'));
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              return GestureDetector(
                onTap: () => _editTask(task),
                onLongPress: () => _deleteTask(task),
                child: TaskCard(task: task),
              );
            },
          ),
        );
      },
    );
  }
}
