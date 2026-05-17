import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 7)
class AppSettings extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int primaryColorValue;
  @HiveField(2)
  final String themeMode;
  @HiveField(3)
  final bool notificationEnabled;
  @HiveField(4)
  final String userName;
  @HiveField(5)
  final bool onboardingComplete;
  @HiveField(6)
  final bool useFloatingNavBar;

  AppSettings({
    this.id = 'default',
    this.primaryColorValue = 0xFF4ADE80,
    this.themeMode = 'system',
    this.notificationEnabled = true,
    this.userName = '',
    this.onboardingComplete = true,
    this.useFloatingNavBar = false,
  });
}
