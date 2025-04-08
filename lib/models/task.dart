class Task {
  String id;
  String name;
  bool isCompleted;
  Map<String, List<String>> subtasks;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    required this.subtasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((key, value) => MapEntry(key, value)),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    Map<String, List<String>> subtasksMap = {};
    
    if (map['subtasks'] != null) {
      (map['subtasks'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List) {
          subtasksMap[key] = List<String>.from(value);
        }
      });
    }

    return Task(
      id: map['id'],
      name: map['name'],
      isCompleted: map['isCompleted'] ?? false,
      subtasks: subtasksMap,
    );
  }
} 