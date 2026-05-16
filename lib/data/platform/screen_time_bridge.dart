import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

class ScreenTimeBridge {
  static const _channel = MethodChannel(AppConstants.channelScreenTime);

  static Future<List<ScreenTimeAppEntry>> fetchUsageStats() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getUsageStats');
      if (result == null) return [];
      return result.map((e) {
        final map = e as Map<dynamic, dynamic>;
        return ScreenTimeAppEntry(
          appPackageName: map['packageName'] as String? ?? 'unknown',
          date: DateTime.now(),
          durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

class ScreenTimeAppEntry {
  final String appPackageName;
  final DateTime date;
  final int durationMinutes;

  ScreenTimeAppEntry({
    required this.appPackageName,
    required this.date,
    required this.durationMinutes,
  });
}
