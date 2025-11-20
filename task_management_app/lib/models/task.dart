import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'subtask.dart';

enum RepeatType { none, daily, weekly, monthly }

class Task {
  int? id;
  String title;
  String description;
  DateTime date; // date to perform task
  TimeOfDay time; // time to perform task
  bool isCompleted;
  bool isExpired; // Track if task is expired
  RepeatType repeatType;
  List<int> repeatDays; // For weekly repeat, list of weekday ints (1=Mon,7=Sun)
  List<SubTask> subTasks;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.isCompleted = false,
    this.isExpired = false,
    this.repeatType = RepeatType.none,
    this.repeatDays = const [],
    this.subTasks = const [],
  });

  /// Combines date + time into one DateTime representing task's exact due moment
  DateTime get dueDateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'isCompleted': isCompleted ? 1 : 0,
      'isExpired': isExpired ? 1 : 0,
      'repeatType': describeEnum(repeatType),
      'repeatDays': repeatDays.join(','),
      // TODO: Add subTasks serialization if needed
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String).split(':');
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      isCompleted: map['isCompleted'] == 1,
      isExpired: map['isExpired'] == 1,
      repeatType: RepeatType.values.firstWhere(
            (e) => describeEnum(e) == map['repeatType'],
        orElse: () => RepeatType.none,
      ),
      repeatDays: map['repeatDays'] != null && map['repeatDays'] != ''
          ? (map['repeatDays'] as String).split(',').map(int.parse).toList()
          : [],
      // TODO: Add subTasks deserialization if needed
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Task &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
