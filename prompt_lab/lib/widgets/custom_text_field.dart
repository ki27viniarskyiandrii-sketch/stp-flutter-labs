import 'package:material_ui/material_ui.dart';

/// Поле вводу проєкту з підписом, іконкою і валідацією.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.enabled = true,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
