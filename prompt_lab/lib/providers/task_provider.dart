import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/task.dart';

/// Фільтр списку завдань.
enum TaskFilter { all, active, done }

/// Стан списку завдань.
class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;

  TaskFilter get filter => _filter;

  UnmodifiableListView<Task> get tasks {
    final filtered = switch (_filter) {
      TaskFilter.all => _tasks,
      TaskFilter.active => _tasks.where((t) => !t.isDone),
      TaskFilter.done => _tasks.where((t) => t.isDone),
    };
    return UnmodifiableListView(filtered.toList());
  }

  int get totalCount => _tasks.length;
  int get doneCount => _tasks.where((t) => t.isDone).length;

  /// Додає завдання. Порожню назву не приймає.
  void addTask(String title, {TaskPriority priority = TaskPriority.medium}) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Назва завдання не може бути порожньою');
    }
    _tasks.insert(0, Task(title: trimmed, priority: priority));
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
    notifyListeners();
  }

  void removeTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }
}
