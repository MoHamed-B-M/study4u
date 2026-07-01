import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/course_material.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../theme/comic_theme.dart';
import '../../../widgets/comic_card.dart';
import '../../../widgets/comic_button.dart';
import '../../widgets/add_course_sheet.dart';
import '../../widgets/add_task_sheet.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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

  void _handleEditCourse() {
    final course = ref.read(courseDetailProvider(widget.courseId));
    if (course == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(24)),
      ),
      builder: (_) => AddCourseSheet(course: course),
    );
  }

  void _handleDeleteCourse() {
    final course = ref.read(courseDetailProvider(widget.courseId));
    if (course == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.name}"?'),
        actions: [
          ComicButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ComicButton(
            isCta: true,
            onPressed: () {
              ref.read(courseRepositoryProvider).deleteCourse(course.id);
              NotificationService.instance
                  .cancelNotification(course.id.hashCode);
              Navigator.of(ctx).pop();
              Navigator.of(context).maybePop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(course.name, style: Theme.of(context).textTheme.titleLarge),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _handleEditCourse();
                case 'delete':
                  _handleDeleteCourse();
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            elevation: 4,
            surfaceTintColor: Colors.transparent,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 20, color: Theme.of(context).colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text('Edit', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 20, color: ComicTheme.inkRed),
                    const SizedBox(width: 12),
                    Text('Delete',
                        style: TextStyle(color: ComicTheme.inkRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Materials'),
            Tab(text: 'Notes'),
            Tab(text: 'Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InfoTab(course: course),
          _MaterialsTab(courseId: course.id, color: color),
          _NotesTab(courseId: course.id),
          _TasksTab(courseId: course.id),
        ],
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
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
            icon: Icons.person_outline,
            label: 'Professor',
            value:
                course.professor.isEmpty ? 'Not assigned' : course.professor),
        const SizedBox(height: 12),
        _InfoCard(
            icon: Icons.schedule_outlined,
            label: 'Schedule',
            value: '${course.startTime} - ${course.endTime}'),
        const SizedBox(height: 12),
        _InfoCard(
            icon: Icons.location_on_outlined,
            label: 'Room',
            value: course.room.isEmpty ? 'Not set' : course.room),
        const SizedBox(height: 12),
        _InfoCard(
            icon: Icons.menu_book_outlined,
            label: 'Credits',
            value:
                '${course.creditHours.toStringAsFixed(0)} ${course.creditHours == 1 ? 'Credit' : 'Credits'}'),
        const SizedBox(height: 24),
        Text('Grade Progress', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _buildGradeSection(context, cs, color),
        const SizedBox(height: 24),
        Text('Attendance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _buildAttendanceQuickView(context, ref),
      ],
    );
  }

  Widget _buildGradeSection(BuildContext context, ColorScheme cs, Color color) {
    final percentage = course.percentage;
    return ComicCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${course.currentGrade.toStringAsFixed(1)} / ${course.targetGrade.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: percentage >= 80
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: percentage >= 80 ? Colors.green : Colors.orange,
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
              backgroundColor: cs.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceQuickView(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final records = ref.watch(attendanceRecordsProvider);
    final courseRecords =
        records.where((r) => r.courseId == course.id).toList();
    final present =
        courseRecords.where((r) => r.status == AttendanceStatus.present).length;
    final total = courseRecords
        .where((r) => r.status != AttendanceStatus.upcoming)
        .length;
    final rate = total > 0 ? present / total * 100 : 0.0;

    if (total == 0) {
      return ComicCard(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(16),
        child: const Center(child: Text('No attendance records yet')),
      );
    }

    return ComicCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(Icons.check_circle_outline, 'Present', '$present',
              Colors.green),
          Container(width: 1, height: 40, color: cs.outlineVariant),
          _buildStat(Icons.cancel_outlined, 'Absent', '${total - present}',
              ComicTheme.inkRed),
          Container(width: 1, height: 40, color: cs.outlineVariant),
          _buildStat(Icons.trending_up, 'Rate', '${rate.toStringAsFixed(0)}%',
              cs.primary),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ComicCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
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
                          color:
                              Theme.of(context).colorScheme.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.folder_outlined,
                            size: 48,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      Text('No materials yet',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('Tap + to add PDFs, images or links',
                          style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final m = materials[index];
                    return _MaterialTile(
                      material: m,
                      onDelete: () {
                        ref
                            .read(materialRepositoryProvider)
                            .deleteMaterial(m.id);
                        ref.read(dataRefreshProvider.notifier).state++;
                      },
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ComicButton(
            isCta: true,
            onPressed: () => _showAddMaterialSheet(context, ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 18, color: ComicTheme.surfaceWhite),
                const SizedBox(width: 8),
                const Text('Add Material'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddMaterialSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddMaterialSheet(courseId: courseId),
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
        return Icons.link;
      case 'file':
        final ext = material.content.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext))
          return Icons.image_outlined;
        if (ext == 'pdf') return Icons.picture_as_pdf;
        return Icons.description_outlined;
      default:
        return Icons.article_outlined;
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
          launchUrl(Uri.file(material.content),
              mode: LaunchMode.externalApplication);
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('File Not Found'),
              content: const Text('File may have been moved.'),
              actions: [
                ComicButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'))
              ],
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ComicCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon(), color: cs.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(material),
                      style:
                          TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: ComicTheme.inkRed.withOpacity(0.6)),
                ),
              if (material.type == 'link' || material.type == 'file')
                Icon(Icons.open_in_new, size: 16, color: cs.onSurfaceVariant),
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
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'txt'
      ],
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Icon(Icons.horizontal_rule,
                  color: cs.onSurfaceVariant, size: 32)),
          Center(
              child: Text('Add Material',
                  style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 20),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'link', label: Text('Link'), icon: Icon(Icons.link)),
              ButtonSegment(
                  value: 'note',
                  label: Text('Note'),
                  icon: Icon(Icons.note_outlined)),
              ButtonSegment(
                  value: 'file',
                  label: Text('File'),
                  icon: Icon(Icons.attach_file)),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() => _type = v.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              filled: true,
              prefixIcon: const Icon(Icons.text_fields),
            ),
          ),
          const SizedBox(height: 16),
          if (_type == 'link')
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                filled: true,
                prefixIcon: const Icon(Icons.link),
              ),
            ),
          if (_type == 'note')
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Write your note...',
                filled: true,
              ),
              maxLines: 3,
            ),
          if (_type == 'file') ...[
            ComicButton(
              onPressed: _pickFile,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload_file, size: 18, color: ComicTheme.inkBlack),
                  const SizedBox(width: 8),
                  Text(_pickedFileName ?? 'Pick a file'),
                ],
              ),
            ),
            if (_pickedFileName != null)
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _pickedFileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.green),
                    ),
                  ),
                ],
              ),
          ],
          const SizedBox(height: 24),
          ComicButton(
            isCta: true,
            onPressed: _submit,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 18, color: ComicTheme.surfaceWhite),
                const SizedBox(width: 8),
                const Text('Add Material'),
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
                  child: Text('No notes yet',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: notes.length,
                  itemBuilder: (context, index) =>
                      _NoteTile(note: notes[index]),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ComicButton(
            isCta: true,
            onPressed: () => _showAddNoteSheet(context, ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 18, color: ComicTheme.surfaceWhite),
                const SizedBox(width: 8),
                const Text('Add Note'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddNoteSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddNoteSheet(courseId: courseId),
    );
  }
}

