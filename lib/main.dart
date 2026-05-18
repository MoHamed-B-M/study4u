import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'presentation/widgets/floating_nav_bar.dart';
import 'core/services/notification_service.dart';
import 'core/services/update_service.dart';
import 'data/datasources/local_storage.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/theme_provider.dart';
import 'presentation/features/home/home_screen.dart';
import 'presentation/features/tracker/tracker_screen.dart';
import 'presentation/features/statistics/statistics_screen.dart';
import 'presentation/features/settings/settings_screen.dart';
import 'presentation/features/course_detail/course_detail_screen.dart';
import 'presentation/features/splash/splash_screen.dart';
import 'presentation/features/feature_preview/feature_preview_screen.dart';
import 'presentation/widgets/update_dialog.dart';
import 'data/models/app_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.instance.init();
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
    final initError = LocalStorage.initError;
    if (initError != null) {
      return const CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: CupertinoPageScaffold(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Init error', textAlign: TextAlign.center),
            ),
          ),
        ),
      );
    }
    if (!_ready) {
      return const CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: CupertinoPageScaffold(
          child: Center(child: CupertinoActivityIndicator()),
        ),
      );
    }
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        barBackgroundColor: const Color(0xFF111625),
        scaffoldBackgroundColor: const Color(0xFF111625),
      ),
      home: SplashScreen(nextPage: _getNextPage()),
    );
  }

  Widget _getNextPage() {
    try {
      final settings = LocalStorage.appSettingsBox.get('default') ?? AppSettings();
      if (!settings.onboardingComplete) return const ProviderScope(child: FeaturePreviewScreen());
    } catch (_) {}
    return const ProviderScope(child: Stdy4uApp());
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
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => CupertinoPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/tracker',
            pageBuilder: (context, state) => CupertinoPage(
              key: state.pageKey,
              child: const TrackerScreen(),
            ),
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) => CupertinoPage(
              key: state.pageKey,
              child: const StatisticsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CupertinoPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/course/:id',
            pageBuilder: (context, state) => CupertinoPage(
              key: state.pageKey,
              child: CourseDetailScreen(courseId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
  );
  return router;
});

class Stdy4uApp extends ConsumerStatefulWidget {
  const Stdy4uApp({super.key});

  @override
  ConsumerState<Stdy4uApp> createState() => _Stdy4uAppState();
}

class _Stdy4uAppState extends ConsumerState<Stdy4uApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());
  }

  Future<void> _checkUpdate() async {
    final service = UpdateService();
    final update = await service.checkForUpdate();
    if (!mounted || update == null || !update.isNewer) return;
    await UpdateDialog.show(context: context, update: update);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    final seedColor = Color(ref.watch(primaryColorProvider));

    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    final theme = isDark ? AppTheme.darkTheme(seedColor) : AppTheme.lightTheme(seedColor);

    return CupertinoApp.router(
      title: 'stdy4u',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final useFloating = ref.watch(useFloatingNavBarProvider);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: widget.child,
                ),
              ),
            ),
            RepaintBoundary(
              child: useFloating
                  ? FloatingNavBar(
                      currentIndex: _currentIndex,
                      onDestinationSelected: (index) {
                        HapticFeedback.lightImpact();
                        setState(() => _currentIndex = index);
                        if (index == 0) context.go('/');
                        if (index == 1) context.go('/tracker');
                        if (index == 2) context.go('/stats');
                      },
                    )
                  : CupertinoTabBar(
                      currentIndex: _currentIndex,
                      onTap: (index) {
                        HapticFeedback.lightImpact();
                        setState(() => _currentIndex = index);
                        if (index == 0) context.go('/');
                        if (index == 1) context.go('/tracker');
                        if (index == 2) context.go('/stats');
                      },
                      items: const [
                        BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
                        BottomNavigationBarItem(icon: Icon(CupertinoIcons.calendar), label: 'Tracker'),
                        BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar_alt_fill), label: 'Stats'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
