class Task {
  String id;
  String title;
  bool isCompleted;
  DateTime dateTime;
  List<SubTask> subTasks;
  String userId;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dateTime,
    this.subTasks = const [],
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dateTime': dateTime.toIso8601String(),
      'subTasks': subTasks.map((st) => st.toMap()).toList(),
      'userId': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'],
      dateTime: DateTime.parse(map['dateTime']),
      subTasks: (map['subTasks'] as List)
          .map((st) => SubTask.fromMap(st))
          .toList(),
      userId: map['userId'],
    );
  }
}

class SubTask {
  String id;
  String title;
  bool isCompleted;
  String timeSlot;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.timeSlot,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'timeSlot': timeSlot,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'],
      timeSlot: map['timeSlot'],
    );
  }
}