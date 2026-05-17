import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'data/datasources/local_storage.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/theme_provider.dart';
import 'presentation/features/home/home_screen.dart';
import 'presentation/features/tracker/tracker_screen.dart';
import 'presentation/features/statistics/statistics_screen.dart';
import 'presentation/features/settings/settings_screen.dart';
import 'presentation/features/course_detail/course_detail_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalStorage.init();
  runApp(const StartupApp());
}

class StartupApp extends StatefulWidget {
  const StartupApp({super.key});

  @override
  State<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends State<StartupApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ready = LocalStorage.isReady;
    if (!_ready) {
      LocalStorage.onReady(() {
        if (mounted) setState(() => _ready = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: _ready
          ? const ProviderScope(child: Stdy4uApp())
          : const _LoadingApp(),
    );
  }
}

class _LoadingApp extends StatelessWidget {
  const _LoadingApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (mounted) {
        setState(() => _error = details);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                '${_error!.exception}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
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
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          GoRoute(
            path: '/course/:id',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: CourseDetailScreen(courseId: state.pathParameters['id']!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
    ],
  );
  return router;
});

class Stdy4uApp extends ConsumerWidget {
  const Stdy4uApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    final seedColor = Color(s.primaryColorValue);

    final theme = AppTheme.lightTheme(seedColor);
    final darkTheme = AppTheme.darkTheme(seedColor);

    return MaterialApp.router(
      title: 'stdy4u',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
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
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = index);
          if (index == 0) context.go('/');
          if (index == 1) context.go('/tracker');
          if (index == 2) context.go('/stats');
        },
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Tracker'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Stats'),
        ],
      ),
    );
  }
}
