import 'package:flutter/material.dart';

/// Every colour used in Orbit, taken from the Figma design.
/// Keeping them in one place makes the whole app look consistent.
class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF111B38); // dark navy: headings, project banner
  static const Color blue = Color(0xFF3563E9); // primary buttons and active tab
  static const Color surface = Color(0xFFF2F5FC); // light blue-grey cards and fields
  static const Color border = Color(0xFFE3E8F2);
  static const Color muted = Color(0xFF6B7488); // secondary text
  static const Color danger = Color(0xFFD64545); // "Needs attention" label

  // Pastel card colours from the Figma file.
  static const Color lavender = Color(0xFFECE6FB);
  static const Color sky = Color(0xFFE2EBFD);
  static const Color mint = Color(0xFFDDF4F3);
  static const Color peach = Color(0xFFFFEFD9);
  static const Color pink = Color(0xFFFDE7E7);
  static const Color green = Color(0xFFDDF3E4);

  static const List<Color> pastels = [lavender, sky, mint, peach, pink, green];

  /// Picks a pastel colour by position, so lists get a friendly colour rhythm.
  static Color pastel(int index) => pastels[index % pastels.length];
}

/// The one [ThemeData] used by the whole app (colours, text styles, buttons).
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        primary: AppColors.blue,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: AppColors.ink,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          height: 1.15,
          color: AppColors.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: AppColors.ink),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: AppColors.ink),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.muted),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.muted,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

/// Shared look for every text field in the app.
InputDecoration orbitInputDecoration({
  required String hint,
  IconData? prefixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 20, color: AppColors.muted),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}
