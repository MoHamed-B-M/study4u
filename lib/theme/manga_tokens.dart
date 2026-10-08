import 'package:flutter/material.dart';

/// Port of Komi Store `mangaColors()` + `mangaAccentSwatch()` +
/// `MangaPaper` / `MangaAccent` (core/presentation/.../personality/manga/).
///
/// Source of truth for every hex below:
/// - DAY:   page F1EADC / panel FAF5EA / well E7DEC9 / ink 1B150D /
///          muted 695F50 / shadow 1B150D / error B3261E
/// - NIGHT: page 0C0A07 / panel 16120C / well 211B12 / ink F0E9DA /
///          muted 968B77 / shadow 000000 / error FF6B5E
/// - NORD:  page 2E3440 / panel 3B4252 / well 434C5E / ink ECEFF4 /
///          muted 9AA5BD / shadow 20242E / error E5818A
/// - Accents: MONO=null(ink/paper) / CRIMSON D8202A / COBALT 1F4ED8 /
///          SUN F5A300 (on 1B150D) / FROST 88C0D0 (on 2E3440)

enum MangaPaper { day, night, nord }

enum MangaAccent { mono, crimson, cobalt, sun, frost }

class MangaPalette {
  final Color page;
  final Color panel;
  final Color well;
  final Color ink;
  final Color muted;
  final Color shadow;
  final Color error;
  final Color onError;
  final double screentoneOpacity;
  final double gridOpacity;

  const MangaPalette({
    required this.page,
    required this.panel,
    required this.well,
    required this.ink,
    required this.muted,
    required this.shadow,
    required this.error,
    required this.onError,
    required this.screentoneOpacity,
    required this.gridOpacity,
  });

  static const day = MangaPalette(
    page: Color(0xFFF1EADC),
    panel: Color(0xFFFAF5EA),
    well: Color(0xFFE7DEC9),
    ink: Color(0xFF1B150D),
    muted: Color(0xFF695F50),
    shadow: Color(0xFF1B150D),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    screentoneOpacity: 0.16,
    gridOpacity: 0.05,
  );

  static const night = MangaPalette(
    page: Color(0xFF0C0A07),
    panel: Color(0xFF16120C),
    well: Color(0xFF211B12),
    ink: Color(0xFFF0E9DA),
    muted: Color(0xFF968B77),
    shadow: Color(0xFF000000),
    error: Color(0xFFFF6B5E),
    onError: Color(0xFF1B150D),
    screentoneOpacity: 0.20,
    gridOpacity: 0.06,
  );

  static const nord = MangaPalette(
    page: Color(0xFF2E3440),
    panel: Color(0xFF3B4252),
    well: Color(0xFF434C5E),
    ink: Color(0xFFECEFF4),
    muted: Color(0xFF9AA5BD),
    shadow: Color(0xFF20242E),
    error: Color(0xFFE5818A),
    onError: Color(0xFF20242E),
    screentoneOpacity: 0.16,
    gridOpacity: 0.05,
  );

  static MangaPalette of(MangaPaper paper) {
    switch (paper) {
      case MangaPaper.day:
        return day;
      case MangaPaper.night:
        return night;
      case MangaPaper.nord:
        return nord;
    }
  }
}

class MangaAccentSwatch {
  final Color primary;
  final Color onPrimary;
  const MangaAccentSwatch(this.primary, this.onPrimary);
}

/// Returns null for MONO (caller falls back to ink/paper).
MangaAccentSwatch? mangaAccentSwatch(MangaAccent accent, MangaPalette ink) {
  switch (accent) {
    case MangaAccent.mono:
      return null;
    case MangaAccent.crimson:
      return const MangaAccentSwatch(Color(0xFFD8202A), Color(0xFFFFFFFF));
    case MangaAccent.cobalt:
      return const MangaAccentSwatch(Color(0xFF1F4ED8), Color(0xFFFFFFFF));
    case MangaAccent.sun:
      return const MangaAccentSwatch(Color(0xFFF5A300), Color(0xFF1B150D));
    case MangaAccent.frost:
      return const MangaAccentSwatch(Color(0xFF88C0D0), Color(0xFF2E3440));
  }
}

/// Resolved Komi manga color set (== PersonalityColors in Komi).
class MangaColors {
  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color error;
  final Color onError;
  final Color shadow;
  final double screentoneOpacity;
  final double gridOpacity;

  const MangaColors({
    required this.primary,
    required this.onPrimary,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.shadow,
    required this.screentoneOpacity,
    required this.gridOpacity,
  });

  bool get isDark => background.computeLuminance() < 0.5;

  static MangaColors resolve({
    MangaPaper paper = MangaPaper.day,
    MangaAccent accent = MangaAccent.crimson,
  }) {
    final ink = MangaPalette.of(paper);
    final swatch = mangaAccentSwatch(accent, ink);
    final primary = swatch?.primary ?? ink.ink;
    final onPrimary = swatch?.onPrimary ?? ink.page;
    return MangaColors(
      primary: primary,
      onPrimary: onPrimary,
      background: ink.page,
      onBackground: ink.ink,
      surface: ink.panel,
      onSurface: ink.ink,
      surfaceVariant: ink.well,
      onSurfaceVariant: ink.muted,
      outline: ink.ink,
      outlineVariant: ink.muted,
      error: ink.error,
      onError: ink.onError,
      shadow: ink.shadow,
      screentoneOpacity: ink.screentoneOpacity,
      gridOpacity: ink.gridOpacity,
    );
  }
}

/// Komi `MangaShape`: sharp corners, thick inked borders.
class MangaShape {
  MangaShape._();
  static const double borderPanel = 3.0;
  static const double borderButton = 2.5;
  static const double borderChip = 2.0;
  static const double corner = 0.0;
  static const double skewStampDeg = -10.0;
  static const double badgeRotationDeg = -8.0;
}

/// Komi `MangaShadow`: hard offset shadows, zero blur.
class MangaShadow {
  MangaShadow._();
  static const double cardX = 6.0;
  static const double cardY = 6.0;
  static const double buttonX = 4.0;
  static const double buttonY = 4.0;
  static const double modalX = 14.0;
  static const double modalY = 14.0;
  static const double blur = 0.0;
  static const double pressTranslate = 4.0;
}

/// Komi `Spacing`: shared neutral rhythm.
class MangaSpacing {
  MangaSpacing._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}
