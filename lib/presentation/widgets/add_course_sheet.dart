import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/course.dart';
import '../../shared/providers/logic_providers.dart';
import '../theme/app_theme.dart';
import 'gradient_button.dart';

class AddCourseSheet extends ConsumerStatefulWidget {
  const AddCourseSheet({super.key});

  @override
  ConsumerState<AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends ConsumerState<AddCourseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _profCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  int _colorValue = AppTheme.primary.value;
  double _targetGrade = 4.0;
  double _creditHours = 3.0;
  final Set<int> _weekDays = {};

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _colors = [
    Color(0xFF4ADE80),
    Color(0xFF2DD4BF),
    Color(0xFFFBBF24),
    Color(0xFF60A5FA),
    Color(0xFFF472B6),
    Color(0xFFA78BFA),
    Color(0xFFFB923C),
    Color(0xFF34D399),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _profCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  String _timeToString(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $ampm';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    final course = CourseEntity(
      id: const Uuid().v4(),
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      professor: _profCtrl.text.trim(),
      room: _roomCtrl.text.trim(),
      startTime: _timeToString(_startTime),
      endTime: _timeToString(_endTime),
      colorValue: _colorValue,
      targetGrade: _targetGrade,
      creditHours: _creditHours,
      scheduleJson: _weekDays.map((d) => _days[d]).toList().toString(),
      weekDays: _weekDays.map((d) => _days[d]).toList(),
    );

    ref.read(courseRepositoryProvider).addCourse(course);
    ref.read(dataRefreshProvider.notifier).state++;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 12,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text('Add Course', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Course Name', hintText: 'e.g. Advanced Mathematics'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(labelText: 'Course Code', hintText: 'e.g. MAT201'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _profCtrl,
                      decoration: const InputDecoration(labelText: 'Professor', hintText: 'Dr. Smith'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _roomCtrl,
                      decoration: const InputDecoration(labelText: 'Room', hintText: 'e.g. LH 3'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      value: _creditHours,
                      decoration: const InputDecoration(labelText: 'Credits'),
                      items: List.generate(6, (i) => (i + 1).toDouble()).map((v) =>
                        DropdownMenuItem(value: v, child: Text('${v.toInt()}'))
                      ).toList(),
                      onChanged: (v) => setState(() => _creditHours = v ?? 3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _timeField('Start Time', _timeToString(_startTime), () => _pickTime(true)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timeField('End Time', _timeToString(_endTime), () => _pickTime(false)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Days of Week', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: List.generate(7, (i) => FilterChip(
                  label: Text(_days[i], style: const TextStyle(fontSize: 12)),
                  selected: _weekDays.contains(i),
                  onSelected: (v) => setState(() => v ? _weekDays.add(i) : _weekDays.remove(i)),
                  selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                )),
              ),
              const SizedBox(height: 16),
              Text('Color', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: _colors.map((c) => GestureDetector(
                  onTap: () => setState(() => _colorValue = c.value),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: _colorValue == c.value ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: _colorValue == c.value
                          ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)]
                          : null,
                    ),
                    child: _colorValue == c.value ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              Text('Target Grade: ${_targetGrade.toStringAsFixed(1)}', style: Theme.of(context).textTheme.labelLarge),
              Slider(
                value: _targetGrade,
                min: 2.0, max: 4.0, divisions: 20,
                label: _targetGrade.toStringAsFixed(1),
                onChanged: (v) => setState(() => _targetGrade = v),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Add Course',
                icon: Icons.book,
                onPressed: _save,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
