import 'package:flutter/cupertino.dart';

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

  static CupertinoThemeData lightTheme(Color seed) {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: seed,
      scaffoldBackgroundColor: background,
      barBackgroundColor: surface,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontSize: 17,
          color: textPrimary,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.37,
        ),
        tabLabelTextStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        actionTextStyle: TextStyle(
          fontSize: 17,
          color: seed,
        ),
      ),
    );
  }

  static CupertinoThemeData darkTheme(Color seed) {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: seed,
      scaffoldBackgroundColor: const Color(0xFF000000),
      barBackgroundColor: const Color(0xFF1C1C1E),
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontSize: 17,
          color: CupertinoColors.white,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.white,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: CupertinoColors.white,
          letterSpacing: 0.37,
        ),
        tabLabelTextStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.systemGrey,
        ),
        actionTextStyle: TextStyle(
          fontSize: 17,
          color: seed,
        ),
      ),
    );
  }
}
