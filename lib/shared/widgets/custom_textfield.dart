import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/validation.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.validators,
    this.prefixIcon,
    this.inputFormatters,
    this.keyboardType,
    this.maxLines,
    this.onFieldSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final List<Validation>? validators;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final int? maxLines;
  final VoidCallback? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      validator: validators?.validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: inputFormatters,
      onFieldSubmitted: (String value) {
        onFieldSubmitted?.call();
      },
    );
  }
}
