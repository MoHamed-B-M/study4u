import 'package:flutter/cupertino.dart';

class AnimatedCounter extends StatefulWidget {
  final double targetValue;
  final int decimals;
  final TextStyle? style;
  final String suffix;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.targetValue,
    this.decimals = 2,
    this.style,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<AnimatedCounter> createState() => AnimatedCounterState();
}

class AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _displayValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.addListener(() {
      setState(() => _displayValue = _animation.value * widget.targetValue);
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _controller.reset();
      _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
      _controller.forward();
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
