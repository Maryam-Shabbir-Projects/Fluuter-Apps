import 'package:flutter/material.dart';
import '../models/subtask.dart';

typedef OnSubTaskChanged = void Function(int index, String value);
typedef OnSubTaskRemoved = void Function(int index);

class SubTaskList extends StatelessWidget {
  final List<SubTask> subTasks;
  final OnSubTaskChanged onChanged;
  final OnSubTaskRemoved onRemove;

  const SubTaskList({
    super.key,
    required this.subTasks,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: subTasks.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final subtask = subTasks[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: subtask.title,
                  decoration: const InputDecoration(
                    labelText: 'Subtask',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => onChanged(index, val),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onRemove(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
