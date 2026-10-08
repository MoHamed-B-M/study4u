import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manga_tokens.dart';

/// Study4U theme — direct port of Komi Store **Manga personality**
/// (default: DAY paper + CRIMSON accent).
///
/// Mapping from Komi (`core/presentation/.../personality/manga/`):
/// - `MangaColors.mangaColors(DAY, CRIMSON)` -> light scheme
/// - `MangaColors.mangaColors(NIGHT, CRIMSON)` -> dark scheme
///   (NIGHT ink F0E9DA, panel 16120C, page 0C0A07)
/// - `MangaShape`  -> borderPanel 3, borderButton 2.5, borderChip 2,
///   corner 0 (sharp, BorderRadius.zero everywhere)
/// - `MangaShadow` -> card 6/6, button 4/4, modal 14/14, blur 0
/// - `MangaType`   -> display 28, title 22, stamp 15 (0.06em),
///   body 13.5/20 Medium, label 12/14 Black, mono 12/16, uppercase headings
/// - Fonts (Latin): display Anton, body Noto Sans, mono JetBrains Mono
class ComicTheme {
  ComicTheme._();

  // --- Resolved Komi palettes (keep old field names as aliases) ---
  static final MangaColors lightManga = MangaColors.resolve(
    paper: MangaPaper.day,
    accent: MangaAccent.crimson,
  );
  static final MangaColors darkManga = MangaColors.resolve(
    paper: MangaPaper.night,
    accent: MangaAccent.crimson,
  );

  // Legacy names kept as `static const` so existing `const` call sites
  // (default param values, const widgets, const BoxShadows) keep compiling.
  // Values match Komi DAY/NIGHT exactly.
  static const Color paperBg = Color(0xFFF1EADC);
  static const Color surfaceWhite = Color(0xFFFAF5EA);
  static const Color inkBlack = Color(0xFF1B150D);
  static const Color inkRed = Color(0xFFD8202A);
  static const Color darkPulp = Color(0xFF0C0A07);
  static const Color darkSurface = Color(0xFF16120C);
  static const Color darkText = Color(0xFFF0E9DA);

  // Komi well / muted, exposed for panels & states.
  static const Color wellLight = Color(0xFFE7DEC9);
  static const Color mutedLight = Color(0xFF695F50);
  static const Color wellDark = Color(0xFF211B12);
  static const Color mutedDark = Color(0xFF968B77);

  static ThemeData _build(MangaColors m, Brightness brightness) {
    final displayFamily = GoogleFonts.anton().fontFamily;
    final bodyFamily = GoogleFonts.notoSans().fontFamily;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: m.primary,
      onPrimary: m.onPrimary,
      primaryContainer: m.primary,
      onPrimaryContainer: m.onPrimary,
      secondary: m.primary,
      onSecondary: m.onPrimary,
      secondaryContainer: m.primary,
      onSecondaryContainer: m.onPrimary,
      tertiary: m.surfaceVariant,
      onTertiary: m.onSurfaceVariant,
      surface: m.surface,
      onSurface: m.onSurface,
      surfaceContainer: m.surface,
      surfaceContainerHigh: m.surfaceVariant,
      surfaceContainerHighest: m.surfaceVariant,
      error: m.error,
      onError: m.onError,
      outline: m.outline,
      outlineVariant: m.outlineVariant,
      shadow: m.shadow,
      scrim: m.shadow,
      surfaceTint: m.primary,
      inverseSurface: m.onSurface,
      onInverseSurface: m.surface,
      inversePrimary: m.primary,
    );

    // Komi MangaType: display/title/stamp = display face, uppercase.
    final display = GoogleFonts.anton(
      color: m.onBackground,
      letterSpacing: 0.4,
    );
    final body = GoogleFonts.notoSans(
      color: m.onBackground,
      fontWeight: FontWeight.w500,
    );
    final mono = GoogleFonts.jetBrainsMono(color: m.onSurfaceVariant);

    final textTheme = TextTheme(
      displayLarge: display.copyWith(fontSize: 28, height: 1.0),
      displayMedium: display.copyWith(fontSize: 26, height: 1.0),
      displaySmall: display.copyWith(fontSize: 24, height: 1.0),
      headlineLarge: display.copyWith(fontSize: 22, height: 23 / 22),
      headlineMedium: display.copyWith(fontSize: 20, height: 1.05),
      headlineSmall: display.copyWith(fontSize: 18, height: 1.1),
      titleLarge: display.copyWith(fontSize: 16, height: 1.1),
      titleMedium: display.copyWith(fontSize: 15, height: 1.0, letterSpacing: 0.9),
      titleSmall: display.copyWith(fontSize: 14, height: 1.1),
      bodyLarge: body.copyWith(fontSize: 13.5, height: 20 / 13.5),
      bodyMedium: body.copyWith(fontSize: 13, height: 1.45),
      bodySmall: body.copyWith(fontSize: 12, height: 1.4),
      labelLarge: GoogleFonts.notoSans(
        fontSize: 12,
        height: 14 / 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.24,
        color: m.onBackground,
      ),
      labelMedium: GoogleFonts.notoSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: m.onSurfaceVariant,
      ),
      labelSmall: mono.copyWith(fontSize: 11, height: 1.3),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: m.background,
      colorScheme: scheme,
      textTheme: textTheme,
      fontFamily: bodyFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: m.surface,
        foregroundColor: m.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: displayFamily,
          fontSize: 22,
          height: 1.0,
          letterSpacing: 0.2,
          color: m.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: m.surface,
        shadowColor: m.shadow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: m.outline, width: MangaShape.borderPanel),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(m.primary),
          foregroundColor: WidgetStatePropertyAll(m.onPrimary),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: m.outline, width: MangaShape.borderButton),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontFamily: displayFamily,
              fontSize: 15,
              letterSpacing: 0.9,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(m.onSurface),
          side: WidgetStatePropertyAll(
            BorderSide(color: m.outline, width: MangaShape.borderButton),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: m.background,
        selectedColor: m.primary,
        labelStyle: TextStyle(
          fontFamily: bodyFamily,
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
          letterSpacing: 0.5,
          color: m.onSurface,
        ),
        side: BorderSide(color: m.outline, width: MangaShape.borderChip),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      dividerTheme: DividerThemeData(color: m.outlineVariant, thickness: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: m.surface,
        selectedItemColor: m.onPrimary,
        unselectedItemColor: m.onSurface,
      ),
    );
  }

  static ThemeData get light => _build(lightManga, Brightness.light);
  static ThemeData get dark => _build(darkManga, Brightness.dark);
}
