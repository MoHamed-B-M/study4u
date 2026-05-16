class AppConstants {
  AppConstants._();

  static const String appName = 'stdy4u';
  static const String coursesBox = 'courses';
  static const String tasksBox = 'tasks';
  static const String attendanceBox = 'attendance';
  static const String settingsBox = 'settings';
  static const String pomodoroBox = 'pomodoro';
  static const String screenTimeBox = 'screenTime';

  static const double attendanceThreshold = 75.0;
  static const int pomodoroFocusMinutes = 25;
  static const int pomodoroShortBreakMinutes = 5;
  static const int pomodoroLongBreakMinutes = 15;
  static const int pomodoroSessionsBeforeLongBreak = 4;
  static const int maxGradePoints = 4;

  static const String channelScreenTime = 'com.stdy4u/screen_time';
  static const String channelCalendar = 'com.stdy4u/calendar';
  static const String channelAlarm = 'com.stdy4u/alarm';

  static const String androidAlarmChannelId = 'stdy4u_alarm_channel';
  static const String androidPomodoroChannelId = 'stdy4u_pomodoro_channel';
  static const String androidPomodoroChannelName = 'Pomodoro Timer';
  static const String androidAlarmChannelName = 'Class & Task Reminders';
}
