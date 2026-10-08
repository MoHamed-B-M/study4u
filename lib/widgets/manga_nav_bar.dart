import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/comic_theme.dart';

class MangaNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final bool enableHaptic;

  const MangaNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ComicTheme.darkSurface : ComicTheme.surfaceWhite,
        border: Border(
          top: BorderSide(color: ComicTheme.inkBlack, width: 3.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Row(
            children: [
              _NavTab(
                icon: Icons.home_outlined,
                label: 'HOME',
                isSelected: selectedIndex == 0,
                onTap: () => onTabChange(0),
                isDark: isDark,
                enableHaptic: enableHaptic,
              ),
              _NavTab(
                icon: Icons.calendar_today_outlined,
                label: 'TRACKER',
                isSelected: selectedIndex == 1,
                onTap: () => onTabChange(1),
                isDark: isDark,
                enableHaptic: enableHaptic,
              ),
              _NavTab(
                icon: Icons.analytics_outlined,
                label: 'STATS',
                isSelected: selectedIndex == 2,
                onTap: () => onTabChange(2),
                isDark: isDark,
                enableHaptic: enableHaptic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final bool enableHaptic;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDark = false,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedColor = isDark ? ComicTheme.darkText : ComicTheme.inkBlack;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (enableHaptic) HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? ComicTheme.inkRed : Colors.transparent,
            border: isSelected
                ? Border.all(color: ComicTheme.inkBlack, width: 2.5)
                : null,
            borderRadius: BorderRadius.zero,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ComicTheme.inkBlack,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? ComicTheme.surfaceWhite : unselectedColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? ComicTheme.surfaceWhite : unselectedColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
