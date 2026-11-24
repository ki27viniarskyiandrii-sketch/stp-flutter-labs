import 'package:uuid/uuid.dart';

/// Пріоритет завдання.
enum TaskPriority {
  low('Низький'),
  medium('Середній'),
  high('Високий');

  const TaskPriority(this.label);

  final String label;
}

/// Завдання у списку ToDo.
class Task {
  Task({
    String? id,
    required this.title,
    this.priority = TaskPriority.medium,
    this.isDone = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final TaskPriority priority;
  final bool isDone;
  final DateTime createdAt;

  Task copyWith({String? title, TaskPriority? priority, bool? isDone}) {
    return Task(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }
}
