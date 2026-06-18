import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color constants
  static const Color bgColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE4E4E7);
  static const Color textPrimary = Color(0xFF09090B);
  static const Color textSecondary = Color(0xFF71717A);
  static const Color sidebarBg = Color(0xFF09090B);
  static const Color sidebarActive = Color(0xFF27272A);
  static const Color primaryBtn = Color(0xFF18181B);

  // Legacy aliases
  static const Color background = bgColor;
  static const Color accent = primaryBtn;
  static const Color border = borderColor;
  static const Color cardBg = surfaceColor;
  static const Color textMuted = Color(0xFFA1A1AA);
  static const Color sidebarText = Color(0xFFFAFAFA);
  static const Color sidebarTextMuted = Color(0xFFA1A1AA);
  static const Color sidebarHover = Color(0xFF3F3F46);
  static const Color scoreHigh = Color(0xFF16A34A);
  static const Color scoreMid = Color(0xFFCA8A04);
  static const Color scoreLow = Color(0xFFDC2626);
  static const Color scoreHighBg = Color(0xFF16A34A);
  static const Color scoreMidBg = Color(0xFFCA8A04);
  static const Color scoreLowBg = Color(0xFFDC2626);

  static Color scoreColor(int score) {
    if (score >= 8) return scoreHigh;
    if (score >= 6) return scoreMid;
    return scoreLow;
  }

  static BoxDecoration cardDecoration({double radius = 8}) => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBtn,
        brightness: Brightness.light,
        surface: surfaceColor,
        background: bgColor,
        primary: primaryBtn,
        onPrimary: bgColor,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF18181B), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide:
              const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBtn,
          foregroundColor: bgColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBtn,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderColor),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }
}
