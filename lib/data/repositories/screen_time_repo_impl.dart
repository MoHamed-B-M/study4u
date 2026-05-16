import 'dart:async';
import '../../domain/entities/screen_time_entry.dart';
import '../../domain/repositories/screen_time_repository.dart';
import '../datasources/local_storage.dart';
import '../models/screen_time_log.dart';
import '../platform/screen_time_bridge.dart';

class ScreenTimeRepositoryImpl implements ScreenTimeRepository {
  @override
  List<ScreenTimeEntryEntity> getLogs() {
    return LocalStorage.screenTimeBox.values.map(_toEntity).toList();
  }

  @override
  Future<void> fetchAndStore() async {
    try {
      final data = await ScreenTimeBridge.fetchUsageStats();
      for (final entry in data) {
        final existingId = '${entry.appPackageName}_${entry.date.toIso8601String().substring(0, 10)}';
        final existing = LocalStorage.screenTimeBox.get(existingId);
        if (existing != null) {
          LocalStorage.screenTimeBox.put(
            existingId,
            ScreenTimeLog(
              id: existing.id,
              appPackageName: existing.appPackageName,
              date: existing.date,
              durationMinutes: existing.durationMinutes + entry.durationMinutes,
            ),
          );
        } else {
          LocalStorage.screenTimeBox.put(
            existingId,
            ScreenTimeLog(
              id: existingId,
              appPackageName: entry.appPackageName,
              date: entry.date,
              durationMinutes: entry.durationMinutes,
            ),
          );
        }
      }
    } catch (_) {}
  }

  @override
  int getTodayMinutes() {
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);
    return LocalStorage.screenTimeBox.values
        .where((log) => log.date.toIso8601String().substring(0, 10) == todayStr)
        .fold(0, (sum, log) => sum + log.durationMinutes);
  }

  @override
  Stream<List<ScreenTimeEntryEntity>> watchLogs() {
    return LocalStorage.screenTimeBox.watch().map((_) => getLogs());
  }

  ScreenTimeEntryEntity _toEntity(ScreenTimeLog m) {
    return ScreenTimeEntryEntity(
      id: m.id,
      appPackageName: m.appPackageName,
      date: m.date,
      durationMinutes: m.durationMinutes,
    );
  }
}

class ScreenTimeEntry {
  final String appPackageName;
  final DateTime date;
  final int durationMinutes;

  ScreenTimeEntry({
    required this.appPackageName,
    required this.date,
    required this.durationMinutes,
  });
}
