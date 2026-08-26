import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:solar_icons/solar_icons.dart';
import '../theme/design_tokens.dart';

class StudyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onAddPressed;

  const StudyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF212121).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: SolarIconsBold.home,
                activeIcon: SolarIconsBold.home,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
              _NavItem(
                icon: SolarIconsBold.chartSquare,
                activeIcon: SolarIconsBold.chartSquare,
                label: 'Stats',
                isActive: currentIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Vibrate.feedback(FeedbackType.light);
                  onAddPressed?.call();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        DesignTokens.primaryLavender,
                        DesignTokens.secondaryBlue
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            DesignTokens.primaryLavender.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    SolarIconsBold.addCircle,
                    color: DesignTokens.textWhite,
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              _NavItem(
                icon: SolarIconsBold.calendar,
                activeIcon: SolarIconsBold.calendar,
                label: 'Tracker',
                isActive: currentIndex == 2,
                onTap: () => onDestinationSelected(2),
              ),
              _NavItem(
                icon: SolarIconsBold.settings,
                activeIcon: SolarIconsBold.settings,
                label: 'Settings',
                isActive: currentIndex == 3,
                onTap: () => onDestinationSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Vibrate.feedback(FeedbackType.selection);
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive
                  ? DesignTokens.primaryLavender
                  : context.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? DesignTokens.primaryLavender
                    : context.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
