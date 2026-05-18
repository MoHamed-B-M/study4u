import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FloatingNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar> {
  final List<_NavDestination> _destinations = const [
    _NavDestination(
      icon: CupertinoIcons.home,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Home',
    ),
    _NavDestination(
      icon: CupertinoIcons.calendar,
      activeIcon: CupertinoIcons.calendar_circle_fill,
      label: 'Tracker',
    ),
    _NavDestination(
      icon: CupertinoIcons.chart_bar_alt_fill,
      activeIcon: CupertinoIcons.chart_bar_alt_fill,
      label: 'Stats',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 48,
        right: 48,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? CupertinoColors.white.withOpacity(0.08)
                  : CupertinoColors.black.withOpacity(0.06),
              border: Border.all(
                color: isDark
                    ? CupertinoColors.white.withOpacity(0.12)
                    : CupertinoColors.black.withOpacity(0.08),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_destinations.length, (index) {
                final destination = _destinations[index];
                final isActive = index == widget.currentIndex;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onDestinationSelected(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isActive
                          ? CupertinoTheme.of(context).primaryColor.withOpacity(0.25)
                          : CupertinoColors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isActive ? destination.activeIcon : destination.icon,
                      color: isActive
                          ? CupertinoTheme.of(context).primaryColor
                          : isDark
                              ? CupertinoColors.white.withOpacity(0.45)
                              : CupertinoColors.black.withOpacity(0.45),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
