import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../../presentation/theme/theme_provider.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/task.dart';
import '../../../theme/comic_theme.dart';
import '../../../widgets/comic_card.dart';
import '../../widgets/quote_expansion_route.dart';
import '../../widgets/circular_progress_ring.dart';
import '../../../core/animation/page_scale.dart' show PageScaleProvider;

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(courseListProvider);
    final pendingCount = ref.watch(pendingTaskCountProvider);
    final upNext = ref.watch(upNextProvider);
    final settings = ref.watch(settingsProvider);
    final userName = settings.userName.isEmpty ? 'Student' : settings.userName;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nextCourse = upNext.hasNext ? upNext.course : null;
    final nextProgress = nextCourse != null ? nextCourse.percentage / 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi! $userName'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/settings');
            },
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ComicCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      ComicTheme.inkRed.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.checkmark_seal,
                                  size: 18,
                                  color: ComicTheme.inkRed,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                pendingCount.toString(),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? ComicTheme.darkText
                                      : ComicTheme.inkBlack,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pending Tasks',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? ComicTheme.darkText
                                          .withValues(alpha: 0.7)
                                      : ComicTheme.inkBlack
                                          .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTotalCoursesCard(context, courses.length),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (nextCourse != null)
                    _NextClassCardWrapper(
                      course: nextCourse,
                      nextProgress: nextProgress,
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Courses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? ComicTheme.darkText
                              : ComicTheme.inkBlack,
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
                              color: ComicTheme.inkRed,
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
                                color: isDark
                                    ? ComicTheme.darkText.withValues(alpha: 0.5)
                                    : ComicTheme.inkBlack
                                        .withValues(alpha: 0.5),
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
                                child: ComicCard(
                                  width: 120,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(course.colorValue)
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.menu_book_rounded,
                                            size: 18,
                                            color: Color(course.colorValue)),
                                      ),
                                      const Spacer(),
                                      Text(
                                        course.code,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? ComicTheme.darkText
                                              : ComicTheme.inkBlack,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        course.name,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? ComicTheme.darkText
                                                  .withValues(alpha: 0.7)
                                              : ComicTheme.inkBlack
                                                  .withValues(alpha: 0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Today\'s Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
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
    );
  }

  Widget _buildTotalCoursesCard(BuildContext context, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ComicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ComicTheme.inkRed.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.book,
              size: 18,
              color: ComicTheme.inkRed,
            ),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Total Courses',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? ComicTheme.darkText.withValues(alpha: 0.7)
                  : ComicTheme.inkBlack.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final pending = tasks.where((t) => !t.isCompleted).take(3).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (pending.isEmpty) {
      return ComicCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ComicTheme.inkRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.checkmark_seal_fill,
                size: 18,
                color: ComicTheme.inkRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All caught up!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                    ),
                  ),
                  Text(
                    'No pending tasks right now.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? ComicTheme.darkText.withValues(alpha: 0.7)
                          : ComicTheme.inkBlack.withValues(alpha: 0.7),
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
          child: ComicCard(
            padding: const EdgeInsets.all(16),
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
                          ? ComicTheme.inkRed
                          : CupertinoColors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? ComicTheme.inkRed
                            : (isDark
                                ? ComicTheme.darkText.withValues(alpha: 0.5)
                                : ComicTheme.inkBlack.withValues(alpha: 0.5)),
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            CupertinoIcons.check_mark,
                            size: 12,
                            color: ComicTheme.surfaceWhite,
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
                              ? (isDark
                                  ? ComicTheme.darkText.withValues(alpha: 0.5)
                                  : ComicTheme.inkBlack.withValues(alpha: 0.5))
                              : (isDark
                                  ? ComicTheme.darkText
                                  : ComicTheme.inkBlack),
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${task.dueDate.month}/${task.dueDate.day}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? ComicTheme.darkText.withValues(alpha: 0.5)
                              : ComicTheme.inkBlack.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.urgency == TaskUrgency.urgent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ComicTheme.inkRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Urgent',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: ComicTheme.inkRed,
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
  ConsumerState<_NextClassCardWrapper> createState() =>
      _NextClassCardWrapperState();
}

class _NextClassCardWrapperState extends ConsumerState<_NextClassCardWrapper> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return RepaintBoundary(
      key: _key,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          final renderBox =
              _key.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null && renderBox.hasSize) {
            final position = renderBox.localToGlobal(Offset.zero);
            final rect = Rect.fromLTWH(
              position.dx,
              position.dy,
              renderBox.size.width,
              renderBox.size.height,
            );
            final scaleNotifier = PageScaleProvider.of(context);
            Navigator.of(context).push(QuoteExpansionRoute(
              sourceRect: rect,
              sourceColor: Color(course.colorValue),
              pageScaleNotifier: scaleNotifier,
            ));
          }
        },
        child: ComicCard(
          backgroundColor: Color(course.colorValue),
          padding: const EdgeInsets.all(24),
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
                        color: ComicTheme.surfaceWhite.withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ComicTheme.surfaceWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${course.code} \u2022 ${course.startTime} - ${course.endTime}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ComicTheme.surfaceWhite.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(widget.nextProgress * 100).toInt()}% of semester',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ComicTheme.surfaceWhite.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CircularProgressRing(
                progress: widget.nextProgress,
                size: 72,
                strokeWidth: 6,
                progressColor: ComicTheme.surfaceWhite,
                backgroundColor: ComicTheme.surfaceWhite.withValues(alpha: 0.2),
                label: '${(widget.nextProgress * 100).toInt()}%',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
