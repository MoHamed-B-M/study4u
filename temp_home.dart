import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import '../../../../shared/providers/logic_providers.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/usecases/schedule_optimizer.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/add_course_sheet.dart';
import '../../widgets/squish_button.dart';
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
    final pendingCount = ref.watch(pendingTaskCountProvider);
    final upNext = ref.watch(upNextProvider);
    final greeting = ref.watch(greetingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You have $pendingCount pending tasks.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : AppTheme.textPrimary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      SquishButton(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/settings');
                        },
                        restingRadius: 12,
                        pressedRadius: 8,
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.settings_outlined, color: isDark ? Colors.white54 : AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
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

  Widget _buildUpNextPage(BuildContext context, UpNextResult upNext, List<CourseEntity> courses, WidgetRef ref) {
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
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    color: isDark ? AppTheme.surfaceDark : Colors.white,
                    child: Column(
                      children: [
                        Icon(Icons.book, color: AppTheme.primary, size: 24),
                        const SizedBox(height: 8),
                        Text('${courses.length}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Text('Courses', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : AppTheme.textPrimary.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    color: isDark ? AppTheme.surfaceDark : Colors.white,
                    child: Column(
                      children: [
                        Icon(Icons.task_alt, color: AppTheme.primary, size: 24),
                        const SizedBox(height: 8),
                        Text('${ref.watch(pendingTaskCountProvider)}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Text('Pending', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : AppTheme.textPrimary.withValues(alpha: 0.6))),
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

  Widget _buildTasksPage(BuildContext context, WidgetRef ref, List<TaskEntity> tasks) {
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
                  child: Text('Hooray! No pending tasks.', style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : AppTheme.textPrimary.withValues(alpha: 0.6),
                  )),
                ),
              )
            else
              ...List.generate(tasks.length > 3 ? 3 : tasks.length, (index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    color: isDark ? AppTheme.surfaceDark : Colors.white,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref.read(taskRepositoryProvider).toggleTask(task.id);
                            ref.read(dataRefreshProvider.notifier).state++;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: task.isCompleted ? AppTheme.primary : Colors.transparent,
                              border: Border.all(
                                color: task.isCompleted ? AppTheme.primary : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: task.isCompleted
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
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
                                  color: isDark ? Colors.white : AppTheme.textPrimary,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                DateFormat('MMM dd, hh:mm a').format(task.dueDate),
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppTheme.textPrimary.withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                        ),
                        if (task.urgency == TaskUrgency.urgent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.warningRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('URGENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.warningRed)),
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
                  child: Text('+${tasks.length - 3} more tasks', style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
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
            AppCard(
              padding: const EdgeInsets.all(16),
              color: isDark ? AppTheme.surfaceDark : Colors.white,
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
                            value: analytics.hasRecords ? analytics.percentage / 100 : 0,
                            strokeWidth: 6,
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : AppTheme.textPrimary.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              analytics.isBelowThreshold ? AppTheme.warningRed : AppTheme.primary,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          analytics.hasRecords ? '${analytics.percentage.toInt()}%' : '--',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppTheme.textPrimary),
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
                            _miniStat(Colors.green, '${analytics.present}', isDark),
                            const SizedBox(width: 16),
                            _miniStat(AppTheme.warningRed, '${analytics.absent}', isDark),
                            const SizedBox(width: 16),
                            _miniStat(AppTheme.amberYellow, '${analytics.late}', isDark),
                          ],
                        ),
                        if (analytics.isBelowThreshold) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.warningRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Below 75%!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.warningRed)),
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
            AppCard(
              padding: const EdgeInsets.all(16),
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: AppTheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Focus Timer', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary)),
                        Text('Start a session to track focus', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppTheme.textPrimary.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: isDark ? Colors.white38 : AppTheme.textPrimary.withValues(alpha: 0.4)),
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
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        SizedBox(
          width: 8,
          height: 8,
          child: Container(decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  ? AppTheme.primary
                  : (isDark ? Colors.white24 : AppTheme.textPrimary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String? action) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppTheme.textPrimary,
        )),
        if (action != null)
          TextButton(
            onPressed: () => HapticFeedback.lightImpact(),
            child: Text(action, style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
      ],
    );
  }

  Widget _buildUpNextCard(BuildContext context, CourseEntity course) {
    final upNextKey = GlobalKey();
    return RepaintBoundary(
      key: upNextKey,
      child: SquishButton(
        onTap: () {
          HapticFeedback.lightImpact();
          final renderBox = upNextKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null && renderBox.hasSize) {
            final position = renderBox.localToGlobal(Offset.zero);
            final rect = Rect.fromLTWH(
              position.dx, position.dy,
              renderBox.size.width, renderBox.size.height,
            );
            final scaleNotifier = PageScaleProvider.of(context);
            Navigator.of(context).push(QuoteExpansionRoute(
              sourceRect: rect,
              sourceColor: AppTheme.mintGreenLight,
              pageScaleNotifier: scaleNotifier,
            ));
          }
        },
        padding: const EdgeInsets.all(24),
        backgroundColor: AppTheme.mintGreenLight,
        restingRadius: AppTheme.radiusCard,
        pressedRadius: 14,
        boxShadow: [
          BoxShadow(
            color: AppTheme.mintGreenLight.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              style: GoogleFonts.outfit(
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
                Icon(Icons.access_time_rounded, color: Colors.black87, size: 18),
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
    );
  }

  Widget _buildCoursesList(BuildContext context, List<CourseEntity> courses, WidgetRef ref) {
    if (courses.isEmpty) {
      return Text('No courses added yet.', style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppTheme.textPrimary.withValues(alpha: 0.6),
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
              closedColor: isDark ? AppTheme.surfaceDark : Colors.white,
              closedElevation: 0,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppTheme.outline.withValues(alpha: 0.3),
                ),
              ),
              openColor: Theme.of(context).scaffoldBackgroundColor,
              openElevation: 0,
              openShape: const RoundedRectangleBorder(),
              transitionDuration: const Duration(milliseconds: 280),
              closedBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(course.colorValue).withValues(alpha: 0.15),
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
                          color: isDark ? Colors.white : AppTheme.textPrimary,
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
                          color: isDark ? Colors.white60 : AppTheme.textPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isDark ? Colors.white38 : AppTheme.textPrimary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.startTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : AppTheme.textPrimary.withValues(alpha: 0.5),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surfaceDark,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
            ),
            builder: (_) => const AddCourseSheet(),
          );
        },
        backgroundColor: AppTheme.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Course',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
