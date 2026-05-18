import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/course_material.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../theme/design_tokens.dart';
import '../../theme/app_theme.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(courseDetailProvider(widget.courseId));
    if (course == null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Course not found')),
        child: const Center(child: Text('This course no longer exists.')),
      );
    }
    final color = Color(course.colorValue);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            CupertinoSlidingSegmentedControl<int>(
              groupValue: _selectedTab,
              onValueChanged: (v) {
                if (v != null) setState(() => _selectedTab = v);
              },
              children: const {
                0: Text('Info'),
                1: Text('Materials'),
                2: Text('Notes'),
                3: Text('Tasks'),
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _InfoTab(course: course),
                  _MaterialsTab(courseId: course.id, color: color),
                  _NotesTab(courseId: course.id),
                  _TasksTab(courseId: course.id),
                ],
              ),
            ),
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

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _InfoCard(
          icon: CupertinoIcons.person,
          label: 'Professor',
          value: course.professor.isEmpty ? 'Not assigned' : course.professor,
        ).animate().fadeIn(duration: 200.ms),
        const SizedBox(height: 16),
        _InfoCard(
          icon: CupertinoIcons.clock,
          label: 'Schedule',
          value: '${course.startTime} - ${course.endTime}',
        ).animate().fadeIn(duration: 200.ms, delay: 50.ms),
        const SizedBox(height: 16),
        _InfoCard(
          icon: CupertinoIcons.location,
          label: 'Room',
          value: course.room.isEmpty ? 'Not set' : course.room,
        ).animate().fadeIn(duration: 200.ms, delay: 100.ms),
        const SizedBox(height: 16),
        _InfoCard(
          icon: CupertinoIcons.book,
          label: 'Credits',
          value: '${course.creditHours.toStringAsFixed(0)} ${course.creditHours == 1 ? 'Credit' : 'Credits'}',
        ).animate().fadeIn(duration: 200.ms, delay: 150.ms),
        const SizedBox(height: 24),
        const Text('Grade Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildGradeSection(context, color),
        const SizedBox(height: 24),
        const Text('Attendance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildAttendanceQuickView(context, ref),
      ],
    );
  }

  Widget _buildGradeSection(BuildContext context, Color color) {
    final percentage = course.percentage;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${course.currentGrade.toStringAsFixed(1)} / ${course.targetGrade.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: percentage >= 80
                      ? CupertinoColors.systemGreen.withOpacity(0.1)
                      : CupertinoColors.systemOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: percentage >= 80
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemOrange,
                  ),
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
              backgroundColor: CupertinoColors.systemGrey5,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceQuickView(BuildContext context, WidgetRef ref) {
    final records = ref.watch(attendanceRecordsProvider);
    final courseRecords = records.where((r) => r.courseId == course.id).toList();
    final present = courseRecords.where((r) => r.status == AttendanceStatus.present).length;
    final total = courseRecords.where((r) => r.status != AttendanceStatus.upcoming).length;
    final rate = total > 0 ? present / total * 100 : 0.0;

    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        child: const Center(
          child: Text('No attendance records yet', style: TextStyle(color: CupertinoColors.systemGrey2)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(CupertinoIcons.checkmark_circle, 'Present', '$present', CupertinoColors.systemGreen),
          Container(width: 1, height: 40, color: CupertinoColors.systemGrey4),
          _buildStat(CupertinoIcons.xmark_circle, 'Absent', '${total - present}', CupertinoColors.systemRed),
          Container(width: 1, height: 40, color: CupertinoColors.systemGrey4),
          _buildStat(CupertinoIcons.chart_bar_alt_fill, 'Rate', '${rate.toStringAsFixed(0)}%', CupertinoTheme.of(context).primaryColor),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CupertinoTheme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: CupertinoTheme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey2)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaterialsTab extends ConsumerWidget {
  final String courseId;
  final Color color;
  const _MaterialsTab({required this.courseId, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materials = ref.watch(courseMaterialsProvider(courseId));
    return Column(
      children: [
        Expanded(
          child: materials.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.folder,
                          size: 48,
                          color: CupertinoColors.systemGrey3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No materials yet',
                        style: TextStyle(color: CupertinoColors.systemGrey2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + to add PDFs, images or links',
                        style: TextStyle(fontSize: 13, color: CupertinoColors.systemGrey3),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final m = materials[index];
                    return _MaterialTile(
                      material: m,
                      onDelete: () {
                        ref.read(materialRepositoryProvider).deleteMaterial(m.id);
                        ref.read(dataRefreshProvider.notifier).state++;
                      },
                    ).animate().fadeIn(duration: 200.ms, delay: (index * 40).ms);
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: CupertinoButton.filled(
            onPressed: () => _showAddMaterialSheet(context, ref),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.add, size: 18),
                SizedBox(width: 8),
                Text('Add Material'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddMaterialSheet(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoPageScaffold(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: _AddMaterialSheet(courseId: courseId),
        ),
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final CourseMaterialEntity material;
  final VoidCallback? onDelete;
  const _MaterialTile({required this.material, this.onDelete});

  String _subtitle(CourseMaterialEntity m) {
    switch (m.type) {
      case 'link':
        return m.content;
      case 'file':
        final uri = Uri.tryParse(m.content);
        final path = uri?.path ?? m.content;
        return path.split('/').last;
      default:
        return DateFormat('MMM dd').format(m.createdAt);
    }
  }

  IconData _icon() {
    switch (material.type) {
      case 'link':
        return CupertinoIcons.link;
      case 'file':
        final ext = material.content.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) return CupertinoIcons.photo;
        if (ext == 'pdf') return CupertinoIcons.doc_richtext;
        return CupertinoIcons.doc;
      default:
        return CupertinoIcons.doc_text;
    }
  }

  void _open(BuildContext context) {
    switch (material.type) {
      case 'link':
        final uri = Uri.tryParse(material.content);
        if (uri != null && uri.isAbsolute) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 'file':
        final file = File(material.content);
        if (file.existsSync()) {
          launchUrl(Uri.file(material.content), mode: LaunchMode.externalApplication);
        } else {
          showCupertinoDialog(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: const Text('File Not Found'),
              content: const Text('File may have been moved.'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _open(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon(), color: CupertinoTheme.of(context).primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(material),
                      style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      CupertinoIcons.trash,
                      size: 18,
                      color: CupertinoColors.systemRed.withOpacity(0.6),
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              if (material.type == 'link' || material.type == 'file')
                const Icon(CupertinoIcons.arrow_up_right, size: 16, color: CupertinoColors.systemGrey3),
            ],
          ),
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
  final _urlController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'link';
  String? _pickedFilePath;
  String? _pickedFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final sourcePath = file.path!;

    final dir = await getApplicationDocumentsDirectory();
    final destDir = Directory('${dir.path}/study4u_materials');
    if (!destDir.existsSync()) destDir.createSync();

    final destPath = '${destDir.path}/${file.name}';
    await File(sourcePath).copy(destPath);

    setState(() {
      _pickedFilePath = destPath;
      _pickedFileName = file.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('Add Material', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          CupertinoSegmentedControl<String>(
            groupValue: _type,
            onValueChanged: (v) => setState(() => _type = v),
            children: const {
              'link': Text('Link'),
              'note': Text('Note'),
              'file': Text('File'),
            },
          ),
          const SizedBox(height: 20),
          CupertinoTextField(
            controller: _titleController,
            placeholder: 'Title',
            prefix: const Icon(CupertinoIcons.textformat, size: 18, color: CupertinoColors.systemGrey2),
          ),
          const SizedBox(height: 16),
          if (_type == 'link')
            CupertinoTextField(
              controller: _urlController,
              placeholder: 'https://...',
              prefix: const Icon(CupertinoIcons.link, size: 18, color: CupertinoColors.systemGrey2),
            ),
          if (_type == 'note')
            CupertinoTextField(
              controller: _noteController,
              placeholder: 'Write your note...',
              maxLines: 3,
            ),
          if (_type == 'file') ...[
            CupertinoButton(
              onPressed: _pickFile,
              child: Text(_pickedFileName ?? 'Pick a file'),
            ),
            if (_pickedFileName != null)
              Row(
                children: [
                  const Icon(CupertinoIcons.checkmark_circle, size: 16, color: CupertinoColors.systemGreen),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _pickedFileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGreen),
                    ),
                  ),
                ],
              ),
          ],
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _submit,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.add, size: 18),
                SizedBox(width: 8),
                Text('Add Material'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    String content;
    switch (_type) {
      case 'link':
        content = _urlController.text.trim();
        break;
      case 'file':
        content = _pickedFilePath ?? '';
        break;
      default:
        content = _noteController.text.trim();
    }

    final repo = ref.read(materialRepositoryProvider);
    repo.addMaterial(CourseMaterialEntity(
      id: const Uuid().v4(),
      courseId: widget.courseId,
      title: _titleController.text.trim(),
      type: _type,
      content: content,
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
    return Column(
      children: [
        Expanded(
          child: notes.isEmpty
              ? Center(
                  child: Text('No notes yet', style: TextStyle(color: CupertinoColors.systemGrey2)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _NoteTile(note: note)
                        .animate()
                        .fadeIn(duration: 200.ms, delay: (index * 40).ms);
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: CupertinoButton.filled(
            onPressed: () => _showAddNoteSheet(context, ref),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.add, size: 18),
                SizedBox(width: 8),
                Text('Add Note'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddNoteSheet(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoPageScaffold(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: _AddNoteSheet(courseId: courseId),
        ),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  final TaskEntity note;
  const _NoteTile({required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(CupertinoIcons.doc_text, color: CupertinoColors.systemOrange, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      note.content,
                      style: TextStyle(fontSize: 13, color: CupertinoColors.systemGrey2),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM dd, yyyy').format(note.dueDate),
                    style: TextStyle(fontSize: 11, color: CupertinoColors.systemGrey3),
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
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('Add Note', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          CupertinoTextField(
            controller: _titleController,
            placeholder: 'Title',
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _contentController,
            placeholder: 'Write your note...',
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _submit,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.add, size: 18),
                SizedBox(width: 8),
                Text('Add Note'),
              ],
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
    return Column(
      children: [
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Text('No tasks yet', style: TextStyle(color: CupertinoColors.systemGrey2)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _TaskTile(task: task)
                        .animate()
                        .fadeIn(duration: 200.ms, delay: (index * 40).ms);
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: CupertinoButton.filled(
            onPressed: () => _showAddTaskSheet(context, ref),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.add, size: 18),
                SizedBox(width: 8),
                Text('Add Task'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddTaskSheet(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoPageScaffold(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: _AddTaskSheet(courseId: courseId),
        ),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  final TaskEntity task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
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
                duration: const Duration(milliseconds: 300),
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
                      color: task.isCompleted
                          ? CupertinoColors.systemGrey2
                          : CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, hh:mm a').format(task.dueDate),
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
            if (task.urgency == TaskUrgency.urgent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: CupertinoColors.systemRed),
                ),
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
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('Add Task', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          CupertinoTextField(
            controller: _titleController,
            placeholder: 'What needs to be done?',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: _pickDate,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.calendar, size: 18),
                      const SizedBox(width: 8),
                      Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CupertinoButton(
                  onPressed: _toggleUrgency,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.flag,
                        size: 18,
                        color: _urgency == TaskUrgency.urgent
                            ? CupertinoColors.systemRed
                            : CupertinoColors.systemGrey2,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _urgency == TaskUrgency.urgent ? 'Urgent' : 'Normal',
                        style: TextStyle(
                          color: _urgency == TaskUrgency.urgent
                              ? CupertinoColors.systemRed
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _submit,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.add, size: 18),
                SizedBox(width: 8),
                Text('Add Task'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: _dueDate,
                minimumDate: DateTime.now(),
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (date) => setState(() => _dueDate = date),
              ),
            ),
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
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
