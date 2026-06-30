import 'package:flutter/material.dart';
import '../theme/comic_theme.dart';

class ComicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color pressBackgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool isCta;

  const ComicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor = ComicTheme.surfaceWhite,
    this.pressBackgroundColor = ComicTheme.inkRed,
    this.borderColor = ComicTheme.inkBlack,
    this.borderWidth = 2.5,
    this.padding,
    this.width,
    this.height,
    this.isCta = false,
  });

  @override
  State<ComicButton> createState() => _ComicButtonState();
}

class _ComicButtonState extends State<ComicButton> {
  bool _isPressed = false;

  Color get _bgColor {
    if (_isPressed) return widget.pressBackgroundColor;
    if (widget.isCta) return ComicTheme.inkRed;
    return widget.backgroundColor;
  }

  Color get _fgColor {
    if (_isPressed && !widget.isCta) return ComicTheme.surfaceWhite;
    if (widget.isCta) return ComicTheme.surfaceWhite;
    return ComicTheme.inkBlack;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color resolveBg(Color c) {
      if (c == ComicTheme.surfaceWhite && isDark) return ComicTheme.darkSurface;
      return c;
    }

    Color resolveFg(Color c) {
      if (c == ComicTheme.inkBlack && isDark) return ComicTheme.darkText;
      return c;
    }

    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              widget.onPressed?.call();
              setState(() => _isPressed = false);
            }
          : null,
      onTapCancel:
          widget.onPressed != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: resolveBg(_bgColor),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: ComicTheme.inkBlack,
              offset: _isPressed ? const Offset(1, 1) : const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: resolveFg(_fgColor),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
