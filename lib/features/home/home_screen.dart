import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/providers/logic_providers.dart';
import '../../shared/models/models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, Tareq! 🌅';
    if (hour < 17) return 'Good Afternoon, Tareq! ☀️';
    return 'Good Evening, Tareq! 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(courseListProvider);
    final tasks = ref.watch(taskManagerProvider);
    
    // Logic for "Up Next" - simple simulation for now
    final upNextCourse = courses.isNotEmpty ? courses.first : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: FadeInDown(
                child: Text(
                  'stdy4u',
                  style: GoogleFonts.outfit(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  FadeInLeft(
                    child: Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'You have ${tasks.where((t) => !t.isCompleted).length} pending tasks for today.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (upNextCourse != null)
                    _buildUpNextCard(context, upNextCourse),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Current Courses', 'View all'),
                  const SizedBox(height: 16),
                  _buildCoursesList(courses),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Due Tasks', null),
                  const SizedBox(height: 16),
                  _buildTasksList(ref, tasks),
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
        Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
        if (action != null)
          TextButton(
            onPressed: () {},
            child: Text(action, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildUpNextCard(BuildContext context, Course course) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, Color(0xFF2DD4BF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
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
                  child: const Text('UP NEXT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
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

  Widget _buildCoursesList(List<Course> courses) {
    if (courses.isEmpty) return const Text('No courses added yet.');
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return FadeInRight(
            delay: Duration(milliseconds: 100 * index),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: course.color.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.book, color: course.color),
                    ),
                    const SizedBox(height: 12),
                    Text(course.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(course.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasksList(WidgetRef ref, List<StudyTask> tasks) {
    if (tasks.isEmpty) return const Text('Hooray! No pending tasks.');
    return Column(
      children: List.generate(tasks.length, (index) {
        final task = tasks[index];
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => ref.read(taskManagerProvider.notifier).toggleTask(task.id),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted ? AppTheme.primary : Colors.transparent,
                        border: Border.all(color: task.isCompleted ? AppTheme.primary : AppTheme.textPrimary.withOpacity(0.2), width: 2),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: task.urgency == TaskUrgency.urgent ? AppTheme.error.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(task.urgency == TaskUrgency.urgent ? 'URGENT' : 'NORMAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: task.urgency == TaskUrgency.urgent ? AppTheme.error : AppTheme.primary)),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FadeInUp(
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.textPrimary,
        label: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
