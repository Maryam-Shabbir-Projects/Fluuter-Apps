import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final completedTasks =
          provider.tasks.where((task) => task.isCompleted).toList();

          if (completedTasks.isEmpty) {
            return const Center(
              child: Text(
                'No completed tasks yet.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              return TaskTile(task: completedTasks[index]);
            },
          );
        },
      ),
    );
  }
}
