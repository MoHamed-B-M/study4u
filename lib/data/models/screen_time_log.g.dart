// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_time_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScreenTimeLogAdapter extends TypeAdapter<ScreenTimeLog> {
  @override
  final int typeId = 6;

  @override
  ScreenTimeLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScreenTimeLog(
      id: fields[0] as String,
      appPackageName: fields[1] as String,
      date: fields[2] as DateTime,
      durationMinutes: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ScreenTimeLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.appPackageName)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.durationMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenTimeLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
