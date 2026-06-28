import 'package:flutter/material.dart';
import '../../core/animation/m3e_spring.dart';

class AnimatedCounter extends StatefulWidget {
  final double targetValue;
  final int decimals;
  final TextStyle? style;
  final String suffix;

  const AnimatedCounter({
    super.key,
    required this.targetValue,
    this.decimals = 2,
    this.style,
    this.suffix = '',
  });

  @override
  State<AnimatedCounter> createState() => AnimatedCounterState();
}

class AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _displayValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      setState(() => _displayValue = _controller.value * widget.targetValue);
    });
    if (context.mounted && M3ESpring.isReducedMotion(context)) {
      _controller.value = 1;
    } else {
      M3ESpring.animate(
        _controller,
        to: 1,
        spring: M3ESpring.spatial(stiffness: 300, damping: 16),
      );
    }
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _controller.value = 0;
      if (context.mounted && M3ESpring.isReducedMotion(context)) {
        _controller.value = 1;
      } else {
        M3ESpring.animate(
          _controller,
          to: 1,
          spring: M3ESpring.spatial(stiffness: 300, damping: 16),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _displayValue.toStringAsFixed(widget.decimals);
    return Text('$formatted${widget.suffix}', style: widget.style);
  }
}
