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
  @HiveField(7)
  final bool hapticFeedback;
  @HiveField(8)
  final bool showNavLabels;
  @HiveField(9)
  final bool pressSound;
  @HiveField(10)
  final double targetCgpa;
  @HiveField(11)
  final bool telegramPromptShown;
  @HiveField(12)
  final bool useAltAppIcon;

  AppSettings({
    this.id = 'default',
    this.primaryColorValue = 0xFF4ADE80,
    this.themeMode = 'system',
    this.notificationEnabled = true,
    this.userName = '',
    this.onboardingComplete = false,
    this.useFloatingNavBar = false,
    this.hapticFeedback = true,
    this.showNavLabels = true,
    this.pressSound = true,
    this.targetCgpa = -1,
    this.telegramPromptShown = false,
    this.useAltAppIcon = false,
  });
}
