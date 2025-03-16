import 'package:flutter/material.dart';

import '../../shared/utils/theme_extensions.dart';

part 'app_colors.dart';
part 'app_text.dart';

class AppTheme {
  // ignore: unused_field
  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary100,
    scaffoldBackgroundColor: AppColors.lightBg100,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary100,
      secondary: AppColors.lightAccent100,
      surface: AppColors.lightBg100,
      onSurface: AppColors.lightText100,
    ),
  );

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary100,
    scaffoldBackgroundColor: AppColors.darkBg100,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary100,
      secondary: AppColors.darkAccent100,
      surface: AppColors.darkBg100,
      onSurface: AppColors.darkText100,
    ),
  );

  static final theme = _darkTheme.copyWith(
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkBg100,
      indicatorColor: AppColors.darkPrimary200,
      elevation: 2,
      iconTheme: const WidgetStatePropertyAll<IconThemeData>(
        IconThemeData(color: AppColors.darkPrimary300),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((state) {
        if (state.contains(WidgetState.selected)) {
          return const TextStyle(color: AppColors.darkText200);
        }

        return const TextStyle(color: AppColors.darkPrimary300);
      }),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
