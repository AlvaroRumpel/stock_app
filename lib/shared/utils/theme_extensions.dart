import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  Brightness get brightness => Theme.of(this).brightness;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
