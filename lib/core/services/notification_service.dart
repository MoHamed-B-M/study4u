import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/datasources/local_storage.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  Future<void> init({
    void Function(String? payload)? onNotificationTap,
  }) async {
    if (_initialized) return;
    _initialized = true;

    // Timezone init with local location
    tz_data.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback to local (UTC if unknown) – still better than crash
      try {
        tz.setLocalLocation(tz.local);
      } catch (_) {}
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Request POST_NOTIFICATIONS on Android 13+
    if (Platform.isAndroid) {
      // Use permission_handler for consistent handling + fallback to plugin
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
      // Also try plugin's own request (covers some OEMs)
      try {
        await androidPlugin?.requestNotificationsPermission();
      } catch (_) {}
      // Request exact alarm permission via system settings intent if needed
      try {
        final canScheduleExact =
            await androidPlugin?.canScheduleExactNotifications() ?? true;
        if (canScheduleExact == false) {
          await androidPlugin?.requestExactAlarmsPermission();
        }
      } catch (_) {}
    }

    // Create all channels – use AppConstants IDs so native AlarmReceiver matches
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.androidAlarmChannelId,
        AppConstants.androidAlarmChannelName,
        description: 'Reminders for upcoming classes and tasks',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    // Keep alias for backward compatibility (old code used 'class_reminders')
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'class_reminders',
        'Class Reminders',
        description: 'Reminders for upcoming classes',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'general',
        'General Notifications',
        description: 'Task reminders and course updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'app_updates_channel',
        'App Updates',
        description:
            'Notifications for new application features and version updates.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  /// Check if notifications are enabled and request if needed. Returns true if granted.
  Future<bool> ensurePermission() async {
    if (!Platform.isAndroid) return true;
    await init();
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final result = await Permission.notification.request();
    if (result.isGranted) return true;
    // Final try via plugin
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final pluginResult =
        await androidPlugin?.requestNotificationsPermission() ?? false;
    return pluginResult == true;
  }

  Future<bool> canScheduleExactAlarms() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    try {
      return await androidPlugin?.canScheduleExactNotifications() ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> triggerUpdateNotification(String version) async {
    final hasPerm = await ensurePermission();
    if (!hasPerm) return;
    final androidDetails = AndroidNotificationDetails(
      'app_updates_channel',
      'App Updates',
      importance: Importance.max,
      priority: Priority.high,
      color: const Color(0xFF4ADE80),
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      (DateTime.now().millisecondsSinceEpoch % 100000).abs(),
      'New Update Available!',
      'Version v$version is now ready to download. Tap to view release notes and upgrade.',
      details,
      payload: 'app_update',
    );
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    final hasPerm = await ensurePermission();
    if (!hasPerm) return;
    const androidDetails = AndroidNotificationDetails(
      'general',
      'General Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Test notification – fires in 2 seconds, useful to verify permissions/channels
  Future<bool> showTestNotification() async {
    final hasPerm = await ensurePermission();
    if (!hasPerm) return false;
    await init();
    const androidDetails = AndroidNotificationDetails(
      'general',
      'General Notifications',
      channelDescription: 'Task reminders and course updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      99999,
      'Notifications working ✓',
      'This is a test – class reminders will appear like this.',
      details,
    );
    return true;
  }

  static DateTime? parseTime(String timeStr) {
    try {
      final cleaned = timeStr.trim().toUpperCase();
      final isPm = cleaned.contains('PM');
      final isAm = cleaned.contains('AM');
      final digits = cleaned.replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = digits.split(':');
      if (parts.length < 2) return null;

      var hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      if (isPm && hour != 12) hour += 12;
      if (isAm && hour == 12) hour = 0;

      return DateTime(2000, 1, 1, hour, minute);
    } catch (_) {
      return null;
    }
  }

  static Duration parseTimeOfDay(String timeStr) {
    final dt = parseTime(timeStr);
    if (dt == null) return Duration.zero;
    return Duration(hours: dt.hour, minutes: dt.minute);
  }

  static int? weekdayNumber(String day) {
    const map = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };
    return map[day.trim().toLowerCase()];
  }

  int _positiveId(int raw) => raw.abs() % 100000;

  Future<void> scheduleClassReminder({
    required int id,
    required String courseName,
    required String startTime,
    required List<String> weekDays,
    int minutesBefore = 15,
  }) async {
    await init();
    final hasPerm = await ensurePermission();
    if (!hasPerm) return;

    final time = parseTime(startTime);
    if (time == null) return;

    final canExact = await canScheduleExactAlarms();
    final scheduleMode = canExact == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final baseId = _positiveId(id);

    for (final day in weekDays) {
      final dayNum = weekdayNumber(day);
      if (dayNum == null) continue;

      // Compute next occurrence correctly:
      // - if day is today, check if reminder time is still in future today, else next week
      final now = DateTime.now();
      final reminderMinutes = time.hour * 60 + time.minute - minutesBefore;
      // Handle previous-day rollover (e.g. 00:05 with 15 min before => previous day 23:50)
      // For simplicity, skip if negative – user can set earlier reminder
      if (reminderMinutes < 0) continue;

      final reminderHour = reminderMinutes ~/ 60;
      final reminderMin = reminderMinutes % 60;

      final todayWeekday = now.weekday;
      int diff = dayNum - todayWeekday;
      final nowMinutes = now.hour * 60 + now.minute;
      if (diff < 0 || (diff == 0 && reminderMinutes <= nowMinutes)) {
        diff += 7;
      }
      final nextDate =
          DateTime(now.year, now.month, now.day).add(Duration(days: diff));
      final scheduleDate = DateTime(
        nextDate.year,
        nextDate.month,
        nextDate.day,
        reminderHour,
        reminderMin,
      );

      final tzScheduledDate = tz.TZDateTime.from(scheduleDate, tz.local);

      final androidDetails = AndroidNotificationDetails(
        AppConstants.androidAlarmChannelId,
        AppConstants.androidAlarmChannelName,
        channelDescription: 'Reminders for upcoming classes and tasks',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
      const iosDetails = DarwinNotificationDetails();
      final details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      final notifId = baseId * 10 + dayNum; // 0..7 offset, stays positive
      try {
        await _plugin.zonedSchedule(
          notifId,
          'Upcoming Class: $courseName',
          'Starts in $minutesBefore minutes at $startTime',
          tzScheduledDate,
          details,
          androidScheduleMode: scheduleMode,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'class_reminder_$courseName',
        );
      } catch (_) {
        // Fallback to inexact if exact fails
        try {
          await _plugin.zonedSchedule(
            notifId,
            'Upcoming Class: $courseName',
            'Starts in $minutesBefore minutes at $startTime',
            tzScheduledDate,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'class_reminder_$courseName',
          );
        } catch (_) {}
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    final baseId = _positiveId(id);
    // Cancel all 7 weekday variants
    for (int dayNum = 1; dayNum <= 7; dayNum++) {
      try {
        await _plugin.cancel(baseId * 10 + dayNum);
      } catch (_) {}
    }
    // Also cancel legacy single id
    try {
      await _plugin.cancel(baseId);
    } catch (_) {}
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  List<String> _parseWeekDays(String json) {
    try {
      final trimmed = json.trim();
      if (trimmed.isEmpty || trimmed == '[]') return [];
      final cleaned = trimmed.replaceAll('[', '').replaceAll(']', '').trim();
      if (cleaned.isEmpty) return [];
      return cleaned
          .split(',')
          .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Reschedule all course reminders – call on app start and after boot
  Future<void> rescheduleAllCourses() async {
    try {
      if (!LocalStorage.isReady) return;
      final courses = LocalStorage.coursesBox.values.toList();
      for (final c in courses) {
        try {
          final dynamic course = c;
          List<String> days = [];
          try {
            days = (course.weekDays as List).cast<String>();
          } catch (_) {}
          if (days.isEmpty) {
            try {
              final json = course.scheduleJson as String?;
              if (json != null) days = _parseWeekDays(json);
            } catch (_) {}
          }
          if (days.isEmpty) continue;
          final startTime = course.startTime as String?;
          final name = course.name as String?;
          final id = course.id as String?;
          if (startTime == null || name == null || id == null) continue;
          await scheduleClassReminder(
            id: id.hashCode,
            courseName: name,
            startTime: startTime,
            weekDays: days,
          );
        } catch (_) {}
      }
    } catch (_) {}
  }
}
