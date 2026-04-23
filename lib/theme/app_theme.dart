// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const softPink = Color(0xFFF3B6C6);
  static const charcoal = Color(0xFF121212);
  static const warmBg = Color(0xFFF8F6F3);

  // Nice readable “ink”
  static const ink = Color(0xFF1C1C1C);
  static const inkSoft = Color(0xFF3A3A3A);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    final scheme = ColorScheme.fromSeed(
      seedColor: softPink,
      brightness: Brightness.light,
    ).copyWith(
      background: warmBg,
      surface: Colors.white,
      onBackground: ink,
      onSurface: ink,
      primary: softPink,
      onPrimary: Colors.black, // readable on softPink
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      textTheme: _textTheme(base.textTheme).apply(
        bodyColor: scheme.onBackground,
        displayColor: scheme.onBackground,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.background,
        foregroundColor: scheme.onBackground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        labelStyle: const TextStyle(color: inkSoft),
        hintStyle: TextStyle(color: inkSoft.withOpacity(0.75)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    final scheme = ColorScheme.fromSeed(
      seedColor: softPink,
      brightness: Brightness.dark,
    ).copyWith(
      background: charcoal,
      surface: const Color(0xFF1B1B1B),
      onBackground: Colors.white,
      onSurface: Colors.white,
      primary: softPink,
      onPrimary: Colors.black,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      textTheme: _textTheme(base.textTheme).apply(
        bodyColor: scheme.onBackground,
        displayColor: scheme.onBackground,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.background,
        foregroundColor: scheme.onBackground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B1B1B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.78)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      headlineSmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(),
      bodyMedium: GoogleFonts.inter(),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
    );
  }
}