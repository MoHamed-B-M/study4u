import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

final mockCoursesProvider = Provider<List<Course>>((ref) {
  return [
    Course(
      id: '1',
      code: 'PHY181.6',
      name: 'University Physics I',
      icon: Icons.functions,
      color: const Color(0xFFFFB74D),
    ),
    Course(
      id: '2',
      code: 'EEE181.5',
      name: 'Digital Logic Design',
      icon: Icons.memory,
      color: const Color(0xFF4DB6AC),
    ),
    Course(
      id: '3',
      code: 'CSE181.4',
      name: 'Data Structures',
      icon: Icons.code,
      color: const Color(0xFF7986CB),
    ),
  ];
});

final mockTasksProvider = Provider<List<StudyTask>>((ref) {
  return [
    StudyTask(
      id: '1',
      title: 'Submit Circuit Simulation Lab Report',
      dueDate: DateTime.now().copyWith(hour: 23, minute: 59),
      urgency: TaskUrgency.urgent,
    ),
    StudyTask(
      id: '2',
      title: 'Calculus Assignment #3',
      dueDate: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 10, minute: 0),
      urgency: TaskUrgency.normal,
    ),
  ];
});

final mockScheduleProvider = Provider<List<ScheduleItem>>((ref) {
  return [
    ScheduleItem(
      id: '1',
      title: 'Electrical Circuit Design 1',
      subtitle: 'EEE182.4 • Lab Room 402',
      timeRange: '09:00 AM – 11:30 AM',
      room: '402',
      status: AttendanceStatus.absent,
    ),
    ScheduleItem(
      id: '2',
      title: 'Advanced Mathematics II',
      subtitle: 'MAT201.2 • Lecture Hall 3',
      timeRange: '12:30 PM – 02:00 PM',
      room: 'LH3',
      status: AttendanceStatus.present,
    ),
    ScheduleItem(
      id: '3',
      title: 'Physics Lab: Optics',
      subtitle: 'PHY181.6 • Lab Room 101',
      timeRange: '03:00 PM – 05:00 PM',
      room: '101',
      status: AttendanceStatus.late,
    ),
  ];
});

final mockAttendanceStatsProvider = Provider<AttendanceStats>((ref) {
  return AttendanceStats(
    present: 8,
    absent: 1,
    late: 2,
    percentage: 81.0,
  );
});

final mockPerformanceProvider = Provider<List<SubjectPerformance>>((ref) {
  return [
    SubjectPerformance(
      name: 'Advanced Mathematics',
      percentage: 94.0,
      grade: 'A+',
      lastUpdated: '2 DAYS AGO',
      color: const Color(0xFF4ADE80),
      icon: Icons.calculate_outlined,
    ),
    SubjectPerformance(
      name: 'Data Structures',
      percentage: 88.0,
      grade: 'A',
      lastUpdated: '5 DAYS AGO',
      color: const Color(0xFF2DD4BF),
      icon: Icons.terminal_outlined,
    ),
    SubjectPerformance(
      name: 'Digital Ethics',
      percentage: 76.0,
      grade: 'B+',
      lastUpdated: 'TODAY',
      color: const Color(0xFFFBBF24),
      icon: Icons.gavel_outlined,
    ),
  ];
});
