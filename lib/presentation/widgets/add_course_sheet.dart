import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/course.dart';
import '../../shared/providers/logic_providers.dart';
import '../theme/app_theme.dart';

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
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text('Course Details', style: Theme.of(context).textTheme.titleLarge)),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: 'Course Name', filled: true),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _codeCtrl, decoration: InputDecoration(labelText: 'Course Code', filled: true))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _profCtrl, decoration: InputDecoration(labelText: 'Professor', filled: true))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _roomCtrl, decoration: InputDecoration(labelText: 'Room', filled: true))),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: '${_creditHours.toInt()}'),
                    decoration: InputDecoration(
                      labelText: 'Credits',
                      filled: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.expand_more, size: 20),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => SizedBox(
                              height: 220,
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    width: 40, height: 4,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.grey[600] : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListWheelScrollView(
                                      itemExtent: 40,
                                      useMagnifier: true,
                                      magnification: 1.2,
                                      children: List.generate(6, (i) {
                                        final credits = i + 1;
                                        return Center(child: Text('$credits', style: Theme.of(context).textTheme.titleMedium));
                                      }),
                                      onSelectedItemChanged: (v) => setState(() => _creditHours = v + 1.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: FilledButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Done'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Schedule', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(true),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(_timeToString(_startTime)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(false),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(_timeToString(_endTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Days', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(7, (i) {
                final selected = _weekDays.contains(i);
                return FilterChip(
                  label: Text(_days[i]),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) _weekDays.add(i);
                      else _weekDays.remove(i);
                    });
                  },
                  showCheckmark: selected,
                );
              }),
            ),
            const SizedBox(height: 20),
            Text('Color & Grade', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: cs.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 32, height: 32,
                                      decoration: BoxDecoration(
                                        color: c, shape: BoxShape.circle,
                                        border: selected ? Border.all(color: cs.onSurface, width: 2.5) : null,
                                      ),
                                      child: selected
                                          ? Icon(Icons.check, size: 16, color: cs.surface)
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
                          child: Slider(
                            value: _targetGrade,
                            min: 2.0, max: 4.0, divisions: 20,
                            onChanged: (v) => setState(() => _targetGrade = v),
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(_targetGrade.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(widget.course != null ? 'Save Changes' : 'Add Course'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
