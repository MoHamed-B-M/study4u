// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseAdapter extends TypeAdapter<Course> {
  @override
  final int typeId = 0;

  @override
  Course read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Course(
      id: fields[0] as String,
      code: fields[1] as String,
      name: fields[2] as String,
      room: fields[3] as String,
      startTime: fields[4] as String,
      endTime: fields[5] as String,
      colorValue: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Course obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.room)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudyTaskAdapter extends TypeAdapter<StudyTask> {
  @override
  final int typeId = 2;

  @override
  StudyTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyTask(
      id: fields[0] as String,
      title: fields[1] as String,
      dueDate: fields[2] as DateTime,
      urgency: fields[3] as TaskUrgency,
      isCompleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StudyTask obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dueDate)
      ..writeByte(3)
      ..write(obj.urgency)
      ..writeByte(4)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttendanceRecordAdapter extends TypeAdapter<AttendanceRecord> {
  @override
  final int typeId = 4;

  @override
  AttendanceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceRecord(
      id: fields[0] as String,
      courseId: fields[1] as String,
      date: fields[2] as DateTime,
      status: fields[3] as AttendanceStatus,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PomodoroSettingsAdapter extends TypeAdapter<PomodoroSettings> {
  @override
  final int typeId = 5;

  @override
  PomodoroSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PomodoroSettings(
      focusDuration: fields[0] as int,
      shortBreakDuration: fields[1] as int,
      longBreakDuration: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PomodoroSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.focusDuration)
      ..writeByte(1)
      ..write(obj.shortBreakDuration)
      ..writeByte(2)
      ..write(obj.longBreakDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PomodoroSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskUrgencyAdapter extends TypeAdapter<TaskUrgency> {
  @override
  final int typeId = 1;

  @override
  TaskUrgency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskUrgency.urgent;
      case 1:
        return TaskUrgency.normal;
      default:
        return TaskUrgency.urgent;
    }
  }

  @override
  void write(BinaryWriter writer, TaskUrgency obj) {
    switch (obj) {
      case TaskUrgency.urgent:
        writer.writeByte(0);
        break;
      case TaskUrgency.normal:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskUrgencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttendanceStatusAdapter extends TypeAdapter<AttendanceStatus> {
  @override
  final int typeId = 3;

  @override
  AttendanceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AttendanceStatus.present;
      case 1:
        return AttendanceStatus.absent;
      case 2:
        return AttendanceStatus.late;
      case 3:
        return AttendanceStatus.upcoming;
      default:
        return AttendanceStatus.present;
    }
  }

  @override
  void write(BinaryWriter writer, AttendanceStatus obj) {
    switch (obj) {
      case AttendanceStatus.present:
        writer.writeByte(0);
        break;
      case AttendanceStatus.absent:
        writer.writeByte(1);
        break;
      case AttendanceStatus.late:
        writer.writeByte(2);
        break;
      case AttendanceStatus.upcoming:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
