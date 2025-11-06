import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/db_service.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  final DBService _dbService = DBService(); // ✅ Instance of DBService

  /// Get read-only list of tasks
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Load all tasks from SQLite
  Future<void> loadTasks() async {
    try {
      final data = await _dbService.getTasks(); // ✅ instance call
      _tasks
        ..clear()
        ..addAll(data);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading tasks: $e');
    }
  }

  /// Add new task
  Future<void> addTask(Task task) async {
    try {
      await _dbService.insertTask(task);
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error adding task: $e');
    }
  }

  /// Update existing task
  Future<void> updateTask(Task task) async {
    try {
      await _dbService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error updating task: $e');
    }
  }

  /// Delete a task (by integer ID)
  Future<void> deleteTask(int id) async {
    try {
      await _dbService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error deleting task: $e');
    }
  }

  /// Toggle completed/uncompleted state
  Future<void> toggleCompleted(Task task) async {
    try {
      task.isCompleted = !task.isCompleted;
      await _dbService.updateTask(task);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error toggling completion: $e');
    }
  }

  /// Explicitly mark a task as completed by ID
  Future<void> markTaskCompleted(int id) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index].isCompleted = true;
        await _dbService.updateTask(_tasks[index]);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error marking task completed: $e');
    }
  }
}
