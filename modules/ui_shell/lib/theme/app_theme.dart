import 'package:flutter/material.dart';

/// The standard color palette for the App Factory.
/// Uses vibrant, premium colors to ensure a "WOW" factor.
class FactoryColors {
  // Vibrant Brand Colors
  static const Color primary = Color(0xFF6C63FF); // Deep modern purple
  static const Color secondary = Color(0xFF00BFA6); // Vibrant teal accent
  static const Color tertiary = Color(0xFFFF6584); // Soft playful pink

  // Neutral Colors (Dark Mode focused)
  static const Color backgroundDark = Color(0xFF1A1A2E); // Deep midnight blue
  static const Color surfaceDark = Color(0xFF16213E); // Slightly lighter midnight
  static const Color backgroundLight = Color(0xFFF8F9FA); // Clean off-white
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFE94560); // Vibrant accent text
  static const Color textPrimaryLight = Color(0xFF1A1A2E); // Dark text for light mode
}

/// The standardized Theme System.
class FactoryTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: FactoryColors.primary,
      scaffoldBackgroundColor: FactoryColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: FactoryColors.primary,
        secondary: FactoryColors.secondary,
        surface: FactoryColors.surfaceLight,
        background: FactoryColors.backgroundLight,
        error: Colors.redAccent,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        bodyLarge: TextStyle(color: Colors.black87),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: FactoryColors.surfaceLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FactoryColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 4,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: FactoryColors.primary,
      scaffoldBackgroundColor: FactoryColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: FactoryColors.primary,
        secondary: FactoryColors.secondary,
        surface: FactoryColors.surfaceDark,
        background: FactoryColors.backgroundDark,
        error: Colors.redAccent,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white70),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: FactoryColors.surfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FactoryColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 4,
        ),
      ),
    );
  }
}
