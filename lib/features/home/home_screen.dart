import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/providers/mock_data.dart';
import '../../shared/models/models.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(mockCoursesProvider);
    final tasks = ref.watch(mockTasksProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: AppTheme.surfaceVariant,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=tareq'),
          ),
        ),
        title: Text(
          'stdy4u',
          style: GoogleFonts.outfit(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Text(
                'Hello, Tareq! 👋',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Text(
                'Ready for your Electrical Circuit lab today?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: _buildUpNextCard(context),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'All Courses', 'View all'),
            const SizedBox(height: 16),
            ...List.generate(courses.length, (index) {
              return FadeInRight(
                duration: Duration(milliseconds: 400 + (index * 100)),
                child: _buildCourseCard(context, courses[index]),
              );
            }),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Due Tasks', null),
            const SizedBox(height: 16),
            ...List.generate(tasks.length, (index) {
              return FadeInUp(
                duration: Duration(milliseconds: 500 + (index * 100)),
                child: _buildTaskCard(context, tasks[index]),
              );
            }),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FadeInUp(
        duration: const Duration(milliseconds: 800),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: () {},
            child: Text(
              action,
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUpNextCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearRouteGradient(
          colors: [Color(0xFF006D36), Color(0xFF004D26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'UP NEXT',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(Icons.bolt, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Electrical Circuit Design 1 L',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'EEE182.4 • Lab Room 402',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                '11:30 AM – 1:30 PM',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: course.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(course.icon, color: course.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.code,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    course.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.onSurface.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, StudyTask task) {
    final isUrgent = task.urgency == TaskUrgency.urgent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUrgent ? const Color(0xFF006D36) : AppTheme.outlineVariant,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUrgent ? const Color(0xFFFFDAD6) : const Color(0xFFDEE8FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isUrgent ? 'URGENT' : 'NORMAL',
                          style: GoogleFonts.plusJakartaSans(
                            color: isUrgent ? const Color(0xFF93000A) : const Color(0xFF111C2D),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('EEEE, hh:mm a').format(task.dueDate).replaceAll(DateFormat('EEEE').format(task.dueDate), task.dueDate.day == DateTime.now().day ? 'Today' : 'Tomorrow')}',
                    style: GoogleFonts.plusJakartaSans(
                      color: isUrgent ? Colors.red : AppTheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// LinearRouteGradient doesn't exist, I meant LinearGradient
class LinearRouteGradient extends LinearGradient {
  const LinearRouteGradient({
    required super.colors,
    super.begin = Alignment.centerLeft,
    super.end = Alignment.centerRight,
    super.stops,
    super.tileMode = TileMode.clamp,
    super.transform,
  });
}
