import 'package:flutter/material.dart';

import '../../shared/utils/theme_extensions.dart';

part 'app_colors.dart';
part 'app_text.dart';

class AppTheme {
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
    appBarTheme: const AppBarTheme(centerTitle: true),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary300, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(color: AppColors.darkPrimary300),
      alignLabelWithHint: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightAvatar100,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.darkPrimary300, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        foregroundColor: AppColors.darkPrimary300,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.darkText100,
      unselectedLabelColor: AppColors.darkText200,
      tabAlignment: TabAlignment.fill,
      labelPadding: const EdgeInsets.all(8),
      indicatorColor: AppColors.darkBg200,
      indicator: BoxDecoration(
        color: AppColors.darkBg200,
        borderRadius: BorderRadius.circular(100),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelStyle: _darkTheme.textTheme.titleLarge,
      unselectedLabelStyle: _darkTheme.textTheme.titleLarge,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateColor.resolveWith((states) {
        return AppColors.darkAvatar100;
      }),
      visualDensity: VisualDensity.compact,
    ),
    datePickerTheme: DatePickerThemeData(
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: AppColors.darkAvatar100,
      ),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: AppColors.darkText200,
      ),
      todayForegroundColor: WidgetStateProperty.all(Colors.white),
      dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.darkAvatar100;
        }
        return null;
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return Colors.black;
        }
        return null;
      }),
    ),
  );
}
