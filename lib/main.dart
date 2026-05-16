import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/datasources/local_storage.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/theme_provider.dart';
import 'presentation/features/home/home_screen.dart';
import 'presentation/features/tracker/tracker_screen.dart';
import 'presentation/features/statistics/statistics_screen.dart';
import 'presentation/features/settings/settings_screen.dart';
import 'presentation/features/onboarding/onboarding_screen.dart';
import 'presentation/features/course_detail/course_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  runApp(const ProviderScope(child: Stdy4uApp()));
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(settingsProvider.select((s) => s.onboardingComplete));
  final router = GoRouter(
    initialLocation: onboarded ? '/' : '/onboarding',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
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
  ref.onDispose(() => router.dispose());
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
    final useDynamic = s.useDynamicColor;

    final theme = useDynamic
        ? AppTheme.lightTheme(seedColor, dynamicColor: true)
        : AppTheme.lightTheme(seedColor, dynamicColor: false);
    final darkTheme = useDynamic
        ? AppTheme.darkTheme(seedColor, dynamicColor: true)
        : AppTheme.darkTheme(seedColor, dynamicColor: false);

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
          GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
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
