import 'package:flutter/cupertino.dart';
import '../theme/design_tokens.dart';
import 'dashboard_card.dart';
import 'circular_progress_ring.dart';

class StudyBarChart extends StatelessWidget {
  final List<BarChartData> data;
  final double maxHeight;
  final Color barColor;
  final String yLabel;
  final double yMax;

  const StudyBarChart({
    super.key,
    required this.data,
    this.maxHeight = 160,
    this.barColor = DesignTokens.primaryLavender,
    this.yLabel = 'GPA',
    this.yMax = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold<double>(0, (max, d) => d.value > max ? d.value : max);
    final effectiveMax = maxVal > 0 ? maxVal : yMax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: maxHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(yMax.toStringAsFixed(1), style: _axisStyle),
                  Text((yMax * 0.75).toStringAsFixed(1), style: _axisStyle),
                  Text((yMax * 0.5).toStringAsFixed(1), style: _axisStyle),
                  Text((yMax * 0.25).toStringAsFixed(1), style: _axisStyle),
                  Text('0.0', style: _axisStyle),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.map((d) {
                    final height = (d.value / effectiveMax) * (maxHeight - 20);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: height.clamp(4.0, double.infinity),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                d.color ?? barColor,
                                (d.color ?? barColor).withValues(alpha: 0.5),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d.label,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textTertiary,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const TextStyle _axisStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: DesignTokens.textTertiary,
  );
}

class BarChartData {
  final String label;
  final double value;
  final Color? color;

  const BarChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

class AttendanceCard extends StatelessWidget {
  final double attendanceRate;
  final String grade;
  final double gradePercentage;
  final VoidCallback? onTap;

  const AttendanceCard({
    super.key,
    required this.attendanceRate,
    required this.grade,
    required this.gradePercentage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      backgroundColor: DesignTokens.primaryLavender,
      borderRadius: DesignTokens.radiusLG,
      onTap: onTap,
      padding: const EdgeInsets.all(DesignTokens.spacingLG),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: DesignTokens.textWhite.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.book,
                        size: 16,
                        color: DesignTokens.textWhite,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Academic Overview',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textWhite,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Grade',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: DesignTokens.textWhite,
                          ),
                        ),
                        Text(
                          grade,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: DesignTokens.textWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: DesignTokens.textWhite,
                          ),
                        ),
                        Text(
                          '${attendanceRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: DesignTokens.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircularProgressRing(
            progress: gradePercentage / 100,
            size: 64,
            strokeWidth: 6,
            progressColor: DesignTokens.textWhite,
            backgroundColor: DesignTokens.textWhite.withValues(alpha: 0.2),
            label: '${gradePercentage.toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }
}

class PomodoroCard extends StatelessWidget {
  final String timerDisplay;
  final bool isActive;
  final int completedSessions;
  final VoidCallback onStartPause;
  final VoidCallback? onReset;

  const PomodoroCard({
    super.key,
    required this.timerDisplay,
    required this.isActive,
    required this.completedSessions,
    required this.onStartPause,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      backgroundColor: DesignTokens.cardPurple,
      borderRadius: DesignTokens.radiusLG,
      padding: const EdgeInsets.all(DesignTokens.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: DesignTokens.cardPurpleAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.timer,
                  size: 16,
                  color: DesignTokens.cardPurpleAccent,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Focus Timer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  timerDisplay,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              MiniProgressRing(
                progress: isActive ? 0.6 : 0.0,
                size: 48,
                color: DesignTokens.cardPurpleAccent,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$completedSessions sessions today',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onStartPause,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [DesignTokens.primaryLavender, DesignTokens.secondaryBlue],
                      ),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.primaryLavender.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                          color: DesignTokens.textWhite,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isActive ? 'Pause' : 'Start Focus',
                          style: const TextStyle(
                            color: DesignTokens.textWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (onReset != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onReset,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DesignTokens.textWhite,
                      shape: BoxShape.circle,
                      boxShadow: DesignTokens.cardShadow,
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_counterclockwise,
                      size: 18,
                      color: DesignTokens.cardPurpleAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
