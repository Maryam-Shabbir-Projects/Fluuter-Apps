import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class RepeatedTasksScreen extends StatelessWidget {
  const RepeatedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repeated Tasks'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final repeatedTasks = provider.tasks.where((task) => task.repeat).toList();

          if (repeatedTasks.isEmpty) {
            return const Center(
              child: Text(
                'No repeated tasks found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: repeatedTasks.length,
            itemBuilder: (context, index) {
              return TaskTile(task: repeatedTasks[index]);
            },
          );
        },
      ),
    );
  }
}
