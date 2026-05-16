import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

class AlarmBridge {
  static const _channel = MethodChannel(AppConstants.channelAlarm);

  static Future<bool> scheduleAlarm({
    required int triggerAtMillis,
    required String title,
    required String body,
    int id = 0,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('scheduleAlarm', {
        'triggerAtMillis': triggerAtMillis,
        'title': title,
        'body': body,
        'id': id,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> cancelAlarm(int id) async {
    try {
      final result = await _channel.invokeMethod<bool>('cancelAlarm', {
        'id': id,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
