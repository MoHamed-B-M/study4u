import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:navigation_bar_m3e/navigation_bar_m3e.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
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
import 'core/animation/m3e_spring.dart';
import 'data/models/app_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: ExpressiveLoadingIndicator()),
        ),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark()
          .copyWith(scaffoldBackgroundColor: AppTheme.scaffoldDark),
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
                child:
                    MainScreen(currentLocation: state.matchedLocation, child: child!),
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
    final seedColor = Color(ref.watch(primaryColorProvider));

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightCS =
            lightDynamic ?? ColorScheme.fromSeed(seedColor: seedColor);
        final darkCS = darkDynamic ?? ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        );

        return MaterialApp.router(
          title: 'stdy4u',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(lightCS),
          darkTheme: AppTheme.darkTheme(darkCS),
          themeMode: themeMode,
          routerConfig: router,
        );
      },
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;
  final String currentLocation;
  const MainScreen({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navCtrl;
  late Animation<Offset> _navSlide;
  bool _wasSettings = false;

  @override
  void initState() {
    super.initState();
    _navCtrl = AnimationController(vsync: this);
    _navSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5),
    ).animate(_navCtrl);
    _wasSettings = widget.currentLocation == '/settings';
    if (_wasSettings) _navCtrl.value = 1;
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isSettings = widget.currentLocation == '/settings';
    if (isSettings != _wasSettings) {
      _wasSettings = isSettings;
      final reduced = M3ESpring.isReducedMotion(context);
      if (reduced) {
        _navCtrl.value = isSettings ? 1 : 0;
      } else {
        M3ESpring.animate(
          _navCtrl,
          to: isSettings ? 1 : 0,
          spring: M3ESpring.spatial(),
        );
      }
    }
  }

  @override
  void dispose() {
    _navCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showLabels = ref.watch(showNavLabelsProvider);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    return Scaffold(
      body: RepaintBoundary(
        child: widget.child,
      ),
      bottomNavigationBar: SlideTransition(
        position: _navSlide,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: NavigationBarM3E(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              HapticFeedback.lightImpact();
              setState(() => _currentIndex = index);
              if (index == 0) context.go('/');
              if (index == 1) context.go('/tracker');
              if (index == 2) context.go('/stats');
            },
            labelBehavior: showLabels
                ? NavBarM3ELabelBehavior.alwaysShow
                : NavBarM3ELabelBehavior.alwaysHide,
            size: NavBarM3ESize.small,
            elevation: 4,
            destinations: const [
              NavigationDestinationM3E(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home'),
              NavigationDestinationM3E(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: 'Tracker'),
              NavigationDestinationM3E(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: 'Stats'),
            ],
          ),
        ),
      ),
    );
  }
}
