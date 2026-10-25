import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color defaultPrimary = Color(0xFF1E3A8A); // Classic Vintech Indigo / Navy
  static const Color secondaryColor = Color(0xFF0F766E); // Teal accent
  static const Color backgroundLight = Color(0xFFEEF2F6); // Cool Gray/Slate canvas untuk kontras tinggi
  static const Color surfaceLight = Colors.white;
  static const Color textMain = Color(0xFF0F172A); // Slate-900
  static const Color textMuted = Color(0xFF64748B); // Slate-500
  static const Color borderLight = Color(0xFFE2E8F0); // Slate-200
  static const Color success = Color(0xFF16A34A); // Green-600
  static const Color warning = Color(0xFFD97706); // Amber-600
  static const Color danger = Color(0xFFDC2626); // Red-600

  /// Converts hex color string (e.g. '#1e3a8a' or '1e3a8a') to Color object.
  static Color parseHexColor(String? hexString, {Color defaultColor = defaultPrimary}) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    String cleanHex = hexString.replaceAll('#', '').trim();
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    if (cleanHex.length == 8) {
      try {
        return Color(int.parse(cleanHex, radix: 16));
      } catch (_) {
        return defaultColor;
      }
    }
    return defaultColor;
  }

  static ThemeData getTheme({Color primary = defaultPrimary}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: surfaceLight,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textMain),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textMain,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withAlpha(80), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1),
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        hintStyle: TextStyle(color: textMuted.withAlpha(120), fontSize: 14),
      ),
    );
  }
}
