// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 7;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      id: fields[0] as String,
      primaryColorValue: fields[1] as int,
      themeMode: fields[2] as String,
      notificationEnabled: fields[3] as bool,
      userName: fields[4] as String,
      onboardingComplete: fields[5] as bool,
      useFloatingNavBar: fields[6] as bool,
      hapticFeedback: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.primaryColorValue)
      ..writeByte(2)
      ..write(obj.themeMode)
      ..writeByte(3)
      ..write(obj.notificationEnabled)
      ..writeByte(4)
      ..write(obj.userName)
      ..writeByte(5)
      ..write(obj.onboardingComplete)
      ..writeByte(6)
      ..write(obj.useFloatingNavBar)
      ..writeByte(7)
      ..write(obj.hapticFeedback);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
