import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../db/database_helper.dart';
import '../models/task.dart';
import '../models/notification_item.dart';
import '../models/notification_type.dart';
import 'notification_provider.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = Uuid();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isDark = false;
  bool get isDarkMode => _isDark;

  // Track expired tasks that have already triggered notifications
  final Set<int> _notifiedExpiredTaskIds = {};

  void toggleDarkMode() {
    _isDark = !_isDark;
    notifyListeners();
  }

  /// Load only non-expired tasks for today
  Future<void> loadTasks(BuildContext context) async {
    await _db.markExpiredTasks();
    _tasks = await _db.getTasksByDateExcludeExpired(DateTime.now());
    notifyListeners();
    await checkForNewExpiredTasks(context);
  }

  /// Load only non-expired tasks (all dates)
  Future<void> loadAllTasks(BuildContext context) async {
    await _db.markExpiredTasks();
    _tasks = await _db.getAllTasksExcludeExpired();
    notifyListeners();
    await checkForNewExpiredTasks(context);
  }

  Future<void> loadCompletedTasks(BuildContext context) async {
    _tasks = await _db.getCompletedTasks();
    notifyListeners();
  }

  Future<void> loadExpiredTasks(BuildContext context) async {
    await _db.markExpiredTasks();
    _tasks = await _db.getExpiredTasks();
    notifyListeners();
  }

  Future<void> loadRepeatedTasks(BuildContext context) async {
    _tasks = await _db.getRepeatedTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task, BuildContext context) async {
    // Insert task in DB
    await _db.insertTask(task);
    await loadTasks(context);

    // Schedule reminder notification
    if (task.id != null) {
      await context.read<NotificationProvider>().scheduleTaskReminder(
        taskId: task.id.toString(),
        title: 'Reminder: ${task.title}',
        body: 'Your task "${task.title}" is coming up!',
        taskDueDateTime: DateTime(
          task.date.year,
          task.date.month,
          task.date.day,
          task.time.hour,
          task.time.minute,
        ),
        reminderBefore: const Duration(minutes: 10),
        repeatDaily: task.repeatType == RepeatType.daily,
      );
    }

    // Add in-app notification
    context.read<NotificationProvider>().addNotification(
      NotificationItem(
        id: _uuid.v4(),
        title: "Task Added",
        body: '"${task.title}" added.',
        dateTime: DateTime.now(),
        type: NotificationType.task,
        isRead: false,
      ),
    );

    await checkForNewExpiredTasks(context);
  }

  Future<void> updateTask(Task task, BuildContext context) async {
    await _db.updateTask(task);
    await loadTasks(context);

    final notificationProvider = context.read<NotificationProvider>();

    if (task.id != null) {
      // Cancel existing reminder to avoid duplicates
      await notificationProvider.cancelTaskReminder(task.id.toString());

      if (!task.isCompleted) {
        // Reschedule reminder if task not completed
        await notificationProvider.scheduleTaskReminder(
          taskId: task.id.toString(),
          title: 'Reminder: ${task.title}',
          body: 'Your task "${task.title}" is coming up!',
          taskDueDateTime: DateTime(
            task.date.year,
            task.date.month,
            task.date.day,
            task.time.hour,
            task.time.minute,
          ),
          reminderBefore: const Duration(minutes: 10),
          repeatDaily: task.repeatType == RepeatType.daily,
        );
      }
    }

    // Add relevant notification
    if (task.isCompleted) {
      notificationProvider.addNotification(
        NotificationItem(
          id: _uuid.v4(),
          title: "Task Completed",
          body: '"${task.title}" completed.',
          dateTime: DateTime.now(),
          type: NotificationType.task,
          isRead: false,
        ),
      );
    } else {
      notificationProvider.addNotification(
        NotificationItem(
          id: _uuid.v4(),
          title: "Task Updated",
          body: '"${task.title}" updated.',
          dateTime: DateTime.now(),
          type: NotificationType.task,
          isRead: false,
        ),
      );
    }

    await checkForNewExpiredTasks(context);
  }

  Future<void> deleteTask(int id, String title, BuildContext context) async {
    await _db.deleteTask(id);
    await loadTasks(context);

    // Cancel reminder notification when task is deleted
    await context.read<NotificationProvider>().cancelTaskReminder(id.toString());

    context.read<NotificationProvider>().addNotification(
      NotificationItem(
        id: _uuid.v4(),
        title: "Task Deleted",
        body: '"$title" deleted.',
        dateTime: DateTime.now(),
        type: NotificationType.system,
        isRead: false,
      ),
    );

    _notifiedExpiredTaskIds.remove(id);
  }

  /// Checks for newly expired tasks and sends notifications for them once.
  Future<void> checkForNewExpiredTasks(BuildContext context) async {
    await _db.markExpiredTasks();

    final expiredTasks = await _db.getExpiredTasks();
    final notificationProvider = context.read<NotificationProvider>();

    for (final task in expiredTasks) {
      if (task.id != null && !_notifiedExpiredTaskIds.contains(task.id)) {
        notificationProvider.addNotification(
          NotificationItem(
            id: _uuid.v4(),
            title: "Task Expired",
            body: 'The task "${task.title}" has expired.',
            dateTime: DateTime.now(),
            type: NotificationType.task,
            isRead: false,
          ),
        );
        _notifiedExpiredTaskIds.add(task.id!);
      }
    }
  }
}
