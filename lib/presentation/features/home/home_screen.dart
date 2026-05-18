import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/task.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/pill_chip.dart';
import '../../widgets/add_course_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(courseListProvider);
    final tasks = ref.watch(taskListProvider);
    final pendingCount = ref.watch(pendingTaskCountProvider);
    final upNext = ref.watch(upNextProvider);
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: const Border(bottom: BorderSide.none),
        leading: Text(
          'stdy4u',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.gear, size: 24),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/settings');
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.bell, size: 24),
              onPressed: () {
                HapticFeedback.lightImpact();
                _showNotificationHistory(context);
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text('Home'),
              border: const Border(bottom: BorderSide.none),
              backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Good morning!',
                      style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2),
                    const SizedBox(height: 4),
                    Text(
                      'You have $pendingCount pending tasks.',
                      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                        color: CupertinoColors.systemGrey2,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.2),
                    const SizedBox(height: 24),
                    if (upNext.hasNext && upNext.course != null)
                      _buildUpNextCard(context, upNext.course!, primaryColor)
                          .animate().fadeIn(duration: 500.ms).slideY(begin: 0.3),
                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'Current Courses'),
                    const SizedBox(height: 16),
                    _buildCoursesList(context, courses, ref),
                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'Due Tasks'),
                    const SizedBox(height: 16),
                    _buildTasksList(context, ref, tasks),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationHistory(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Notifications'),
        message: const Text(
          'Enable notifications in Settings to get reminded about classes, tasks, and pomodoro sessions.',
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Open Notification Settings'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildUpNextCard(BuildContext context, CourseEntity course, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/course/${course.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              AppTheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.24),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'UP NEXT',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Icon(CupertinoIcons.bolt_fill, color: CupertinoColors.white),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              course.name,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${course.code} • ${course.room}',
              style: const TextStyle(color: CupertinoColors.systemGrey5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(CupertinoIcons.clock, color: CupertinoColors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${course.startTime} - ${course.endTime}',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
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
      return Text(
        'No courses added yet.',
        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          color: CupertinoColors.systemGrey2,
        ),
      );
    }
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
          return Container(
            width: 170,
            margin: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/course/${course.id}');
              },
              onLongPress: () {
                HapticFeedback.heavyImpact();
                showCupertinoModalPopup(
                  context: context,
                  builder: (ctx) => CupertinoActionSheet(
                    title: Text(course.name),
                    message: Text(course.code),
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(ctx);
                          HapticFeedback.lightImpact();
                          showCupertinoModalPopup(
                            context: context,
                            builder: (_) => CupertinoPageScaffold(
                              backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
                              child: SafeArea(
                                child: AddCourseSheet(course: course),
                              ),
                            ),
                          );
                        },
                        child: const Text('Edit Course'),
                      ),
                      CupertinoActionSheetAction(
                        isDestructiveAction: true,
                        onPressed: () {
                          Navigator.pop(ctx);
                          HapticFeedback.mediumImpact();
                          showCupertinoDialog(
                            context: context,
                            builder: (dCtx) => CupertinoAlertDialog(
                              title: Text('Delete ${course.name}?'),
                              content: const Text('This will also remove all related attendance records.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(dCtx),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  child: const Text('Delete'),
                                  onPressed: () {
                                    ref.read(courseRepositoryProvider).deleteCourse(course.id);
                                    ref.read(dataRefreshProvider.notifier).state++;
                                    Navigator.pop(dCtx);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Delete Course'),
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      isDefaultAction: true,
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? CupertinoColors.systemGrey6.withOpacity(0.3)
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(course.colorValue),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(course.colorValue).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.book,
                              color: Color(course.colorValue),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            course.code,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            course.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.clock, size: 12, color: CupertinoColors.systemGrey2),
                              const SizedBox(width: 4),
                              Text(
                                course.startTime,
                                style: const TextStyle(fontSize: 11, color: CupertinoColors.systemGrey2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, WidgetRef ref, List<TaskEntity> tasks) {
    if (tasks.isEmpty) {
      return Text(
        'Hooray! No pending tasks.',
        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          color: CupertinoColors.systemGrey2,
        ),
      );
    }
    return Column(
      children: List.generate(tasks.length, (index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(taskRepositoryProvider).toggleTask(task.id);
                    ref.read(dataRefreshProvider.notifier).state++;
                  },
                  child: AnimatedContainer(
                    duration: 300.ms,
                    curve: Curves.easeInOut,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? CupertinoTheme.of(context).primaryColor
                          : CupertinoColors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemGrey3,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(CupertinoIcons.check_mark, size: 16, color: CupertinoColors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${task.dueDate.month}/${task.dueDate.day} ${task.dueDate.hour}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: task.urgency == TaskUrgency.urgent
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemGrey2,
                        ),
                      ),
                    ],
                  ),
                ),
                PillChip(
                  label: task.urgency == TaskUrgency.urgent ? 'URGENT' : 'NORMAL',
                  color: task.urgency == TaskUrgency.urgent
                      ? CupertinoColors.systemRed
                      : AppTheme.primary,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (index * 80).ms).slideX(begin: 0.2);
      }),
    );
  }
}
