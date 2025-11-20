import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final int maxLines;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.maxLines = 1,
    this.onSaved,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onSaved: onSaved,
      validator: validator,
    );
  }
}
