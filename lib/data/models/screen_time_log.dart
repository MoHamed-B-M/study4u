import 'package:hive/hive.dart';

part 'screen_time_log.g.dart';

@HiveType(typeId: 8)
class ScreenTimeLog extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String appPackageName;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final int durationMinutes;

  ScreenTimeLog({
    required this.id,
    required this.appPackageName,
    required this.date,
    required this.durationMinutes,
  });
}
