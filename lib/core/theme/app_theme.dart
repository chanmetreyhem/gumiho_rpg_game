import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const purple = Color(0xFF6C3CE9);
  static const purpleDark = Color(0xFF4A2DB8);
  static const purpleLight = Color(0xFFB8A4F5);
  static const orange = Color(0xFFFF8A3D);
  static const orangeDark = Color(0xFFE86A1A);
  static const gold = Color(0xFFFFC107);
  static const textPrimary = Color(0xFF2D1B69);
  static const textSecondary = Color(0xFF8E8E9A);
  static const cardWhite = Color(0xF8FFFFFF);
  static const gradientTop = Color(0xFFE8DEFF);
  static const gradientBottom = Color(0xFFF8F5FF);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientBottom, Colors.white],
    stops: [0.0, 0.45, 1.0],
  );
}

class AppTheme {
  static ThemeData get light => _buildLight(null);

  static ThemeData forLocale(String languageCode) {
    if (languageCode == 'km') {
      return _buildLight(GoogleFonts.notoSansKhmer);
    }
    return light;
  }

  static ThemeData _buildLight(TextStyle Function({
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    Color? color,
  })? fontBuilder) {
    TextStyle style({
      required Color color,
      required FontWeight fontWeight,
      required double fontSize,
      double letterSpacing = 0,
    }) {
      if (fontBuilder != null) {
        return fontBuilder(
          color: color,
          fontWeight: fontWeight,
          fontSize: fontSize,
          letterSpacing: letterSpacing,
        );
      }
      return TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      );
    }

    final textTheme = TextTheme(
      headlineLarge: style(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      headlineMedium: style(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      titleLarge: style(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      titleMedium: style(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyMedium: style(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      labelLarge: style(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.gradientBottom,
      colorScheme: const ColorScheme.light(
        primary: AppColors.purple,
        secondary: AppColors.orange,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: style(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.8,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
