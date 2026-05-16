class ScreenTimeEntryEntity {
  final String id;
  final String appPackageName;
  final DateTime date;
  final int durationMinutes;

  ScreenTimeEntryEntity({
    required this.id,
    required this.appPackageName,
    required this.date,
    required this.durationMinutes,
  });
}
