import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/providers/logic_providers.dart';
import '../../../../presentation/theme/theme_provider.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/task.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/quote_expansion_route.dart';
import '../../../core/animation/page_scale.dart' show PageScaleProvider;

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(courseListProvider);
    final pendingCount = ref.watch(pendingTaskCountProvider);
    final upNext = ref.watch(upNextProvider);
    final greeting = ref.watch(greetingProvider);
    final settings = ref.watch(settingsProvider);
    final userName = settings.userName.isEmpty ? 'Student' : settings.userName;

    final nextCourse = upNext.hasNext ? upNext.course : null;
    final nextProgress = nextCourse != null ? nextCourse.percentage / 100 : 0.0;

    return CupertinoPageScaffold(
      backgroundColor: DesignTokens.background,
      child: Stack(
        children: [
          const BlobBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.spacingLG,
                      DesignTokens.spacingMD,
                      DesignTokens.spacingLG,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'STUDY4U',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: DesignTokens.textTertiary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/settings');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: DesignTokens.surface,
                                      shape: BoxShape.circle,
                                      boxShadow: DesignTokens.cardShadow,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.bell,
                                      size: 18,
                                      color: DesignTokens.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: DesignTokens.textSecondary,
                          ),
                        ).animate().fadeIn(duration: 300.ms),
                        Text(
                          'Hi! $userName',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: DesignTokens.textPrimary,
                            height: 1.2,
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacingLG,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InfoCard(
                                icon: CupertinoIcons.checkmark_seal,
                                iconColor: DesignTokens.cardBlueAccent,
                                backgroundColor: DesignTokens.cardBlue,
                                value: pendingCount.toString(),
                                label: 'Pending Tasks',
                              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTotalCoursesCard(context, courses.length).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (nextCourse != null)
                          _NextClassCardWrapper(
                            course: nextCourse,
                            nextProgress: nextProgress,
                          ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.15),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Courses',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: DesignTokens.textPrimary,
                              ),
                            ),
                            if (courses.length > 3)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                },
                                child: Text(
                                  'See All',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: DesignTokens.primaryLavender,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 140,
                          child: courses.isEmpty
                              ? Center(
                                  child: Text(
                                    'No courses yet. Tap + to add one.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: DesignTokens.textTertiary,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: courses.length,
                                  itemBuilder: (context, index) {
                                    final course = courses[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right: index < courses.length - 1 ? 12 : 0,
                                      ),
                                      child: CourseCard(
                                        code: course.code,
                                        name: course.name,
                                        color: Color(course.colorValue),
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          context.push('/course/${course.id}');
                                        },
                                      ).animate().fadeIn(
                                        duration: 300.ms,
                                        delay: (300 + index * 80).ms,
                                      ).slideX(begin: 0.15),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Today\'s Tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTasksList(context, ref),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCoursesCard(BuildContext context, int count) {
    return DashboardCard(
      backgroundColor: DesignTokens.cardCream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignTokens.cardCreamAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.book,
              size: 18,
              color: DesignTokens.cardCreamAccent,
            ),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Total Courses',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final pending = tasks.where((t) => !t.isCompleted).take(3).toList();

    if (pending.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(DesignTokens.spacingMD),
        decoration: BoxDecoration(
          color: DesignTokens.cardGreen,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignTokens.cardGreenAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.checkmark_seal_fill,
                size: 18,
                color: DesignTokens.cardGreenAccent,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All caught up!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  Text(
                    'No pending tasks right now.',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: pending.map((task) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DashboardCard(
            backgroundColor: DesignTokens.surface,
            padding: const EdgeInsets.all(DesignTokens.spacingMD),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(taskRepositoryProvider).toggleTask(task.id);
                    ref.read(dataRefreshProvider.notifier).state++;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? DesignTokens.primaryLavender
                          : CupertinoColors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? DesignTokens.primaryLavender
                            : DesignTokens.textTertiary,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            CupertinoIcons.check_mark,
                            size: 12,
                            color: DesignTokens.textWhite,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? DesignTokens.textTertiary
                              : DesignTokens.textPrimary,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${task.dueDate.month}/${task.dueDate.day}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: DesignTokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.urgency == TaskUrgency.urgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DesignTokens.cardPink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Urgent',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.cardPinkAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NextClassCardWrapper extends ConsumerStatefulWidget {
  final CourseEntity course;
  final double nextProgress;

  const _NextClassCardWrapper({
    required this.course,
    required this.nextProgress,
  });

  @override
  ConsumerState<_NextClassCardWrapper> createState() => _NextClassCardWrapperState();
}

class _NextClassCardWrapperState extends ConsumerState<_NextClassCardWrapper> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return RepaintBoundary(
      key: _key,
      child: NextClassCard(
        courseName: course.name,
        courseCode: course.code,
        time: '${course.startTime} - ${course.endTime}',
        progress: widget.nextProgress,
        color: Color(course.colorValue),
        onTap: () {
          HapticFeedback.lightImpact();
          final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null && renderBox.hasSize) {
            final position = renderBox.localToGlobal(Offset.zero);
            final rect = Rect.fromLTWH(
              position.dx, position.dy,
              renderBox.size.width, renderBox.size.height,
            );
            final scaleNotifier = PageScaleProvider.of(context);
            Navigator.of(context).push(QuoteExpansionRoute(
              sourceRect: rect,
              sourceColor: Color(course.colorValue),
              pageScaleNotifier: scaleNotifier,
            ));
          }
        },
      ),
    );
  }
}
