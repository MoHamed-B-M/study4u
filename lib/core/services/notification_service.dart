import 'dart:io' show Platform;
import 'dart:typed_data' show Int64List;
import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init({
    void Function(String? payload)? onNotificationTap,
  }) async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
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

    if (Platform.isAndroid) {
      await androidPlugin?.requestNotificationsPermission();
      // Request exact alarm permission for Android 12+
      await androidPlugin?.requestExactAlarmsPermission();
    }

    await _createNotificationChannels(androidPlugin);
  }

  Future<void> _createNotificationChannels(AndroidFlutterLocalNotificationsPlugin? androidPlugin) async {
    if (androidPlugin == null) return;

    // General notifications channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'general',
        'General Notifications',
        description: 'Task reminders and course updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        sound: RawResourceAndroidNotificationSound('notification_default'),
      ),
    );

    // Class reminders channel - high priority with alarm-like behavior
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'class_reminders',
        'Class Reminders',
        description: 'Reminders for upcoming classes',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        sound: RawResourceAndroidNotificationSound('notification_default'),
        vibrationPattern: const Int64List.fromList([0, 500, 200, 500]),
      ),
    );

    // Alarm channel for critical reminders - full screen intent
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'alarms',
        'Alarms',
        description: 'Critical alarms and time-sensitive reminders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        sound: RawResourceAndroidNotificationSound('notification_default'),
        vibrationPattern: const Int64List.fromList([0, 1000, 500, 1000]),
      ),
    );

    // App updates channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'app_updates_channel',
        'App Updates',
        description: 'Notifications for new application features and version updates.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        sound: RawResourceAndroidNotificationSound('notification_default'),
      ),
    );
  }

  Future<void> triggerUpdateNotification(String version) async {
    final androidDetails = AndroidNotificationDetails(
      'app_updates_channel',
      'App Updates',
      importance: Importance.max,
      priority: Priority.high,
      color: const Color(0xFF4ADE80),
      playSound: true,
      enableVibration: true,
      enableLights: true,
      sound: const RawResourceAndroidNotificationSound('notification_default'),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
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
    bool isAlarm = false,
  }) async {
    final channel = isAlarm ? 'alarms' : 'general';
    final androidDetails = AndroidNotificationDetails(
      channel,
      isAlarm ? 'Alarms' : 'General Notifications',
      importance: isAlarm ? Importance.max : Importance.high,
      priority: isAlarm ? Priority.max : Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      sound: const RawResourceAndroidNotificationSound('notification_default'),
      fullScreenIntent: isAlarm,
      category: isAlarm ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.reminder,
      visibility: isAlarm ? NotificationVisibility.public : NotificationVisibility.private,
    );
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: isAlarm ? InterruptionLevel.timeSensitive : InterruptionLevel.active,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(id, title, body, details, payload: payload);
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
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7,
    };
    return map[day.trim().toLowerCase()];
  }

  Future<void> scheduleClassReminder({
    required int id,
    required String courseName,
    required String startTime,
    required List<String> weekDays,
    int minutesBefore = 15,
  }) async {
    final time = parseTime(startTime);
    if (time == null) return;

    final reminderTime = Duration(hours: time.hour, minutes: time.minute) - Duration(minutes: minutesBefore);
    if (reminderTime.isNegative) return;

    for (final day in weekDays) {
      final dayNum = weekdayNumber(day);
      if (dayNum == null) continue;

      final now = DateTime.now();
      var diff = dayNum - now.weekday;
      if (diff <= 0) diff += 7;
      final nextDate = DateTime(now.year, now.month, now.day + diff);
      final scheduleDate = DateTime(
        nextDate.year, nextDate.month, nextDate.day,
        reminderTime.inHours.remainder(24),
        reminderTime.inMinutes.remainder(60),
      );

      final tzScheduledDate = tz.TZDateTime.from(scheduleDate, tz.local);

      final androidDetails = AndroidNotificationDetails(
        'class_reminders',
        'Class Reminders',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        sound: const RawResourceAndroidNotificationSound('notification_default'),
        vibrationPattern: const Int64List.fromList([0, 500, 200, 500]),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _plugin.zonedSchedule(
        id * 10 + dayNum,
        'Upcoming Class: $courseName',
        'Starts in $minutesBefore minutes at $startTime',
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'class_reminder_$courseName',
      );
    }
  }

  /// Schedule a one-time alarm notification with full-screen intent
  Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'alarms',
      'Alarms',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      sound: const RawResourceAndroidNotificationSound('notification_default'),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      vibrationPattern: const Int64List.fromList([0, 1000, 500, 1000]),
      timeoutAfter: 60000, // Auto-dismiss after 1 minute
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload ?? 'alarm_$id',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Cancel all class reminders for a specific course
  Future<void> cancelClassReminders(int courseId) async {
    // This would need to track scheduled IDs - simplified for now
    await _plugin.cancelAll();
  }
}
