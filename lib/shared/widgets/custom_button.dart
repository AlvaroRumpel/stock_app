import 'package:flutter/material.dart';

import '../utils/context_extensions.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? _iconColor;
  final IconData? _icon;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    Color? iconColor,
    IconData? icon,
  }) : _type = _CustomButtonType.filled,
       _icon = icon,
       _iconColor = iconColor;

  const CustomButton.outlined({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    Color? iconColor,
    IconData? icon,
  }) : _type = _CustomButtonType.outlined,
       _icon = icon,
       _iconColor = iconColor;

  final _CustomButtonType _type;

  ButtonStyleButton get _button => switch (_type) {
    _CustomButtonType.filled => ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        iconColor: _iconColor,
      ),
      label: child,
      icon: _icon != null ? Icon(_icon) : null,
    ),
    _CustomButtonType.outlined => OutlinedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        iconColor: _iconColor,
      ),
      label: child,
      icon: _icon != null ? Icon(_icon) : null,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: context.width, child: _button);
  }
}

enum _CustomButtonType { filled, outlined }
