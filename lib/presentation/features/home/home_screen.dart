import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/task.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/add_course_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(courseListProvider);
    final tasks = ref.watch(taskListProvider);
    final pendingCount = ref.watch(pendingTaskCountProvider);
    final upNext = ref.watch(upNextProvider);
    final greeting = ref.watch(greetingProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Text(
                'stdy4u',
                style: GoogleFonts.outfit(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/settings');
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You have $pendingCount pending tasks.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (upNext.hasNext && upNext.course != null)
                    _buildUpNextCard(context, upNext.course!),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Current Courses', 'View all'),
                  const SizedBox(height: 16),
                  _buildCoursesList(context, courses, ref),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Due Tasks', null),
                  const SizedBox(height: 16),
                  _buildTasksList(context, ref, tasks),
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

  Widget _buildSectionHeader(BuildContext context, String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (action != null)
          TextButton(
            onPressed: () => HapticFeedback.lightImpact(),
            child: Text(action, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildUpNextCard(BuildContext context, CourseEntity course) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/course/${course.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF4ADE80),
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ADE80).withValues(alpha: 0.3),
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
                const Icon(Icons.bolt, color: Colors.black87),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              course.name,
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${course.code} \u2022 ${course.room}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black87, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${course.startTime} - ${course.endTime}',
                  style: const TextStyle(
                    color: Colors.black87,
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
      return Text('No courses added yet.', style: Theme.of(context).textTheme.bodyMedium);
    }
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/course/${course.id}');
              },
              onLongPress: () => _showCourseOptions(context, course, ref),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                color: isDark ? AppTheme.surfaceDark : Colors.white,
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
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCourseOptions(BuildContext context, CourseEntity course, WidgetRef ref) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(course.name, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(course.code, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Course'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(ctx);
                  HapticFeedback.lightImpact();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
                    ),
                    builder: (_) => AddCourseSheet(course: course),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outlined, color: Theme.of(context).colorScheme.error),
                title: Text('Delete Course', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteCourse(context, course, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteCourse(BuildContext context, CourseEntity course, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text('Delete ${course.name}?'),
        content: const Text('This will also remove all related attendance records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(courseRepositoryProvider).deleteCourse(course.id);
              ref.read(dataRefreshProvider.notifier).state++;
              Navigator.pop(dCtx);
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, WidgetRef ref, List<TaskEntity> tasks) {
    if (tasks.isEmpty) {
      return Text('Hooray! No pending tasks.', style: Theme.of(context).textTheme.bodyMedium);
    }
    return Column(
      children: List.generate(tasks.length, (index) {
        final task = tasks[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
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
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(task.dueDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: task.urgency == TaskUrgency.urgent
                              ? AppTheme.warningRed
                              : (isDark ? Colors.white38 : AppTheme.textPrimary.withValues(alpha: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.urgency == TaskUrgency.urgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warningRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'URGENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.warningRed,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NORMAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
      ),
    );
  }
}