class _NoteTile extends StatelessWidget {
  final TaskEntity note;
  const _NoteTile({required this.note});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ComicCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFFBBF24).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.article_outlined,
                  color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(note.content,
                        style: TextStyle(
                            fontSize: 13, color: cs.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM dd, yyyy').format(note.dueDate),
                    style:
                        TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Icon(Icons.horizontal_rule,
                  color: cs.onSurfaceVariant, size: 32)),
          Center(
              child: Text('Add Note',
                  style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title', filled: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
                labelText: 'Write your note...', filled: true),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          ComicButton(
            isCta: true,
            onPressed: _submit,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 18, color: ComicTheme.surfaceWhite),
                const SizedBox(width: 8),
                const Text('Add Note'),
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
                  child: Text('No tasks yet',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) =>
                      _TaskTile(task: tasks[index]),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ComicButton(
            isCta: true,
            onPressed: () => _showAddTaskSheet(context, ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 18, color: ComicTheme.surfaceWhite),
                const SizedBox(width: 8),
                const Text('Add Task'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddTaskSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddTaskSheet(courseId: courseId),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  final TaskEntity task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ComicCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
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
                  color: task.isCompleted ? cs.primary : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted ? cs.primary : cs.outline,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? Icon(Icons.check, size: 16, color: cs.surface)
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
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted
                          ? cs.onSurfaceVariant
                          : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, hh:mm a').format(task.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: task.urgency == TaskUrgency.urgent
                          ? ComicTheme.inkRed
                          : cs.onSurfaceVariant,
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
                  color: ComicTheme.inkRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: ComicTheme.inkRed),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
