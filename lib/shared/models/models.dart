import 'package:flutter/material.dart';

class Course {
  final String id;
  final String code;
  final String name;
  final IconData icon;
  final Color color;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.icon,
    required this.color,
  });
}

enum TaskUrgency { urgent, normal }

class StudyTask {
  final String id;
  final String title;
  final DateTime dueDate;
  final TaskUrgency urgency;
  bool isCompleted;

  StudyTask({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.urgency,
    this.isCompleted = false,
  });
}

enum AttendanceStatus { present, absent, late, upcoming }

class ScheduleItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeRange;
  final String room;
  final AttendanceStatus status;
  final Color? color;

  ScheduleItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeRange,
    required this.room,
    this.status = AttendanceStatus.upcoming,
    this.color,
  });
}

class AttendanceStats {
  final int present;
  final int absent;
  final int late;
  final double percentage;

  AttendanceStats({
    required this.present,
    required this.absent,
    required this.late,
    required this.percentage,
  });
}

class SubjectPerformance {
  final String name;
  final double percentage;
  final String grade;
  final String lastUpdated;
  final Color color;
  final IconData icon;

  SubjectPerformance({
    required this.name,
    required this.percentage,
    required this.grade,
    required this.lastUpdated,
    required this.color,
    required this.icon,
  });
}
