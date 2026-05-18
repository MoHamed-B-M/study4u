import 'package:flutter/cupertino.dart';
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
    this.padding,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    this.width,
    this.color,
  });

  factory AppCard.glass({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) {
    return AppCard(
      child: child,
      padding: padding,
      borderRadius: borderRadius,
      border: Border.all(color: CupertinoColors.systemGrey4),
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
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: gradient != null
            ? null
            : (color ?? (isDark
                ? const Color(0xFF1C1C1E)
                : CupertinoColors.systemGrey6)),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusXXL),
        border: border,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
