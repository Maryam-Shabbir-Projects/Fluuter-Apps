import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            const SizedBox(height: 4),
            Text(
              'Date: ${task.date.toLocal().toString().split(' ')[0]}, Time: ${task.time.format(context)}',
            ),
          ],
        ),
        trailing: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            // Create a new updated task instance manually
            final updatedTask = Task(
              id: task.id,
              title: task.title,
              description: task.description,
              date: task.date,
              time: task.time,
              isCompleted: value ?? false,
              repeatType: task.repeatType,
              repeatDays: task.repeatDays,
              subTasks: task.subTasks,
            );

            provider.updateTask(updatedTask, context);
          },
        ),
      ),
    );
  }
}
