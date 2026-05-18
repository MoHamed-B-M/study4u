import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
    this.barColor = AppTheme.primary,
    this.yLabel = 'GPA',
    this.yMax = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                  Text(yMax.toStringAsFixed(1), style: _axisStyle(cs)),
                  Text((yMax * 0.75).toStringAsFixed(1), style: _axisStyle(cs)),
                  Text((yMax * 0.5).toStringAsFixed(1), style: _axisStyle(cs)),
                  Text((yMax * 0.25).toStringAsFixed(1), style: _axisStyle(cs)),
                  Text('0.0', style: _axisStyle(cs)),
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
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
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

  static TextStyle _axisStyle(ColorScheme cs) => TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: cs.onSurfaceVariant,
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
      backgroundColor: AppTheme.primary,
      borderRadius: AppTheme.radiusCard,
      onTap: onTap,
      padding: const EdgeInsets.all(24),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Academic Overview',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          grade,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
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
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${attendanceRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
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
            progressColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
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
    final cs = Theme.of(context).colorScheme;

    return DashboardCard(
      backgroundColor: cs.surfaceContainerLow,
      borderRadius: AppTheme.radiusCard,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Focus Timer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
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
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              MiniProgressRing(
                progress: isActive ? 0.6 : 0.0,
                size: 48,
                color: AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$completedSessions sessions today',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onStartPause,
                  icon: Icon(isActive ? Icons.pause : Icons.play_arrow),
                  label: Text(isActive ? 'Pause' : 'Start Focus'),
                ),
              ),
              if (onReset != null) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.surfaceContainerHighest,
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
