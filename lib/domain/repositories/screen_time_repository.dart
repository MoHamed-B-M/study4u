import '../entities/screen_time_entry.dart';

abstract class ScreenTimeRepository {
  List<ScreenTimeEntryEntity> getLogs();
  Future<void> fetchAndStore();
  int getTodayMinutes();
  Stream<List<ScreenTimeEntryEntity>> watchLogs();
}
