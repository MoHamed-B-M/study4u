import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'shared/models/models.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/tracker/tracker_screen.dart';
import 'features/statistics/statistics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(CourseAdapter());
  Hive.registerAdapter(TaskUrgencyAdapter());
  Hive.registerAdapter(StudyTaskAdapter());
  Hive.registerAdapter(AttendanceStatusAdapter());
  Hive.registerAdapter(AttendanceRecordAdapter());
  Hive.registerAdapter(PomodoroSettingsAdapter());
  
  // Open Boxes
  await Hive.openBox<Course>('courses');
  await Hive.openBox<StudyTask>('tasks');
  await Hive.openBox<AttendanceRecord>('attendance');
  await Hive.openBox<PomodoroSettings>('settings');

  // Pre-populate if empty
  final coursesBox = Hive.box<Course>('courses');
  if (coursesBox.isEmpty) {
    coursesBox.put('1', Course(id: '1', code: 'EEE182', name: 'Electrical Circuit Design', room: 'Lab 402', startTime: '09:00 AM', endTime: '11:30 AM', colorValue: AppTheme.primary.value));
    coursesBox.put('2', Course(id: '2', code: 'MAT201', name: 'Advanced Mathematics', room: 'LH 3', startTime: '12:30 PM', endTime: '02:00 PM', colorValue: AppTheme.secondary.value));
  }

  runApp(const ProviderScope(child: MyApp()));
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/tracker', builder: (context, state) => const TrackerScreen()),
          GoRoute(path: '/stats', builder: (context, state) => const StatisticsScreen()),
        ],
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'stdy4u',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: widget.child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) context.go('/');
          if (index == 1) context.go('/tracker');
          if (index == 2) context.go('/stats');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Tracker'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Stats'),
        ],
      ),
    );
  }
}
