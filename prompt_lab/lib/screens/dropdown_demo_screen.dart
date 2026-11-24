import 'package:material_ui/material_ui.dart';

import '../models/task.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';

/// Форма, де разом працюють CustomTextField, CustomDropdown і CustomButton.
class DropdownDemoScreen extends StatefulWidget {
  const DropdownDemoScreen({super.key});

  @override
  State<DropdownDemoScreen> createState() => _DropdownDemoScreenState();
}

class _DropdownDemoScreenState extends State<DropdownDemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  TaskPriority? _priority;
  String? _result;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _result = '${_titleController.text.trim()}, пріоритет: ${_priority!.label}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Few-shot: CustomDropdown')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: 'Назва',
              icon: Icons.title,
              controller: _titleController,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введіть назву' : null,
            ),
            const SizedBox(height: 16),
            CustomDropdown<TaskPriority>(
              label: 'Пріоритет',
              icon: Icons.flag_outlined,
              hint: 'Оберіть пріоритет',
              items: TaskPriority.values,
              itemLabel: (p) => p.label,
              value: _priority,
              onChanged: (p) => setState(() => _priority = p),
              validator: (p) => p == null ? 'Оберіть пріоритет' : null,
            ),
            const SizedBox(height: 24),
            CustomButton(label: 'Зберегти', icon: Icons.save, onPressed: _save),
            if (_result != null) ...[
              const SizedBox(height: 16),
              Text('Збережено: $_result'),
            ],
          ],
        ),
      ),
    );
  }
}
