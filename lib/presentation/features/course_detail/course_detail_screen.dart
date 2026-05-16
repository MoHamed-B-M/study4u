import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/course_material.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../theme/app_theme.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(courseDetailProvider(widget.courseId));
    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course not found')),
        body: const Center(child: Text('This course no longer exists.')),
      );
    }
    final color = Color(course.colorValue);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            floating: false,
            stretch: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Hero(
                          tag: 'course-icon-${course.id}',
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.book, size: 32, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(course.name,
                          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text('${course.code} ${course.room.isNotEmpty ? '• ${course.room}' : ''}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: scheme.primary,
                  unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.5),
                  indicatorColor: scheme.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12),
                  tabs: const [
                    Tab(text: 'Info', icon: Icon(Icons.info_outline, size: 18)),
                    Tab(text: 'Materials', icon: Icon(Icons.folder_outlined, size: 18)),
                    Tab(text: 'Notes', icon: Icon(Icons.note_alt_outlined, size: 18)),
                    Tab(text: 'Tasks', icon: Icon(Icons.checklist_outlined, size: 18)),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            _InfoTab(course: course),
            _MaterialsTab(courseId: course.id),
            _NotesTab(courseId: course.id),
            _TasksTab(courseId: course.id),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends ConsumerWidget {
  final CourseEntity course;
  const _InfoTab({required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(course.colorValue);
    final style = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _InfoCard(
          icon: Icons.person_outline,
          label: 'Professor',
          value: course.professor.isEmpty ? 'Not assigned' : course.professor,
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2),
        const SizedBox(height: 16),
        _InfoCard(
          icon: Icons.access_time,
          label: 'Schedule',
          value: '${course.startTime} - ${course.endTime}',
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: 0.2),
        const SizedBox(height: 16),
        _InfoCard(
          icon: Icons.meeting_room_outlined,
          label: 'Room',
          value: course.room.isEmpty ? 'Not set' : course.room,
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideX(begin: 0.2),
        const SizedBox(height: 16),
        _InfoCard(
          icon: Icons.school_outlined,
          label: 'Credits',
          value: '${course.creditHours.toStringAsFixed(0)} ${course.creditHours == 1 ? 'Credit' : 'Credits'}',
        ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideX(begin: 0.2),
        const SizedBox(height: 24),
        Text('Grade Progress', style: style.titleLarge),
        const SizedBox(height: 12),
        _buildGradeSection(context, color),
        const SizedBox(height: 24),
        Text('Attendance', style: style.titleLarge),
        const SizedBox(height: 12),
              _buildAttendanceQuickView(context, ref),
      ],
    );
  }

  Widget _buildGradeSection(BuildContext context, Color color) {
    final percentage = course.percentage;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${course.currentGrade.toStringAsFixed(1)} / ${course.targetGrade.toStringAsFixed(1)}',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: scheme.onSurface),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: percentage >= 80 ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: percentage >= 80 ? Colors.green : Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 10,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceQuickView(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final records = ref.watch(attendanceRecordsProvider);
    final courseRecords = records.where((r) => r.courseId == course.id).toList();
    final present = courseRecords.where((r) => r.status == AttendanceStatus.present).length;
    final total = courseRecords.where((r) => r.status != AttendanceStatus.upcoming).length;
    final rate = total > 0 ? present / total * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(Icons.check_circle_outline, 'Present', '$present', Colors.green),
          Container(width: 1, height: 40, color: scheme.outlineVariant),
          _buildStat(Icons.cancel_outlined, 'Absent', '${total - present}', Colors.red.shade300),
          Container(width: 1, height: 40, color: scheme.outlineVariant),
          _buildStat(Icons.trending_up, 'Rate', '${rate.toStringAsFixed(0)}%', scheme.primary),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7))),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: scheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.5))),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaterialsTab extends ConsumerWidget {
  final String courseId;
  const _MaterialsTab({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materials = ref.watch(courseMaterialsProvider(courseId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: materials.isEmpty
          ? Center(child: Text('No materials yet', style: Theme.of(context).textTheme.bodyMedium))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final m = materials[index];
                return _MaterialTile(material: m)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 80).ms)
                    .slideX(begin: 0.2);
              },
            ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showAddMaterialSheet(context, ref),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMaterialSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXXL)),
      ),
      builder: (_) => _AddMaterialSheet(courseId: courseId),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final CourseMaterialEntity material;
  const _MaterialTile({required this.material});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (material.type) {
      'link' => Icons.link,
      'file' => Icons.description_outlined,
      _ => Icons.article_outlined,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(material.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    material.type == 'link' ? material.content : DateFormat('MMM dd').format(material.createdAt),
                    style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.5)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _AddMaterialSheet extends ConsumerStatefulWidget {
  final String courseId;
  const _AddMaterialSheet({required this.courseId});

  @override
  ConsumerState<_AddMaterialSheet> createState() => _AddMaterialSheetState();
}

class _AddMaterialSheetState extends ConsumerState<_AddMaterialSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _type = 'link';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add Material', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'link', label: Text('Link'), icon: Icon(Icons.link, size: 16)),
              ButtonSegment(value: 'note', label: Text('Note'), icon: Icon(Icons.article, size: 16)),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() => _type = v.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title', hintText: 'e.g. Lecture 1 Notes'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: _type == 'link' ? 'URL' : 'Content',
              hintText: _type == 'link' ? 'https://...' : 'Write your note...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add),
              label: const Text('Add Material'),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    final repo = ref.read(materialRepositoryProvider);
    repo.addMaterial(CourseMaterialEntity(
      id: const Uuid().v4(),
      courseId: widget.courseId,
      title: _titleController.text.trim(),
      type: _type,
      content: _contentController.text.trim(),
    ));
    ref.read(dataRefreshProvider.notifier).state++;
    Navigator.of(context).pop();
  }
}

