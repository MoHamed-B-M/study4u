import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class BubbleNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const BubbleNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  static const _destinations = [
    _NavDestination(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavDestination(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today, label: 'Tracker'),
    _NavDestination(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'Stats'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 0, 24, MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? AppTheme.surfaceDark : Colors.white).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_destinations.length, (index) {
            final dest = _destinations[index];
            final isActive = index == currentIndex;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onDestinationSelected(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: EdgeInsets.symmetric(
                  horizontal: isActive ? 16 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? dest.activeIcon : dest.icon,
                      size: 22,
                      color: isActive
                          ? AppTheme.primary
                          : (isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF64748B)),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: isActive
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                dest.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),
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
