import 'package:app_usage/app_usage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUsageState {
  final List<AppUsageInfo> todayUsage;
  final List<AppUsageInfo> weekUsage;
  final Duration todayTotal;
  final Duration weekTotal;
  final bool loading;
  final String? error;

  AppUsageState({
    this.todayUsage = const [],
    this.weekUsage = const [],
    this.todayTotal = Duration.zero,
    this.weekTotal = Duration.zero,
    this.loading = false,
    this.error,
  });

  AppUsageState copyWith({
    List<AppUsageInfo>? todayUsage,
    List<AppUsageInfo>? weekUsage,
    Duration? todayTotal,
    Duration? weekTotal,
    bool? loading,
    String? error,
  }) =>
      AppUsageState(
        todayUsage: todayUsage ?? this.todayUsage,
        weekUsage: weekUsage ?? this.weekUsage,
        todayTotal: todayTotal ?? this.todayTotal,
        weekTotal: weekTotal ?? this.weekTotal,
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );
}

class AppUsageNotifier extends StateNotifier<AppUsageState> {
  AppUsageNotifier() : super(AppUsageState());

  Future<void> fetchUsage() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = todayStart.subtract(const Duration(days: 7));

      final todayData = await AppUsage().getAppUsage(todayStart, now);
      final weekData = await AppUsage().getAppUsage(weekStart, now);

      final todayTotal =
          todayData.fold<Duration>(Duration.zero, (sum, info) => sum + info.usage);
      final weekTotal =
          weekData.fold<Duration>(Duration.zero, (sum, info) => sum + info.usage);

      todayData.sort((a, b) => b.usage.compareTo(a.usage));
      weekData.sort((a, b) => b.usage.compareTo(a.usage));

      state = state.copyWith(
        todayUsage: todayData,
        weekUsage: weekData,
        todayTotal: todayTotal,
        weekTotal: weekTotal,
        loading: false,
      );
    } on PlatformException catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Usage access not granted: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }
}

final appUsageProvider =
    StateNotifierProvider<AppUsageNotifier, AppUsageState>((ref) {
  return AppUsageNotifier();
});
