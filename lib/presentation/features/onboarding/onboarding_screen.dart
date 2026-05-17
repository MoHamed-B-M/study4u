import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/gradient_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.school_rounded,
      title: 'Welcome to stdy4u',
      subtitle: 'Your Smart Study Companion',
      description: 'Track courses, manage tasks, monitor attendance,\nand boost productivity — all in one place.',
      color: AppTheme.primary,
    ),
    _SlideData(
      icon: Icons.dashboard_rounded,
      title: 'Dashboard Overview',
      subtitle: 'Stay on Top of Your Day',
      description: 'View your upcoming classes, pending tasks,\nand course progress at a single glance.',
      color: AppTheme.secondary,
    ),
    _SlideData(
      icon: Icons.calendar_month_rounded,
      title: 'Attendance Tracker',
      subtitle: 'Never Miss a Class',
      description: 'Mark attendance, view your weekly schedule,\nand get alerted when you fall below threshold.',
      color: AppTheme.tertiary,
    ),
    _SlideData(
      icon: Icons.analytics_rounded,
      title: 'Performance Analytics',
      subtitle: 'Know Your Numbers',
      description: 'Track your CGPA in real time, use the Pomodoro\ntimer, and visualize grade distributions.',
      color: AppTheme.primary,
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _onDone() {
    HapticFeedback.heavyImpact();
    ref.read(settingsProvider.notifier).setOnboardingComplete(true);
    context.replace('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                    )
                  else
                    const SizedBox.shrink(),
                  TextButton(
                    onPressed: _onDone,
                    child: Text('Skip', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _OnboardingPage(
                    key: ValueKey(index),
                    slide: slide,
                    isActive: index == _currentPage,
                    totalPages: _slides.length,
                    currentIndex: index,
                    onDone: _onDone,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatefulWidget {
  final _SlideData slide;
  final bool isActive;
  final int totalPages;
  final int currentIndex;
  final VoidCallback onDone;

  const _OnboardingPage({
    super.key,
    required this.slide,
    required this.isActive,
    required this.totalPages,
    required this.currentIndex,
    required this.onDone,
  });

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    if (widget.isActive) {
      _animCtrl.value = 1;
    }
  }

  @override
  void didUpdateWidget(_OnboardingPage old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _animCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slide;
    final opacity = widget.isActive ? _fadeAnim.value : 1.0;
    final offset = widget.isActive ? _slideAnim.value : Offset.zero;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: offset,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: slide.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(slide.icon, size: 56, color: slide.color),
              ),
              const SizedBox(height: 40),
              Text(
                slide.title,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                slide.subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: slide.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                slide.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              _buildDots(context),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: widget.currentIndex == widget.totalPages - 1
                    ? GradientButton(
                        label: 'Get Started',
                        icon: Icons.rocket_launch,
                        onPressed: widget.onDone,
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDots(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.totalPages, (i) {
        final isActive = i == widget.currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}
