import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
class Course extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String code;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String room;
  @HiveField(11)
  final String professor;
  @HiveField(4)
  final String startTime;
  @HiveField(5)
  final String endTime;
  @HiveField(6)
  final int colorValue;
  @HiveField(7)
  final double targetGrade;
  @HiveField(8)
  final double currentGrade;
  @HiveField(9)
  final double creditHours;
  @HiveField(10)
  final String scheduleJson;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.room,
    this.professor = '',
    required this.startTime,
    required this.endTime,
    required this.colorValue,
    this.targetGrade = 4.0,
    this.currentGrade = 0.0,
    this.creditHours = 3.0,
    this.scheduleJson = '[]',
  });

  Color get color => Color(colorValue);
}

@HiveType(typeId: 1)
enum TaskUrgency {
  @HiveField(0)
  urgent,
  @HiveField(1)
  normal
}

@HiveType(typeId: 2)
class StudyTask extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime dueDate;
  @HiveField(3)
  final TaskUrgency urgency;
  @HiveField(4)
  bool isCompleted;
  @HiveField(5)
  final String courseId;
  @HiveField(6)
  final String content;
  @HiveField(7)
  final String type;

  StudyTask({
    required this.id,
    required this.title,
    required this.dueDate,
    this.urgency = TaskUrgency.normal,
    this.isCompleted = false,
    this.courseId = '',
    this.content = '',
    this.type = 'task',
  });
}

@HiveType(typeId: 3)
enum AttendanceStatus {
  @HiveField(0)
  present,
  @HiveField(1)
  absent,
  @HiveField(2)
  late,
  @HiveField(3)
  upcoming
}

@HiveType(typeId: 4)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String courseId;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final AttendanceStatus status;

  AttendanceRecord({
    required this.id,
    required this.courseId,
    required this.date,
    required this.status,
  });
}

@HiveType(typeId: 6)
class CourseMaterial extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String courseId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String type;
  @HiveField(4)
  final String content;
  @HiveField(5)
  final DateTime createdAt;

  CourseMaterial({
    required this.id,
    required this.courseId,
    required this.title,
    this.type = 'link',
    this.content = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

@HiveType(typeId: 5)
class PomodoroSettings extends HiveObject {
  @HiveField(0)
  final int focusDuration;
  @HiveField(1)
  final int shortBreakDuration;
  @HiveField(2)
  final int longBreakDuration;

  PomodoroSettings({
    this.focusDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
  });
}
