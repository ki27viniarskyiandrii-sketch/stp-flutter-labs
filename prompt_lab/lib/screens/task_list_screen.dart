import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

/// Екран "Список завдань".
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Список завдань'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${provider.doneCount}/${provider.totalCount}'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<TaskFilter>(
              segments: const [
                ButtonSegment(value: TaskFilter.all, label: Text('Усі')),
                ButtonSegment(value: TaskFilter.active, label: Text('Активні')),
                ButtonSegment(value: TaskFilter.done, label: Text('Виконані')),
              ],
              selected: {provider.filter},
              onSelectionChanged: (s) => provider.setFilter(s.first),
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('Завдань поки немає'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) =>
                        _TaskTile(task: tasks[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Додати'),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<(String, TaskPriority)>(
      context: context,
      builder: (_) => const _AddTaskDialog(),
    );
    if (result == null || !context.mounted) return;
    context.read<TaskProvider>().addTask(result.$1, priority: result.$2);
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final Task task;

  Color _priorityColor(ColorScheme scheme) => switch (task.priority) {
        TaskPriority.high => scheme.error,
        TaskPriority.medium => scheme.tertiary,
        TaskPriority.low => scheme.outline,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) => context.read<TaskProvider>().removeTask(task.id),
      child: CheckboxListTile(
        value: task.isDone,
        onChanged: (_) => context.read<TaskProvider>().toggleTask(task.id),
        title: Text(
          task.title,
          style: task.isDone
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text('Пріоритет: ${task.priority.label}'),
        secondary: Icon(Icons.flag, color: _priorityColor(scheme)),
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _controller = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = 'Введіть назву завдання');
      return;
    }
    Navigator.of(context).pop((_controller.text, _priority));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Нове завдання'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Назва',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          SegmentedButton<TaskPriority>(
            segments: [
              for (final p in TaskPriority.values)
                ButtonSegment(value: p, label: Text(p.label)),
            ],
            selected: {_priority},
            onSelectionChanged: (s) => setState(() => _priority = s.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        FilledButton(onPressed: _save, child: const Text('Зберегти')),
      ],
    );
  }
}
