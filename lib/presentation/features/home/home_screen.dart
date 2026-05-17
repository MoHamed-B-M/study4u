import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  HapticFeedback.lightImpact();
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
                    '$greeting!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2),
                  const SizedBox(height: 4),
                  Text(
                    'You have $pendingCount pending tasks.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.2),
                  const SizedBox(height: 24),
                  if (upNext.hasNext && upNext.course != null)
                    _buildUpNextCard(context, upNext.course!)
                        .animate().fadeIn(duration: 500.ms).slideY(begin: 0.3),
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
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                  child: const Text('UP NEXT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                ),
                const Icon(Icons.bolt, color: Colors.white),
              ],
            ),
            const SizedBox(height: 20),
            Text(course.name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${course.code} • ${course.room}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('${course.startTime} - ${course.endTime}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(BuildContext context, List<CourseEntity> courses, WidgetRef ref) {
    if (courses.isEmpty) return Text('No courses added yet.', style: Theme.of(context).textTheme.bodyMedium);
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/course/${course.id}');
              },
              onLongPress: () {
                HapticFeedback.heavyImpact();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Delete ${course.name}?'),
                    content: const Text('This will also remove all related attendance records.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(onPressed: () {
                        ref.read(courseRepositoryProvider).deleteCourse(course.id);
                        ref.read(dataRefreshProvider.notifier).state++;
                        Navigator.pop(ctx);
                      }, child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error))),
                    ],
                  ),
                );
              },
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'course-icon-${course.id}',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Color(course.colorValue).withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.book, color: Color(course.colorValue)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(course.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(course.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
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
    if (tasks.isEmpty) return Text('Hooray! No pending tasks.', style: Theme.of(context).textTheme.bodyMedium);
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
                      color: task.isCompleted ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: TextStyle(fontWeight: FontWeight.w600, decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                      const SizedBox(height: 4),
                      Text(DateFormat('MMM dd, hh:mm a').format(task.dueDate), style: TextStyle(fontSize: 12, color: task.urgency == TaskUrgency.urgent ? AppTheme.error : null)),
                    ],
                  ),
                ),
                PillChip(
                  label: task.urgency == TaskUrgency.urgent ? 'URGENT' : 'NORMAL',
                  color: task.urgency == TaskUrgency.urgent ? AppTheme.error : AppTheme.primary,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (index * 80).ms).slideX(begin: 0.2);
      }),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXXL)),
          ),
          builder: (_) => const AddCourseSheet(),
        );
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }
}
