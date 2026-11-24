import 'package:material_ui/material_ui.dart';

/// Випадаючий список проєкту з підписом, іконкою і валідацією.
class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    this.value,
    this.onChanged,
    this.hint,
    this.icon,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final List<T> items;
  final String Function(T item) itemLabel;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final IconData? icon;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      validator: validator,
      onChanged: enabled ? onChanged : null,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
