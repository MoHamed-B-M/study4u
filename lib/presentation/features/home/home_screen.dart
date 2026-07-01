import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import '../../../../shared/providers/logic_providers.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/usecases/schedule_optimizer.dart';
import '../../../../theme/comic_theme.dart';
import '../../../../widgets/comic_card.dart';
import '../../../../widgets/comic_button.dart';
import '../../widgets/add_course_sheet.dart';
import '../../widgets/add_task_sheet.dart';
import '../../widgets/quote_expansion_route.dart';
import '../course_detail/course_detail_screen.dart';
import '../../../core/animation/page_scale.dart' show PageScaleProvider;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(courseListProvider);
    final tasks = ref.watch(taskListProvider);
    final upNext = ref.watch(upNextProvider);
    final greeting = ref.watch(greetingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(greeting),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/settings');
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 320,
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildUpNextPage(context, upNext, courses, ref),
                  _buildTasksPage(context, ref, tasks),
                  _buildQuickStatsPage(context),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildPageIndicator(isDark),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildSectionHeader(context, 'Current Courses', 'View all'),
                  const SizedBox(height: 16),
                  _buildCoursesList(context, courses, ref),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildUpNextPage(BuildContext context, UpNextResult upNext,
      List<CourseEntity> courses, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (upNext.hasNext && upNext.course != null)
              _buildUpNextCard(context, upNext.course!),
            const SizedBox(height: 20),
            _buildSectionHeader(context, 'Quick Overview', null),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ComicCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Column(
                      children: [
                        Icon(Icons.book, color: ComicTheme.inkRed, size: 24),
                        const SizedBox(height: 8),
                        Text('${courses.length}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? ComicTheme.darkText
                                    : ComicTheme.inkBlack)),
                        const SizedBox(height: 2),
                        Text('Courses',
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? ComicTheme.darkText.withValues(alpha: 0.6)
                                    : ComicTheme.inkBlack
                                        .withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ComicCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Column(
                      children: [
                        Icon(Icons.task_alt,
                            color: ComicTheme.inkRed, size: 24),
                        const SizedBox(height: 8),
                        Text('${ref.watch(pendingTaskCountProvider)}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? ComicTheme.darkText
                                    : ComicTheme.inkBlack)),
                        const SizedBox(height: 2),
                        Text('Pending',
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? ComicTheme.darkText.withValues(alpha: 0.6)
                                    : ComicTheme.inkBlack
                                        .withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksPage(
      BuildContext context, WidgetRef ref, List<TaskEntity> tasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Due Tasks', null),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Hooray! No pending tasks.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? ComicTheme.darkText.withValues(alpha: 0.6)
                            : ComicTheme.inkBlack.withValues(alpha: 0.6),
                      )),
                ),
              )
            else
              ...List.generate(tasks.length > 3 ? 3 : tasks.length, (index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ComicCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(taskRepositoryProvider)
                                .toggleTask(task.id);
                            ref.read(dataRefreshProvider.notifier).state++;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: task.isCompleted
                                  ? ComicTheme.inkRed
                                  : Colors.transparent,
                              border: Border.all(
                                color: task.isCompleted
                                    ? ComicTheme.inkRed
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: task.isCompleted
                                ? const Icon(Icons.check,
                                    size: 14, color: ComicTheme.surfaceWhite)
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark
                                      ? ComicTheme.darkText
                                      : ComicTheme.inkBlack,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                DateFormat('MMM dd, hh:mm a')
                                    .format(task.dueDate),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? ComicTheme.darkText
                                            .withValues(alpha: 0.5)
                                        : ComicTheme.inkBlack
                                            .withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                        ),
                        if (task.urgency == TaskUrgency.urgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: ComicTheme.inkRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('URGENT',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: ComicTheme.inkRed)),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            if (tasks.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text('+${tasks.length - 3} more tasks',
                      style: TextStyle(
                          fontSize: 12,
                          color: ComicTheme.inkRed,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsPage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analytics = ref.watch(attendanceAnalyticsResultProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Attendance', null),
            const SizedBox(height: 12),
            ComicCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: CircularProgressIndicator(
                            value: analytics.hasRecords
                                ? analytics.percentage / 100
                                : 0,
                            strokeWidth: 6,
                            backgroundColor: isDark
                                ? ComicTheme.darkText.withValues(alpha: 0.08)
                                : ComicTheme.inkBlack.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              analytics.isBelowThreshold
                                  ? ComicTheme.inkRed
                                  : ComicTheme.inkRed,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          analytics.hasRecords
                              ? '${analytics.percentage.toInt()}%'
                              : '--',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? ComicTheme.darkText
                                  : ComicTheme.inkBlack),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _miniStat(
                                Colors.green, '${analytics.present}', isDark),
                            const SizedBox(width: 16),
                            _miniStat(ComicTheme.inkRed, '${analytics.absent}',
                                isDark),
                            const SizedBox(width: 16),
                            _miniStat(const Color(0xFFF59E0B),
                                '${analytics.late}', isDark),
                          ],
                        ),
                        if (analytics.isBelowThreshold) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: ComicTheme.inkRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Below 75%!',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: ComicTheme.inkRed)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(context, 'Pomodoro', null),
            const SizedBox(height: 12),
            ComicCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined,
                      color: ComicTheme.inkRed, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Focus Timer',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? ComicTheme.darkText
                                    : ComicTheme.inkBlack)),
                        Text('Start a session to track focus',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? ComicTheme.darkText.withValues(alpha: 0.6)
                                    : ComicTheme.inkBlack
                                        .withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: isDark
                          ? ComicTheme.darkText.withValues(alpha: 0.4)
                          : ComicTheme.inkBlack.withValues(alpha: 0.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(Color color, String value, bool isDark) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        SizedBox(
          width: 8,
          height: 8,
          child: Container(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? ComicTheme.inkRed
                  : (isDark
                      ? ComicTheme.darkText.withValues(alpha: 0.24)
                      : ComicTheme.inkBlack.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String? action) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
            )),
        if (action != null)
          ComicButton(
            onPressed: () => HapticFeedback.lightImpact(),
            padding: EdgeInsets.zero,
            child: Text(action,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
      ],
    );
  }

  Widget _buildUpNextCard(BuildContext context, CourseEntity course) {
    final upNextKey = GlobalKey();
    return RepaintBoundary(
      key: upNextKey,
      child: Material(
        color: const Color(0xFFA7F3D0),
        borderRadius: BorderRadius.circular(24),
        elevation: 0,
        shadowColor: const Color(0xFFA7F3D0).withValues(alpha: 0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            HapticFeedback.lightImpact();
            final renderBox =
                upNextKey.currentContext?.findRenderObject() as RenderBox?;
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
                sourceColor: const Color(0xFFA7F3D0),
                pageScaleNotifier: scaleNotifier,
              ));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'UP NEXT',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Icon(Icons.bolt, color: Colors.black87, size: 22),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  course.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.code} \u2022 ${course.room}',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        color: Colors.black87, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${course.startTime} - ${course.endTime}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesList(
      BuildContext context, List<CourseEntity> courses, WidgetRef ref) {
    if (courses.isEmpty) {
      return Text('No courses added yet.',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? ComicTheme.darkText.withValues(alpha: 0.6)
                : ComicTheme.inkBlack.withValues(alpha: 0.6),
          ));
    }
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final course = courses[index];
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 14),
            child: OpenContainer(
              closedColor:
                  isDark ? ComicTheme.darkSurface : ComicTheme.surfaceWhite,
              closedElevation: 0,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isDark
                      ? ComicTheme.surfaceWhite.withValues(alpha: 0.06)
                      : ComicTheme.inkBlack.withValues(alpha: 0.15),
                ),
              ),
              openColor: Theme.of(context).scaffoldBackgroundColor,
              openElevation: 0,
              openShape: const RoundedRectangleBorder(),
              transitionDuration: const Duration(milliseconds: 280),
              closedBuilder: (context, action) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              Color(course.colorValue).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.book,
                          color: Color(course.colorValue),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        course.code,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? ComicTheme.darkText.withValues(alpha: 0.7)
                              : ComicTheme.inkBlack.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isDark
                                ? ComicTheme.darkText.withValues(alpha: 0.4)
                                : ComicTheme.inkBlack.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.startTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? ComicTheme.darkText.withValues(alpha: 0.5)
                                  : ComicTheme.inkBlack.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              openBuilder: (context, closeContainer) {
                return CourseDetailScreen(courseId: course.id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: ComicTheme.surfaceWhite,
          shape: const RoundedRectangleBorder(),
          builder: (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ComicButton(
                    isCta: true,
                    onPressed: () {
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: ComicTheme.surfaceWhite,
                        shape: const RoundedRectangleBorder(),
                        builder: (_) => const AddCourseSheet(),
                      );
                    },
                    child: const Text('Add Course'),
                  ),
                  const SizedBox(height: 8),
                  ComicButton(
                    isCta: true,
                    onPressed: () {
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: ComicTheme.surfaceWhite,
                        shape: const RoundedRectangleBorder(),
                        builder: (_) => const AddTaskSheet(),
                      );
                    },
                    child: const Text('Add Task'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
