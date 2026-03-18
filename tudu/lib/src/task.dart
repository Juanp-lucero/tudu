class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueAt,
    required this.completed,
    required this.category,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? dueAt;
  final bool completed;
  final String? category;

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'].toString(),
      title: (map['title'] ?? '').toString(),
      description: map['description']?.toString(),
      dueAt: map['due_at'] == null ? null : DateTime.parse(map['due_at'].toString()),
      completed: map['completed'] == true,
      category: map['category']?.toString(),
    );
  }
}

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.description,
    required this.dueAt,
    required this.category,
  });

  final String title;
  final String? description;
  final DateTime? dueAt;
  final String? category;

  Map<String, Object?> toInsertMap() {
    return {
      'title': title,
      'description': description,
      'due_at': dueAt?.toIso8601String(),
      'completed': false,
      'category': category,
    };
  }
}
