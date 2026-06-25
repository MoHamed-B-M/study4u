import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/screen_time_repo_impl.dart';
import '../../domain/entities/screen_time_entry.dart';

final screenTimeRepositoryProvider = Provider((ref) => ScreenTimeRepositoryImpl());

final screenTimeLogsProvider = Provider<List<ScreenTimeEntryEntity>>((ref) {
  final repo = ref.watch(screenTimeRepositoryProvider);
  return repo.getLogs();
});

final todayScreenTimeProvider = Provider<int>((ref) {
  final repo = ref.watch(screenTimeRepositoryProvider);
  return repo.getTodayMinutes();
});

final screenTimeRefreshProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(screenTimeRepositoryProvider);
  await repo.fetchAndStore();
});
