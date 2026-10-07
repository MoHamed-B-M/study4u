import 'package:flutter/material.dart';
import '../theme/manga_tokens.dart';
import '../theme/manga_decor.dart';
import '../theme/comic_theme.dart';

/// Flutter port of Komi `KomiSurface` (Manga branch):
/// sharp 3dp inked border + 6/6 hard shadow + optional screentone corner.
///
/// Use instead of the generic [ComicCard] when you want the exact
/// Komi manga panel look with Day/Night aware colors.
class MangaPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool screentoneCorner;
  final bool topEdgeOnly;
  final VoidCallback? onTap;

  const MangaPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.screentoneCorner = false,
    this.topEdgeOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final manga = isDark ? ComicTheme.darkManga : ComicTheme.lightManga;

    final borderSide =
        BorderSide(color: scheme.outline, width: MangaShape.borderPanel);

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: topEdgeOnly
            ? Border(top: BorderSide(color: scheme.outline, width: 4))
            : Border.fromBorderSide(borderSide),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow,
            offset: const Offset(
                MangaShadow.cardX, MangaShadow.cardY),
            blurRadius: MangaShadow.blur,
          ),
        ],
      ),
      child: screentoneCorner
          ? MangaScreentoneCorner(
              ink: scheme.onSurface,
              opacity: manga.screentoneOpacity,
              child: child,
            )
          : child,
    );

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

/// Flutter port of Komi `KomiHeadline` with `HeadlineMarker.Stamp`:
/// a skewed 12x22 stamp chip + uppercase Anton title.
class MangaHeadline extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool showMarker;

  const MangaHeadline(
    this.text, {
    super.key,
    this.style,
    this.showMarker = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ??
        theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
        ) ??
        const TextStyle(fontSize: 16);
    final upper = text.toUpperCase();
    if (!showMarker) return Text(upper, style: base);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: MangaShape.skewStampDeg * 3.141592653589793 / 180,
          child: Container(
            width: 12,
            height: 22,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(upper, style: base, maxLines: 2),
        ),
      ],
    );
  }
}

/// Flutter port of Komi `KomiChip` (Manga branch, Info kind):
/// uppercase W800 label, 2dp inked border, sharp corners.
class MangaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const MangaChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? scheme.primary : scheme.surface;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(
              color: scheme.outline, width: MangaShape.borderChip),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.shadow,
                    offset: const Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11.5,
            letterSpacing: 0.5,
            color: fg,
          ),
        ),
      ),
    );
  }
}
