import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComicTheme {
  ComicTheme._();

  static const paperBg = Color(0xFFFDFBF7);
  static const inkBlack = Color(0xFF000000);
  static const inkRed = Color(0xFFE63946);
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const darkPulp = Color(0xFF2A2A2A);
  static const darkSurface = Color(0xFF3A3A3A);
  static const darkText = Color(0xFFF5F5F5);

  static ThemeData get light => ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: paperBg,
        colorScheme: ColorScheme.light(
          primary: inkRed,
          surface: surfaceWhite,
          onSurface: inkBlack,
        ),
        textTheme: _textTheme.apply(bodyColor: inkBlack, displayColor: inkBlack),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceWhite,
          foregroundColor: inkBlack,
          elevation: 0,
          titleTextStyle: GoogleFonts.luckiestGuy(
            fontSize: 22,
            color: inkBlack,
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: darkPulp,
        colorScheme: ColorScheme.dark(
          primary: inkRed,
          surface: darkSurface,
          onSurface: darkText,
        ),
        textTheme: _textTheme.apply(
          bodyColor: darkText,
          displayColor: darkText,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkSurface,
          foregroundColor: darkText,
          elevation: 0,
          titleTextStyle: GoogleFonts.luckiestGuy(
            fontSize: 22,
            color: darkText,
          ),
        ),
      );

  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.luckiestGuy(fontSize: 32),
        displayMedium: GoogleFonts.luckiestGuy(fontSize: 28),
        displaySmall: GoogleFonts.luckiestGuy(fontSize: 24),
        headlineLarge: GoogleFonts.luckiestGuy(fontSize: 22),
        headlineMedium: GoogleFonts.luckiestGuy(fontSize: 20),
        headlineSmall: GoogleFonts.luckiestGuy(fontSize: 18),
        titleLarge: GoogleFonts.luckiestGuy(fontSize: 16),
        titleMedium: GoogleFonts.luckiestGuy(fontSize: 14),
        titleSmall: GoogleFonts.luckiestGuy(fontSize: 12),
        bodyLarge: GoogleFonts.luckiestGuy(fontSize: 14),
        bodyMedium: GoogleFonts.luckiestGuy(fontSize: 12),
        labelLarge: GoogleFonts.luckiestGuy(fontSize: 14),
        labelMedium: GoogleFonts.luckiestGuy(fontSize: 12),
        labelSmall: GoogleFonts.luckiestGuy(fontSize: 10),
      );
}
