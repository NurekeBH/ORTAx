import 'package:flutter/material.dart';

import 'colors.dart';
import 'ortax_colors.dart';

class AppTheme {
  static ThemeData light({String? fontFamily}) {
    const light = OrtaxColors.light;
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = base.textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: light.textPrimary,
      displayColor: light.textPrimary,
    );

    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textInverse,
        secondary: AppColors.accent,
        onSecondary: light.textPrimary,
        surface: light.surface,
        onSurface: light.textPrimary,
        error: AppColors.error,
        onError: AppColors.textInverse,
      ),
      extensions: const [OrtaxColors.light],
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: light.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: light.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: light.surface,
        border: _border(color: light.border),
        enabledBorder: _border(color: light.border),
        focusedBorder: _border(color: AppColors.primary, width: 1.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  static ThemeData dark({String? fontFamily}) {
    final base = ThemeData.dark(useMaterial3: true);
    const dark = OrtaxColors.dark;
    final textTheme = base.textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: dark.textPrimary,
      displayColor: dark.textPrimary,
    );

    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFFE8C766),
        onPrimary: AppColors.textInverse,
        secondary: AppColors.accent,
        onSecondary: dark.textPrimary,
        surface: dark.surface,
        onSurface: dark.textPrimary,
        error: AppColors.error,
        onError: AppColors.textInverse,
      ),
      extensions: const [OrtaxColors.dark],
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: dark.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: dark.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8C766),
          foregroundColor: const Color(0xFF0F1218),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE8C766),
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: Color(0xFFE8C766)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark.surface,
        border: _border(color: dark.border),
        enabledBorder: _border(color: dark.border),
        focusedBorder: _border(color: const Color(0xFFE8C766), width: 1.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  static OutlineInputBorder _border({Color color = const Color(0xFFE0DACB), double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
