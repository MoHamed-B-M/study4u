import 'package:hive_flutter/hive_flutter.dart';
import '../../shared/models/models.dart';
import '../models/screen_time_log.dart';
import '../models/app_settings.dart';

class LocalStorage {
  static bool _ready = false;
  static String? _initError;
  static void Function()? _onReady;

  static bool get isReady => _ready;
  static String? get initError => _initError;

  static void onReady(void Function() callback) {
    if (_ready) {
      callback();
    } else {
      _onReady = callback;
    }
  }

  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      Hive.registerAdapter(CourseAdapter());
      Hive.registerAdapter(TaskUrgencyAdapter());
      Hive.registerAdapter(StudyTaskAdapter());
      Hive.registerAdapter(AttendanceStatusAdapter());
      Hive.registerAdapter(AttendanceRecordAdapter());
      Hive.registerAdapter(PomodoroSettingsAdapter());
      Hive.registerAdapter(ScreenTimeLogAdapter());
      Hive.registerAdapter(AppSettingsAdapter());
      Hive.registerAdapter(CourseMaterialAdapter());

      await Hive.openBox<Course>('courses');
      await Hive.openBox<StudyTask>('tasks');
      await Hive.openBox<AttendanceRecord>('attendance');
      await Hive.openBox<PomodoroSettings>('settings');
      await Hive.openBox<ScreenTimeLog>('screenTime');
      await Hive.openBox<AppSettings>('appSettings');
      await Hive.openBox<String>('pomodoroSessions');

      final settingsBox = Hive.box<AppSettings>('appSettings');
      if (settingsBox.isEmpty) {
        settingsBox.put('default', AppSettings());
      }

      _ready = true;
      _onReady?.call();
      _onReady = null;
    } catch (e) {
      _initError = e.toString();
      _ready = true;
      _onReady?.call();
      _onReady = null;
    }
  }

  static Box<T> safeBox<T>(String name) {
    try {
      return Hive.box<T>(name);
    } catch (_) {
      rethrow;
    }
  }

  static Box<Course> get coursesBox => Hive.box<Course>('courses');
  static Box<StudyTask> get tasksBox => Hive.box<StudyTask>('tasks');
  static Box<AttendanceRecord> get attendanceBox => Hive.box<AttendanceRecord>('attendance');
  static Box<PomodoroSettings> get pomodoroBox => Hive.box<PomodoroSettings>('settings');
  static Box<ScreenTimeLog> get screenTimeBox => Hive.box<ScreenTimeLog>('screenTime');
  static Box<AppSettings> get appSettingsBox => Hive.box<AppSettings>('appSettings');
  static Box<CourseMaterial> get materialsBox => Hive.box<CourseMaterial>('materials');
  static Box<String> get pomodoroSessionsBox => Hive.box<String>('pomodoroSessions');
}
