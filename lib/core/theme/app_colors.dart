part of 'app_theme.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightPrimary100 = Color(0xFFFF6600);
  static const Color lightPrimary200 = Color(0xFFFF983F);
  static const Color lightPrimary300 = Color(0xFFFFFFA1);
  static const Color lightAccent100 = Color(0xFFF5F5F5);
  static const Color lightAccent200 = Color(0xFF929292);
  static const Color lightText100 = Color(0xFFFFFFFF);
  static const Color lightText200 = Color(0xFFE0E0E0);
  static const Color lightBg100 = Color(0xFF1D1F21);
  static const Color lightBg200 = Color(0xFF2C2E30);
  static const Color lightBg300 = Color(0xFF444648);

  // Dark Theme Colors
  static const Color darkPrimary100 = Color(0xFF2C3A4F);
  static const Color darkPrimary200 = Color(0xFF56647B);
  static const Color darkPrimary300 = Color(0xFFB4C2DC);
  static const Color darkAccent100 = Color(0xFFFF4D4D);
  static const Color darkAccent200 = Color(0xFFFFECDA);
  static const Color darkText100 = Color(0xFFFFFFFF);
  static const Color darkText200 = Color(0xFFE0E0E0);
  static const Color darkBg100 = Color(0xFF1A1F2B);
  static const Color darkBg200 = Color(0xFF292E3B);
  static const Color darkBg300 = Color(0xFF414654);

  /// Method to get color based on theme mode
  static Color getColor(
    BuildContext context,
    Color lightColor,
    Color darkColor,
  ) {
    return context.brightness == Brightness.dark ? darkColor : lightColor;
  }
}
