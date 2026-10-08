import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/comic_theme.dart';
import '../../../core/animation/m3e_spring.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextPage;

  const SplashScreen({super.key, required this.nextPage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _bgColor = ComicTheme.darkPulp;
  static const _glowColor = ComicTheme.inkRed;

  late final AnimationController _fadeCtrl;
  late final AnimationController _scaleCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _borderCtrl;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this);
    _scaleCtrl = AnimationController(vsync: this);
    _glowCtrl = AnimationController(vsync: this);

    M3ESpring.animate(
      _fadeCtrl,
      to: 1,
      spring: M3ESpring.effects(stiffness: 250, damping: 28),
    );

    Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      M3ESpring.animate(
        _scaleCtrl,
        to: 1,
        spring: M3ESpring.spatial(stiffness: 350, damping: 18),
      );
    });

    Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      M3ESpring.animate(
        _glowCtrl,
        to: 1,
        spring: M3ESpring.effects(stiffness: 180, damping: 35),
      );
    });

    Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      M3ESpring.animate(
        _borderCtrl,
        to: 1,
        spring: M3ESpring.spatial(stiffness: 400, damping: 22),
      );
    });

    Timer(const Duration(milliseconds: 3200), _navigateToApp);
  }

  void _navigateToApp() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.nextPage,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _glowCtrl.dispose();
    _borderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final reduced = M3ESpring.isReducedMotion(context);

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (context, child) {
              final gVal = reduced ? 1.0 : _glowCtrl.value;
              // FadeTransition avoids Opacity's saveLayer on every frame.
              return FadeTransition(
                opacity: AlwaysStoppedAnimation(gVal),
                child: child,
              );
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: size.width * 1.3,
                height: size.height * 0.35,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.9),
                    radius: 0.9,
                    colors: [
                      _glowColor.withAlpha(90),
                      _glowColor.withAlpha(20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_fadeCtrl, _scaleCtrl]),
              builder: (context, child) {
                final fVal = reduced ? 1.0 : _fadeCtrl.value;
                final sVal = reduced ? 1.0 : _scaleCtrl.value;
                return Transform.scale(
                  scale: sVal,
                  child: FadeTransition(
                    opacity: AlwaysStoppedAnimation(fVal),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'stdy4u',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1.2,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'STUDY SMARTER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(115),
                      letterSpacing: 3.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
