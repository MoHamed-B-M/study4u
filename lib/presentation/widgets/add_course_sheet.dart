import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay, DayPeriod;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: DateTime(2024, 1, 1, initial.hour, initial.minute),
                mode: CupertinoDatePickerMode.time,
                onDateTimeChanged: (date) {
                  setState(() {
                    final tod = TimeOfDay(hour: date.hour, minute: date.minute);
                    if (isStart) {
                      _startTime = tod;
                    } else {
                      _endTime = tod;
                    }
                  });
                },
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

  String _timeToString(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $ampm';
  }

  void _save() {
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Course Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _nameCtrl,
              placeholder: 'Course Name',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _codeCtrl,
                    placeholder: 'Course Code',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoTextField(
                    controller: _profCtrl,
                    placeholder: 'Professor',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _roomCtrl,
                    placeholder: 'Room',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoTextField(
                    readOnly: true,
                    controller: TextEditingController(text: '${_creditHours.toInt()}'),
                    placeholder: 'Credits',
                    suffix: GestureDetector(
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (ctx) => Container(
                            height: 200,
                            color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                            child: Column(
                              children: [
                                Expanded(
                                  child: CupertinoPicker(
                                    scrollController: FixedExtentScrollController(
                                      initialItem: _creditHours.toInt() - 1,
                                    ),
                                    itemExtent: 32,
                                    onSelectedItemChanged: (v) {
                                      setState(() => _creditHours = v + 1.0);
                                    },
                                    children: List.generate(6, (i) => Center(child: Text('${i + 1}'))),
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
                      },
                      child: const Icon(CupertinoIcons.chevron_down, size: 16, color: CupertinoColors.systemGrey2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Schedule', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () => _pickTime(true),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.clock, size: 16),
                        const SizedBox(width: 8),
                        Text(_timeToString(_startTime)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    onPressed: () => _pickTime(false),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.clock_fill, size: 16),
                        const SizedBox(width: 8),
                        Text(_timeToString(_endTime)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Days', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final selected = _weekDays.contains(i);
                return CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: selected
                      ? CupertinoTheme.of(context).primaryColor.withOpacity(0.2)
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: () {
                    setState(() {
                      if (selected) {
                        _weekDays.remove(i);
                      } else {
                        _weekDays.add(i);
                      }
                    });
                  },
                  child: Text(
                    _days[i],
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? CupertinoTheme.of(context).primaryColor
                          : CupertinoColors.label,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text('Color & Grade', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Color'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _colors.map((c) {
                              final selected = _colorValue == c.value;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: () => setState(() => _colorValue = c.value),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border: selected
                                          ? Border.all(color: CupertinoColors.label, width: 2.5)
                                          : null,
                                    ),
                                    child: selected
                                        ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.white, size: 14)
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Target Grade'),
                      Expanded(
                        child: CupertinoSlider(
                          value: _targetGrade,
                          min: 2.0,
                          max: 4.0,
                          divisions: 20,
                          onChanged: (v) => setState(() => _targetGrade = v),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          _targetGrade.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: widget.course != null ? 'Save Changes' : 'Add Course',
              icon: CupertinoIcons.book,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
