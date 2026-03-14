import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF12121A);
  static const Color darkCard = Color(0xFF1A1A26);
  static const Color darkBorder = Color(0xFF2A2A3A);
  static const Color darkText = Color(0xFFF0F0FF);
  static const Color darkTextSecondary = Color(0xFF8888AA);
  static const Color darkTextMuted = Color(0xFF555566);
  static const Color accentPrimary = Color(0xFF6366F1);
  static const Color accentSecondary = Color(0xFF8B5CF6);
  static const Color accentTertiary = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityUrgent = Color(0xFFDC2626);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPrimary, accentSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        background: darkBackground,
        surface: darkSurface,
        onPrimary: Colors.white,
        onBackground: darkText,
        onSurface: darkText,
        error: accentRed,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: darkText),
        displayMedium: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: darkText),
        headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: darkText),
        headlineSmall: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: darkText),
        bodyLarge: GoogleFonts.inter(fontSize: 15, color: darkText),
        bodyMedium: GoogleFonts.inter(fontSize: 13, color: darkTextSecondary),
        bodySmall: GoogleFonts.inter(fontSize: 11, color: darkTextMuted),
        labelLarge: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: darkText),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: darkText),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentPrimary,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: darkBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: darkBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentPrimary, width: 2)),
        labelStyle: GoogleFonts.inter(color: darkTextSecondary),
        hintStyle: GoogleFonts.inter(color: darkTextMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(primary: accentPrimary),
      scaffoldBackgroundColor: const Color(0xFFF8F9FF),
    );
  }

  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'low': return priorityLow;
      case 'medium': return priorityMedium;
      case 'high': return priorityHigh;
      case 'urgent': return priorityUrgent;
      default: return priorityMedium;
    }
  }

  static Color getHabitCategoryColor(String category) {
    switch (category) {
      case 'health': return accentGreen;
      case 'fitness': return accentOrange;
      case 'mindfulness': return accentSecondary;
      case 'learning': return accentTertiary;
      case 'social': return accentPink;
      case 'productivity': return accentPrimary;
      case 'finance': return accentGreen;
      case 'creativity': return accentPink;
      default: return accentPrimary;
    }
  }
}
