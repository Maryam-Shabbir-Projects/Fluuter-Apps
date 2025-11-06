class Task {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  bool repeat;
  List<String> repeatDays;
  double progress; // value between 0 and 1 for progress tracking

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.repeat = false,
    this.repeatDays = const [],
    this.progress = 0.0,
  });

  // Convert Task object to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'repeat': repeat ? 1 : 0,
      'repeatDays': repeatDays.join(','),
      'progress': progress,
    };
  }

  // Create Task object from database Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
      repeat: map['repeat'] == 1,
      repeatDays: map['repeatDays'] != null && map['repeatDays'].toString().isNotEmpty
          ? map['repeatDays'].toString().split(',')
          : [],
      progress: (map['progress'] ?? 0.0).toDouble(),
    );
  }
}
