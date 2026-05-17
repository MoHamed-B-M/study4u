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
  final CourseEntity? course;
  const AddCourseSheet({super.key, this.course});

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
  void initState() {
    super.initState();
    if (widget.course != null) {
      final c = widget.course!;
      _nameCtrl.text = c.name;
      _codeCtrl.text = c.code;
      _profCtrl.text = c.professor;
      _roomCtrl.text = c.room;
      _startTime = _parseTime(c.startTime);
      _endTime = _parseTime(c.endTime);
      _colorValue = c.colorValue;
      _targetGrade = c.targetGrade;
      _creditHours = c.creditHours;
      _weekDays.addAll(c.weekDays.map((d) => _days.indexOf(d)).where((i) => i >= 0));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _profCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(' ');
    final time = parts[0].split(':');
    int hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    if (parts.length > 1) {
      if (parts[1] == 'PM' && hour != 12) hour += 12;
      if (parts[1] == 'AM' && hour == 12) hour = 0;
    }
    return TimeOfDay(hour: hour, minute: minute);
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

    final id = widget.course?.id ?? const Uuid().v4();

    final course = CourseEntity(
      id: id,
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

    if (widget.course != null) {
      ref.read(courseRepositoryProvider).updateCourse(course);
    } else {
      ref.read(courseRepositoryProvider).addCourse(course);
    }
    ref.read(dataRefreshProvider.notifier).state++;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = TextStyle(
      fontSize: 13,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.course != null ? 'Edit Course' : 'Add Course',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              _sectionHeader('Course Details'),
              const SizedBox(height: 8),
              _groupedCard(theme, [
                _groupedRow(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Course Name',
                      labelStyle: labelStyle,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                _divider(theme),
                _groupedRow(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeCtrl,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Course Code',
                            labelStyle: labelStyle,
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _profCtrl,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Professor',
                            labelStyle: labelStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _divider(theme),
                _groupedRow(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _roomCtrl,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Room',
                            labelStyle: labelStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          value: _creditHours,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Credits',
                            labelStyle: labelStyle,
                          ),
                          items: List.generate(6, (i) => (i + 1).toDouble())
                              .map((v) => DropdownMenuItem(
                                  value: v, child: Text('${v.toInt()}')))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _creditHours = v ?? 3),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              _sectionHeader('Schedule'),
              const SizedBox(height: 8),
              _groupedCard(theme, [
                _groupedRow(
                  child: Row(
                    children: [
                      Expanded(
                        child: _timeField(
                            'Start Time', _timeToString(_startTime),
                            () => _pickTime(true), labelStyle),
                      ),
                      Expanded(
                        child: _timeField(
                            'End Time', _timeToString(_endTime),
                            () => _pickTime(false), labelStyle),
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              _sectionHeader('Days'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (i) => FilterChip(
                  label: Text(_days[i], style: const TextStyle(fontSize: 12)),
                  selected: _weekDays.contains(i),
                  onSelected: (v) =>
                      setState(() => v ? _weekDays.add(i) : _weekDays.remove(i)),
                  selectedColor:
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                  checkmarkColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                )),
              ),

              const SizedBox(height: 24),

              _sectionHeader('Color & Grade'),
              const SizedBox(height: 8),
              _groupedCard(theme, [
                _groupedRow(
                  child: Row(
                    children: [
                      Text('Color',
                          style: GoogleFonts.outfit(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _colors.map((c) {
                              final selected = _colorValue == c.value;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _colorValue = c.value),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border: selected
                                          ? Border.all(
                                              color:
                                                  theme.colorScheme.onSurface,
                                              width: 2.5)
                                          : null,
                                    ),
                                    child: selected
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 14)
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _divider(theme),
                _groupedRow(
                  child: Row(
                    children: [
                      Text('Target Grade',
                          style: GoogleFonts.outfit(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                      Expanded(
                        child: Slider(
                          value: _targetGrade,
                          min: 2.0,
                          max: 4.0,
                          divisions: 20,
                          label: _targetGrade.toStringAsFixed(1),
                          onChanged: (v) =>
                              setState(() => _targetGrade = v),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          _targetGrade.toStringAsFixed(1),
                          style: GoogleFonts.outfit(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 24),
              GradientButton(
                label: widget.course != null ? 'Save Changes' : 'Add Course',
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

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _groupedCard(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _groupedRow({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }

  Widget _divider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }

  Widget _timeField(
      String label, String value, VoidCallback onTap, TextStyle labelStyle) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: labelStyle,
        ),
        child: Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
