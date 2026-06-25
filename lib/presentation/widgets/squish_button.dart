import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SquishButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double restingScale;
  final double pressedScale;
  final double restingRadius;
  final double pressedRadius;
  final Duration squishDuration;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;

  const SquishButton({
    super.key,
    required this.child,
    this.onTap,
    this.restingScale = 1.0,
    this.pressedScale = 0.95,
    this.restingRadius = 24.0,
    this.pressedRadius = 12.0,
    this.squishDuration = const Duration(milliseconds: 300),
    this.backgroundColor,
    this.padding,
    this.boxShadow,
  });

  @override
  State<SquishButton> createState() => _SquishButtonState();
}

class _SquishButtonState extends State<SquishButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _radiusAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.squishDuration,
    );
    _scaleAnim = _controller.drive(Tween<double>(
      begin: widget.restingScale,
      end: widget.pressedScale,
    ));
    _radiusAnim = _controller.drive(Tween<double>(
      begin: widget.restingRadius,
      end: widget.pressedRadius,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    _controller.reverse().then((_) {
      if (mounted && widget.onTap != null) widget.onTap!();
    });
  }

  void _handleTapCancel() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(_radiusAnim.value),
                boxShadow: widget.boxShadow,
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
