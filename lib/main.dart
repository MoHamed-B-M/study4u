import 'package:flutter/material.dart';
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
import 'core/animation/page_scale.dart';
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
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Init error: $initError', textAlign: TextAlign.center),
            ),
          ),
        ),
      );
    }
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: AppTheme.scaffoldDark),
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
        builder: (context, state, child) => ValueListenableBuilder<double>(
          valueListenable: pageScaleNotifier,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              transformHitTests: false,
              child: PageScaleProvider(
                notifier: pageScaleNotifier,
                child: MainScreen(child: child!),
              ),
            );
          },
          child: child,
        ),
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

    return Scaffold(
      body: RepaintBoundary(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: widget.child,
        ),
      ),
      bottomNavigationBar: RepaintBoundary(
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
            : NavigationBar(
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
                indicatorShape: const StadiumBorder(),
                indicatorColor: AppTheme.primary.withValues(alpha: 0.25),
                backgroundColor: AppTheme.surfaceDark.withValues(alpha: 0.95),
                shadowColor: Colors.transparent,
                elevation: 0,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Tracker'),
                  NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Stats'),
                ],
              ),
      ),
    );
  }
}
