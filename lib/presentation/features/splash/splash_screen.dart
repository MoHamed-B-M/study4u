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

    _fadeCtrl = AnimationController(vsync: this)..addListener(_onUpdate);
    _scaleCtrl = AnimationController(vsync: this)..addListener(_onUpdate);
    _glowCtrl = AnimationController(vsync: this)..addListener(_onUpdate);
    _borderCtrl = AnimationController(vsync: this)..addListener(_onUpdate);

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

  void _onUpdate() {
    if (mounted) setState(() {});
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
    final fVal = reduced ? 1.0 : _fadeCtrl.value;
    final sVal = reduced ? 1.0 : _scaleCtrl.value;
    final gVal = reduced ? 1.0 : _glowCtrl.value;
    final bVal = reduced ? 1.0 : _borderCtrl.value;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          Opacity(
            opacity: gVal,
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
            child: Transform.scale(
              scale: sVal,
              child: Opacity(
                opacity: fVal,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _borderCtrl,
                      builder: (context, _) {
                        final borderWidth = 1.5 + (bVal * 1.5);
                        final shadowOffset = 3.0 + (bVal * 3.0);
                        return Container(
                          width: 120,
                          height: 120,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: _bgColor,
                            border: Border.all(
                              color: ComicTheme.surfaceWhite,
                              width: borderWidth,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ComicTheme.inkRed.withAlpha((80 * bVal).toInt()),
                                offset: Offset(shadowOffset, shadowOffset),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/book.svg',
                            colorFilter: ColorFilter.mode(
                              ComicTheme.inkRed,
                              BlendMode.srcIn,
                            ),
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'stdy4u',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 42,
                        color: ComicTheme.surfaceWhite,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'STUDY SMARTER',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 13,
                        color: ComicTheme.surfaceWhite.withAlpha(140),
                        letterSpacing: 3,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
