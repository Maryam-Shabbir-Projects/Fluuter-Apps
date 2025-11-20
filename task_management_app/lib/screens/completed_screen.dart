import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';  // Ensure this import is correct
import '../models/task.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  late TaskProvider _taskProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _taskProvider.loadCompletedTasks(context);
  }

  Future<void> _showDeleteDialog(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && task.id != null) {
      await _taskProvider.deleteTask(task.id!, task.title, context);
      await _taskProvider.loadCompletedTasks(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        if (provider.tasks.isEmpty) {
          return const Center(child: Text('No completed tasks.'));
        }
        return ListView.builder(
          itemCount: provider.tasks.length,
          itemBuilder: (context, index) {
            final task = provider.tasks[index];
            return TaskCard(
              task: task,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
                );
                await provider.loadCompletedTasks(context);
              },
              onLongPress: () => _showDeleteDialog(task),
            );
          },
        );
      },
    );
  }
}
