import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'add_task_screen.dart';

class RepeatedScreen extends StatefulWidget {
  const RepeatedScreen({super.key});

  @override
  State<RepeatedScreen> createState() => _RepeatedScreenState();
}

class _RepeatedScreenState extends State<RepeatedScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).loadRepeatedTasks(context);
  }

  String _getRepeatInfo(Task task) {
    switch (task.repeatType) {
      case RepeatType.daily:
        return 'Repeats daily';
      case RepeatType.weekly:
        if (task.repeatDays.isEmpty) return 'Repeats weekly (no days selected)';
        final daysNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final selectedDays = task.repeatDays.map((d) => daysNames[d - 1]).join(', ');
        return 'Repeats weekly on: $selectedDays';
      case RepeatType.monthly:
        return 'Repeats monthly on day ${task.date.day}';
      default:
        return 'No repeat';
    }
  }

  Future<void> _editTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen(task: task)),
    );
    Provider.of<TaskProvider>(context, listen: false).loadRepeatedTasks(context);
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
    if (confirmed == true) {
      await Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id!, task.title, context);
      Provider.of<TaskProvider>(context, listen: false).loadRepeatedTasks(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    if (provider.tasks.isEmpty) {
      return const Center(child: Text('No repeated tasks.'));
    }

    return ListView.builder(
      itemCount: provider.tasks.length,
      itemBuilder: (context, index) {
        final task = provider.tasks[index];
        return GestureDetector(
          onTap: () => _editTask(task),
          onLongPress: () => _deleteTask(task),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description.isNotEmpty) Text(task.description),
                  const SizedBox(height: 4),
                  Text(
                    _getRepeatInfo(task),
                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
