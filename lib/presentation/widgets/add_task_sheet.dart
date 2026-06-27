import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../shared/providers/logic_providers.dart';
import '../theme/app_theme.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  final String? courseId;

  const AddTaskSheet({super.key, this.courseId});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TaskUrgency _urgency = TaskUrgency.normal;
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.courseId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final courses = ref.watch(courseListProvider);

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
              child: Text('Add Task',
                  style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'What needs to be done?',
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.courseId == null && courses.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedCourseId,
              decoration: const InputDecoration(
                labelText: 'Course (optional)',
                filled: true,
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('No course'),
                ),
                ...courses.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    )),
              ],
              onChanged: (v) => setState(() => _selectedCourseId = v),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleUrgency,
                  icon: Icon(
                    Icons.flag,
                    size: 18,
                    color: _urgency == TaskUrgency.urgent
                        ? AppTheme.warningRed
                        : null,
                  ),
                  label: Text(
                    _urgency == TaskUrgency.urgent ? 'Urgent' : 'Normal',
                    style: TextStyle(
                      color: _urgency == TaskUrgency.urgent
                          ? AppTheme.warningRed
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _toggleUrgency() {
    setState(() {
      _urgency = _urgency == TaskUrgency.urgent
          ? TaskUrgency.normal
          : TaskUrgency.urgent;
    });
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    final repo = ref.read(taskRepositoryProvider);
    repo.addTask(TaskEntity(
      id: const Uuid().v4(),
      courseId: _selectedCourseId ?? '',
      title: _titleController.text.trim(),
      type: TaskType.task,
      urgency: _urgency,
      dueDate: _dueDate,
    ));
    ref.read(dataRefreshProvider.notifier).state++;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }
}
