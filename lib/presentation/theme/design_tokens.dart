import 'package:flutter/material.dart';

class DesignTokens {
  DesignTokens._();

  // Primary palette from design1.jpg
  static const Color primaryLavender = Color(0xFFA18CFF);
  static const Color primaryLavenderLight = Color(0xFFC4B5FD);
  static const Color secondaryBlue = Color(0xFF8F99FB);
  static const Color secondaryBlueLight = Color(0xFFB8C0FC);

  // Card accent colors (matching design1.jpg soft pastels)
  static const Color cardCream = Color(0xFFFFF3E0);
  static const Color cardCreamAccent = Color(0xFFFFB74D);
  static const Color cardBlue = Color(0xFFE8F0FE);
  static const Color cardBlueAccent = Color(0xFF64B5F6);
  static const Color cardPink = Color(0xFFFDE8E8);
  static const Color cardPinkAccent = Color(0xFFEF5350);
  static const Color cardPurple = Color(0xFFF0E6FF);
  static const Color cardPurpleAccent = Color(0xFF7C4DFF);
  static const Color cardGreen = Color(0xFFE8F5E9);
  static const Color cardGreenAccent = Color(0xFF66BB6A);
  static const Color cardTeal = Color(0xFFE0F2F1);
  static const Color cardTealAccent = Color(0xFF26A69A);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Background
  static const Color background = Color(0xFFF7F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F5);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  // Border radius
  static const double radiusSM = 12.0;
  static const double radiusMD = 20.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 28.0;
  static const double radiusPill = 9999.0;

  // Shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF212121).withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: const Color(0xFF212121).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Blob gradient colors for background decoration
  static const Color blobOrange = Color(0xFFFFB74D);
  static const Color blobPurple = Color(0xFFA18CFF);
  static const Color blobBlue = Color(0xFF8F99FB);
  static const Color blobPink = Color(0xFFF48FB1);
}

/// Theme-aware color accessor.
/// Use `context.colorScheme.*` or these shorthand getters for
/// colors that automatically adapt to light / dark mode.
extension ThemeContext on BuildContext {
  /// Page background – matches [ThemeData.scaffoldBackgroundColor].
  Color get background => Theme.of(this).scaffoldBackgroundColor;

  /// Card / sheet surface – maps to M3 `surfaceContainerLow`.
  Color get surface => Theme.of(this).colorScheme.surfaceContainerLow;

  /// Divider / subtle separator – maps to M3 `surfaceContainerHighest`.
  Color get surfaceVariant =>
      Theme.of(this).colorScheme.surfaceContainerHighest;

  /// Primary body text.
  Color get textPrimary => Theme.of(this).colorScheme.onSurface;

  /// Secondary / subdued text.
  Color get textSecondary => Theme.of(this).colorScheme.onSurfaceVariant;

  /// Tertiary / hint text.
  Color get textTertiary =>
      Theme.of(this).colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
}
