import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF00BFA5);
  static const Color primaryDark = Color(0xFF00897B);

  // Background colors
  static const Color backgroundLight = Color(0xFFF3F4F6);
  static const Color backgroundDark = Color(0xFF121212);

  // Card colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);

  // Text colors
  static const Color textLight = Colors.black87;
  static const Color textDark = Colors.white;

  // Accent colors
  static const Color errorColor = Colors.red;

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        error: errorColor,
        surface: cardLight,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textLight,
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        elevation: 8,
      ),
      dividerColor: Colors.black12,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        error: errorColor,
        surface: cardDark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        elevation: 8,
      ),
      dividerColor: Colors.white12,
    );
  }
}
