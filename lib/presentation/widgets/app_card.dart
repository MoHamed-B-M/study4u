import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final double? width;

  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    this.width,
  });

  factory AppCard.glass({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) {
    return AppCard(
      child: child,
      color: Colors.white.withValues(alpha: 0.6),
      padding: padding,
      borderRadius: borderRadius,
      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  factory AppCard.gradient({
    required Widget child,
    required List<Color> colors,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) {
    return AppCard(
      child: child,
      gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      padding: padding,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: colors.first.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: gradient != null
            ? null
            : (color ?? (isDark ? AppTheme.surfaceDark : Theme.of(context).cardTheme.color ?? AppTheme.surface)),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusCard),
        border: border ?? Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppTheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
