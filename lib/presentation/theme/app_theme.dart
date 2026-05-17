import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF4ADE80);
  static const Color secondary = Color(0xFF2DD4BF);
  static const Color tertiary = Color(0xFFFBBF24);
  static const Color background = Color(0xFFF4F9F6);
  static const Color surface = Color(0xFFF8FAF9);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color error = Color(0xFFBA1A1A);
  static const Color outline = Color(0xFFCBD5E1);

  static const double radiusXXL = 32.0;
  static const double radiusMD = 16.0;
  static const double radiusPill = 9999.0;
  static const double standardPadding = 24.0;

  static ThemeData lightTheme(Color seed) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: surface,
      error: error,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(),
      cardTheme: _cardTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      navigationBarTheme: _navigationBarTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      progressIndicatorTheme: _progressIndicatorTheme(),
      bottomSheetTheme: _bottomSheetTheme(),
      appBarTheme: _appBarTheme(),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData darkTheme(Color seed) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      error: const Color(0xFFFFB4AB),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      textTheme: _textThemeDark(),
      cardTheme: _cardThemeDark(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      navigationBarTheme: _navigationBarThemeDark(),
      inputDecorationTheme: _inputDecorationThemeDark(),
      progressIndicatorTheme: _progressIndicatorTheme(),
      bottomSheetTheme: _bottomSheetThemeDark(),
      appBarTheme: _appBarThemeDark(),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme() => TextTheme(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: textPrimary),
    displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary.withOpacity(0.7)),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textPrimary.withOpacity(0.6)),
    labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
  );

  static TextTheme _textThemeDark() => TextTheme(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white),
    displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white70),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white60),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white54),
    labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Colors.white70),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Colors.white60),
  );

  static CardThemeData _cardTheme() => CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXXL)),
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
  );

  static CardThemeData _cardThemeDark() => CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXXL)),
    color: const Color(0xFF16213E),
    surfaceTintColor: Colors.transparent,
  );

  static ElevatedButtonThemeData _elevatedButtonTheme() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 56),
      shape: const StadiumBorder(),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  static NavigationBarThemeData _navigationBarTheme() => NavigationBarThemeData(
    backgroundColor: Colors.white.withOpacity(0.9),
    indicatorColor: primary.withOpacity(0.2),
    labelTextStyle: WidgetStateProperty.all(
      TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
  );

  static NavigationBarThemeData _navigationBarThemeDark() => NavigationBarThemeData(
    backgroundColor: const Color(0xFF1A1A2E).withOpacity(0.95),
    indicatorColor: primary.withOpacity(0.2),
    labelTextStyle: WidgetStateProperty.all(
      TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
  );

  static InputDecorationTheme _inputDecorationTheme() => InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: const BorderSide(color: outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: BorderSide(color: outline.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: const BorderSide(color: primary, width: 2),
    ),
    labelStyle: TextStyle(fontSize: 14, color: textPrimary.withOpacity(0.6)),
  );

  static InputDecorationTheme _inputDecorationThemeDark() => InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF16213E),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: const BorderSide(color: Colors.white24),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: const BorderSide(color: Colors.white24),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: BorderSide(color: primary.withOpacity(0.8), width: 2),
    ),
    labelStyle: TextStyle(fontSize: 14, color: Colors.white60),
  );

  static ProgressIndicatorThemeData _progressIndicatorTheme() => ProgressIndicatorThemeData(
    linearMinHeight: 8,
    borderRadius: BorderRadius.circular(10),
  );

  static BottomSheetThemeData _bottomSheetTheme() => const BottomSheetThemeData(
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXXL)),
    ),
  );

  static BottomSheetThemeData _bottomSheetThemeDark() => BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: const Color(0xFF16213E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXXL)),
    ),
  );

  static AppBarTheme _appBarTheme() => AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
  );

  static AppBarTheme _appBarThemeDark() => AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
  );
}
