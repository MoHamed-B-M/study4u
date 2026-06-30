import 'package:flutter/material.dart';
import '../theme/comic_theme.dart';

class ComicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? customShadow;

  const ComicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor = ComicTheme.surfaceWhite,
    this.borderColor = ComicTheme.inkBlack,
    this.borderWidth = 2.5,
    this.borderRadius,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ComicTheme.darkSurface : backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: borderRadius ?? BorderRadius.zero,
        boxShadow: customShadow ??
            [
              BoxShadow(
                color: ComicTheme.inkBlack,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
      ),
      child: child,
    );
  }
}
