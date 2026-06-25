import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

class CalendarBridge {
  static const _channel = MethodChannel(AppConstants.channelCalendar);

  static Future<bool> addEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String? location,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('addEvent', {
        'title': title,
        'description': description,
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
        'location': location ?? '',
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> removeEvent(String eventId) async {
    try {
      final result = await _channel.invokeMethod<bool>('removeEvent', {
        'eventId': eventId,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<List<CalendarEvent>> fetchEvents(DateTime start, DateTime end) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('fetchEvents', {
        'startDate': start.millisecondsSinceEpoch,
        'endDate': end.millisecondsSinceEpoch,
      });
      if (result == null) return [];
      return result.map((e) {
        final map = e as Map<dynamic, dynamic>;
        return CalendarEvent(
          eventId: map['eventId'] as String? ?? '',
          title: map['title'] as String? ?? '',
          startDate: DateTime.fromMillisecondsSinceEpoch(
            (map['startDate'] as num?)?.toInt() ?? 0,
          ),
          endDate: DateTime.fromMillisecondsSinceEpoch(
            (map['endDate'] as num?)?.toInt() ?? 0,
          ),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

class CalendarEvent {
  final String eventId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;

  CalendarEvent({
    required this.eventId,
    required this.title,
    required this.startDate,
    required this.endDate,
  });
}
