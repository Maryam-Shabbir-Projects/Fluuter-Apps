import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class TodayTasksScreen extends StatelessWidget {
  const TodayTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Tasks'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final todayTasks = provider.tasks.where((task) {
            return task.dueDate.year == today.year &&
                task.dueDate.month == today.month &&
                task.dueDate.day == today.day;
          }).toList();

          if (todayTasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks due today.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: todayTasks.length,
            itemBuilder: (context, index) {
              return TaskTile(task: todayTasks[index]);
            },
          );
        },
      ),
    );
  }
}
