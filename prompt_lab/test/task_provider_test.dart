import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_lab/models/task.dart';
import 'package:prompt_lab/providers/task_provider.dart';

void main() {
  group('TaskProvider', () {
    late TaskProvider provider;

    setUp(() => provider = TaskProvider());

    test('додає завдання на початок списку і обрізає пробіли', () {
      provider.addTask('Перше');
      provider.addTask('  Друге  ', priority: TaskPriority.high);

      expect(provider.totalCount, 2);
      expect(provider.tasks.first.title, 'Друге');
      expect(provider.tasks.first.priority, TaskPriority.high);
    });

    test('порожню назву не приймає', () {
      expect(() => provider.addTask('   '), throwsArgumentError);
      expect(provider.totalCount, 0);
    });

    test('перемикає виконання і фільтрує', () {
      provider.addTask('A');
      provider.addTask('B');
      final id = provider.tasks.last.id; // A
      provider.toggleTask(id);

      expect(provider.doneCount, 1);
      provider.setFilter(TaskFilter.done);
      expect(provider.tasks.map((t) => t.title), ['A']);
      provider.setFilter(TaskFilter.active);
      expect(provider.tasks.map((t) => t.title), ['B']);
    });

    test('видаляє завдання і кожне має свій id', () {
      provider.addTask('A');
      provider.addTask('B');
      expect(provider.tasks[0].id, isNot(provider.tasks[1].id));

      provider.removeTask(provider.tasks.first.id);
      expect(provider.totalCount, 1);
    });

    test('повідомляє слухачів про зміни', () {
      var calls = 0;
      provider.addListener(() => calls++);
      provider.addTask('A');
      provider.toggleTask(provider.tasks.first.id);
      provider.setFilter(TaskFilter.done);
      expect(calls, 3);
    });
  });
}
