import 'package:flutter/cupertino.dart';
import '../theme/design_tokens.dart';
import 'circular_progress_ring.dart';

class DashboardCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const DashboardCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(DesignTokens.spacingMD),
      decoration: BoxDecoration(
        color: backgroundColor ?? DesignTokens.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? DesignTokens.radiusMD),
        boxShadow: DesignTokens.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String code;
  final String name;
  final Color color;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.code,
    required this.name,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      backgroundColor: color.withValues(alpha: 0.1),
      width: 120,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(CupertinoIcons.book, size: 18, color: color),
          ),
          const Spacer(),
          Text(
            code,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: DesignTokens.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: DesignTokens.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class NextClassCard extends StatelessWidget {
  final String courseName;
  final String courseCode;
  final String time;
  final double progress;
  final Color color;
  final VoidCallback? onTap;

  const NextClassCard({
    super.key,
    required this.courseName,
    required this.courseCode,
    required this.time,
    required this.progress,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      backgroundColor: color,
      borderRadius: DesignTokens.radiusLG,
      onTap: onTap,
      padding: const EdgeInsets.all(DesignTokens.spacingLG),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Class',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textWhite.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  courseName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textWhite,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$courseCode • $time',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.textWhite.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(progress * 100).toInt()}% of semester',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textWhite.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircularProgressRing(
            progress: progress,
            size: 72,
            strokeWidth: 6,
            progressColor: DesignTokens.textWhite,
            backgroundColor: DesignTokens.textWhite.withValues(alpha: 0.2),
            label: '${(progress * 100).toInt()}%',
          ),
        ],
      ),
    );
  }
}

class BlobBackground extends StatelessWidget {
  const BlobBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    DesignTokens.blobOrange.withValues(alpha: 0.15),
                    DesignTokens.blobOrange.withValues(alpha: 0.02),
                    CupertinoColors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    DesignTokens.blobPurple.withValues(alpha: 0.1),
                    DesignTokens.blobPurple.withValues(alpha: 0.02),
                    CupertinoColors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    DesignTokens.blobPink.withValues(alpha: 0.08),
                    DesignTokens.blobPink.withValues(alpha: 0.01),
                    CupertinoColors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