class _NotesTab extends ConsumerWidget {
  final String courseId;
  const _NotesTab({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(courseNotesProvider(courseId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: notes.isEmpty
          ? Center(child: Text('No notes yet', style: Theme.of(context).textTheme.bodyMedium))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _NoteTile(note: note)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 80).ms)
                    .slideX(begin: 0.2);
              },
            ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showAddNoteSheet(context, ref),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddNoteSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXXL)),
      ),
      builder: (_) => _AddNoteSheet(courseId: courseId),
    );
  }
}

class _NoteTile extends StatelessWidget {
  final TaskEntity note;
  const _NoteTile({required this.note});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.note_alt_outlined, color: scheme.tertiary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(note.content, style: TextStyle(fontSize: 13, color: scheme.onSurface.withValues(alpha: 0.6))),
                  ],
                  const SizedBox(height: 6),
                  Text(DateFormat('MMM dd, yyyy').format(note.dueDate),
                    style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.4)),
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

class _AddNoteSheet extends ConsumerStatefulWidget {
  final String courseId;
  const _AddNoteSheet({required this.courseId});

  @override
  ConsumerState<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<_AddNoteSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add Note', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title', hintText: 'Note title'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: 'Content', hintText: 'Write your note...'),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    final repo = ref.read(taskRepositoryProvider);
    repo.addTask(TaskEntity(
      id: const Uuid().v4(),
      courseId: widget.courseId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: TaskType.note,
      dueDate: DateTime.now(),
    ));
    ref.read(dataRefreshProvider.notifier).state++;
    Navigator.of(context).pop();
  }
}

class _TasksTab extends ConsumerWidget {
  final String courseId;
  const _TasksTab({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(courseTasksProvider(courseId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: tasks.isEmpty
          ? Center(child: Text('No tasks yet', style: Theme.of(context).textTheme.bodyMedium))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _TaskTile(task: task)
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 80).ms)
                    .slideX(begin: 0.2);
              },
            ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showAddTaskSheet(context, ref),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXXL)),
      ),
      builder: (_) => _AddTaskSheet(courseId: courseId),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  final TaskEntity task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
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
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? scheme.primary : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted ? scheme.primary : scheme.outlineVariant,
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
                  Text(task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? scheme.onSurface.withValues(alpha: 0.5) : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(DateFormat('MMM dd, hh:mm a').format(task.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: task.urgency == TaskUrgency.urgent
                          ? AppTheme.error
                          : scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (task.urgency == TaskUrgency.urgent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('URGENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.error)),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  final String courseId;
  const _AddTaskSheet({required this.courseId});

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _titleController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TaskUrgency _urgency = TaskUrgency.normal;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add Task', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Task', hintText: 'What needs to be done?'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleUrgency,
                  icon: Icon(Icons.flag, size: 18,
                    color: _urgency == TaskUrgency.urgent ? AppTheme.error : null),
                  label: Text(_urgency == TaskUrgency.urgent ? 'Urgent' : 'Normal'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: _urgency == TaskUrgency.urgent
                        ? const BorderSide(color: AppTheme.error)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  void _toggleUrgency() {
    setState(() {
      _urgency = _urgency == TaskUrgency.urgent ? TaskUrgency.normal : TaskUrgency.urgent;
    });
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    final repo = ref.read(taskRepositoryProvider);
    repo.addTask(TaskEntity(
      id: const Uuid().v4(),
      courseId: widget.courseId,
      title: _titleController.text.trim(),
      type: TaskType.task,
      urgency: _urgency,
      dueDate: _dueDate,
    ));
    ref.read(dataRefreshProvider.notifier).state++;
    Navigator.of(context).pop();
  }
}
