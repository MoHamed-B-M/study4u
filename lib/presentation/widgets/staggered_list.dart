import 'package:flutter/material.dart';

class StaggeredList extends StatelessWidget {
  final List<Widget> items;
  final Duration itemDelay;
  final Duration staggerDelay;
  final EdgeInsetsGeometry? padding;

  const StaggeredList({
    super.key,
    required this.items,
    this.itemDelay = const Duration(milliseconds: 80),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        children: List.generate(items.length, (index) {
          return _StaggeredItem(
            index: index,
            itemDelay: itemDelay,
            staggerDelay: staggerDelay,
            child: items[index],
          );
        }),
      ),
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  final int index;
  final Duration itemDelay;
  final Duration staggerDelay;
  final Widget child;

  const _StaggeredItem({
    required this.index,
    required this.itemDelay,
    required this.staggerDelay,
    required this.child,
  });

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final delay = widget.itemDelay + widget.staggerDelay * widget.index;
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
