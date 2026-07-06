import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/comic_theme.dart';

class ComicLoader extends StatefulWidget {
  final double size;
  final Color colorA;
  final Color colorB;

  const ComicLoader({
    super.key,
    this.size = 24,
    this.colorA = ComicTheme.inkRed,
    this.colorB = ComicTheme.surfaceWhite,
  });

  @override
  State<ComicLoader> createState() => _ComicLoaderState();
}

class _ComicLoaderState extends State<ComicLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
    _colorAnim = ColorTween(begin: widget.colorA, end: widget.colorB).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: SvgPicture.asset(
            'assets/icons/thunder-struck.svg',
            width: widget.size,
            height: widget.size,
            colorFilter: ColorFilter.mode(
              _colorAnim.value ?? widget.colorB,
              BlendMode.srcIn,
            ),
          ),
        );
      },
    );
  }
}
