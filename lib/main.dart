import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/update_service.dart';
import 'core/services/sound_service.dart';
import 'data/datasources/local_storage.dart';
import 'theme/comic_theme.dart';
import 'presentation/theme/theme_provider.dart';
import 'presentation/features/home/home_screen.dart';
import 'presentation/features/tracker/tracker_screen.dart';
import 'presentation/features/statistics/statistics_screen.dart';
import 'presentation/features/settings/settings_screen.dart';
import 'presentation/features/course_detail/course_detail_screen.dart';
import 'presentation/features/splash/splash_screen.dart';
import 'presentation/features/feature_preview/feature_preview_screen.dart';
import 'presentation/widgets/update_dialog.dart';
import 'widgets/manga_nav_bar.dart';
import 'core/animation/page_scale.dart';
import 'data/models/app_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  NotificationService.instance.init(
    onNotificationTap: (payload) {
      if (payload != 'app_update') return;
      final update = UpdateService.lastKnownUpdate;
      if (update == null) return;
      final ctx = rootNavigatorKey.currentContext;
      if (ctx == null) return;
      UpdateDialog.show(context: ctx, update: update);
    },
  );
  LocalStorage.init();
  SoundService.instance.init();
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
              child:
                  Text('Init error: $initError', textAlign: TextAlign.center),
            ),
          ),
        ),
      );
    }
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ComicTheme.dark,
        home: const Scaffold(
          body: Center(
            child: Text(
              'LOADING...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ComicTheme.surfaceWhite,
              ),
            ),
          ),
        ),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ComicTheme.dark,
      home: SplashScreen(nextPage: _getNextPage()),
    );
  }

  Widget _getNextPage() {
    try {
      final settings =
          LocalStorage.appSettingsBox.get('default') ?? AppSettings();
      if (!settings.onboardingComplete)
        return const ProviderScope(child: FeaturePreviewScreen());
    } catch (_) {}
    return const ProviderScope(child: Stdy4uApp());
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
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
          GoRoute(
              path: '/tracker',
              builder: (context, state) => const TrackerScreen()),
          GoRoute(
              path: '/stats',
              builder: (context, state) => const StatisticsScreen()),
        ],
      ),
      GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: '/course/:id',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: CourseDetailScreen(courseId: state.pathParameters['id']!),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeInOutCubic)),
              child: child,
            );
          },
        ),
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
    final update = await service.checkForUpdate(channel: UpdateChannel.stable);
    if (!mounted || update == null || !update.isNewer) return;
    UpdateService.lastKnownUpdate = update;
    NotificationService.instance
        .triggerUpdateNotification(update.latestVersion);
    if (mounted) {
      await UpdateDialog.show(context: context, update: update);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'stdy4u',
      debugShowCheckedModeBanner: false,
      theme: ComicTheme.light,
      darkTheme: ComicTheme.dark,
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
  static const _tabRoutes = ['/', '/tracker', '/stats'];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isTabRoute = _tabRoutes.contains(location);
    if (isTabRoute) _currentIndex = _tabRoutes.indexOf(location);
    final enableHaptic = ref.watch(useHapticFeedbackProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    return Scaffold(
      body: isTabRoute
          ? RepaintBoundary(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeScreen(),
                  TrackerScreen(),
                  StatisticsScreen(),
                ],
              ),
            )
          : widget.child,
      bottomNavigationBar: isTabRoute
          ? MangaNavBar(
              selectedIndex: _currentIndex,
              enableHaptic: enableHaptic,
              onTabChange: (index) {
                context.go(_tabRoutes[index]);
              },
            )
          : null,
    );
  }
}
