import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;  // For platform check
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/subtask.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      // SQLite is NOT supported on Web!
      throw UnsupportedError('SQLite database is not supported on Web');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        isExpired INTEGER NOT NULL DEFAULT 0,
        repeatType TEXT NOT NULL,
        repeatDays TEXT,
        subTasks TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN isExpired INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    final id = await db.insert('tasks', _taskToMap(task));
    print('DatabaseHelper: Inserted task with id: $id');
    return id;
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update('tasks', _taskToMap(task), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks');
    return maps.map(_taskFromMap).toList();
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T').first;
    final maps = await db.query('tasks', where: 'date = ? AND isCompleted = 0', whereArgs: [dateStr]);
    return maps.map(_taskFromMap).toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    final db = await database;
    final maps = await db.query('tasks', where: 'isCompleted = 1');
    return maps.map(_taskFromMap).toList();
  }

  Future<List<Task>> getExpiredTasks() async {
    final db = await database;
    final maps = await db.query('tasks', where: 'isExpired = 1');
    return maps.map(_taskFromMap).toList();
  }

  Future<List<Task>> getRepeatedTasks() async {
    final db = await database;
    final maps = await db.query('tasks', where: "repeatType != 'none'");
    return maps.map(_taskFromMap).toList();
  }

  /// New: Get tasks by date excluding expired ones
  Future<List<Task>> getTasksByDateExcludeExpired(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T').first;
    final maps = await db.query(
      'tasks',
      where: 'date = ? AND isCompleted = 0 AND isExpired = 0',
      whereArgs: [dateStr],
    );
    return maps.map(_taskFromMap).toList();
  }

  /// New: Get all tasks excluding expired ones
  Future<List<Task>> getAllTasksExcludeExpired() async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'isExpired = 0',
    );
    return maps.map(_taskFromMap).toList();
  }

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'date': task.date.toIso8601String().split('T').first,
      'time': '${task.time.hour}:${task.time.minute}',
      'isCompleted': task.isCompleted ? 1 : 0,
      'isExpired': task.isExpired ? 1 : 0,
      'repeatType': task.repeatType.toString().split('.').last,
      'repeatDays': task.repeatDays.join(','),
      'subTasks': jsonEncode(task.subTasks
          .map((st) => {'title': st.title, 'isCompleted': st.isCompleted})
          .toList()),
    };
  }

  Task _taskFromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String).split(':');
    List<SubTask> subtasks = [];
    if (map['subTasks'] != null && (map['subTasks'] as String).isNotEmpty) {
      try {
        final decoded = jsonDecode(map['subTasks']);
        if (decoded is List) {
          subtasks = decoded
              .map<SubTask>((st) => SubTask(
              title: st['title'] ?? '', isCompleted: st['isCompleted'] ?? false))
              .toList();
        }
      } catch (_) {
        subtasks = [];
      }
    }

    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
          hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
      isCompleted: map['isCompleted'] == 1,
      isExpired: map['isExpired'] == 1,
      repeatType: RepeatType.values.firstWhere(
              (e) => e.toString().split('.').last == map['repeatType'],
          orElse: () => RepeatType.none),
      repeatDays: map['repeatDays'] != null && (map['repeatDays'] as String).isNotEmpty
          ? (map['repeatDays'] as String).split(',').map(int.parse).toList()
          : [],
      subTasks: subtasks,
    );
  }

  /// Mark tasks expired if their datetime is before now
  Future<void> markExpiredTasks() async {
    final db = await database;
    final now = DateTime.now();

    // Only update tasks that are not completed and not yet expired, but are past their due datetime
    final maps = await db.query(
      'tasks',
      where: 'isCompleted = 0 AND isExpired = 0',
    );

    for (final map in maps) {
      final task = _taskFromMap(map);

      final taskDateTime = DateTime(
        task.date.year,
        task.date.month,
        task.date.day,
        task.time.hour,
        task.time.minute,
      );

      if (taskDateTime.isBefore(now)) {
        await db.update('tasks', {'isExpired': 1}, where: 'id = ?', whereArgs: [task.id]);
      }
    }
  }
}
