import 'package:flutter/material.dart';
import '../../core/animation/m3e_spring.dart';
import '../theme/app_theme.dart';

class SlideOutPanel extends StatefulWidget {
  final Widget leading;
  final List<Widget> actions;
  final double panelWidth;

  const SlideOutPanel({
    super.key,
    required this.leading,
    required this.actions,
    this.panelWidth = 120,
  });

  @override
  State<SlideOutPanel> createState() => _SlideOutPanelState();
}

class _SlideOutPanelState extends State<SlideOutPanel>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _widthAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _widthAnim = _controller.drive(Tween<double>(
      begin: 0,
      end: 1,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (M3ESpring.isReducedMotion(context)) {
        _controller.value = _isOpen ? 1 : 0;
      } else {
        M3ESpring.animate(
          _controller,
          to: _isOpen ? 1 : 0,
          spring: M3ESpring.spatial(stiffness: 500, damping: 24),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        child: Row(
          children: [
            Expanded(child: widget.leading),
            AnimatedBuilder(
              animation: _widthAnim,
              builder: (context, child) {
                return ClipRect(
                  clipper: _PanelClipper(_widthAnim.value),
                  child: SizedBox(
                    width: widget.panelWidth,
                    child: child,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppTheme.outline.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(AppTheme.radiusCard),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widget.actions,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelClipper extends CustomClipper<Rect> {
  final double progress;
  _PanelClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      size.width * (1 - progress),
      0,
      size.width * progress,
      size.height,
    );
  }

  @override
  bool shouldReclip(_PanelClipper oldClipper) => oldClipper.progress != progress;
}
