import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

const List<String> _quotes = [
  'Success is the sum of small efforts, repeated day in and day out. - R. Collier',
  'The secret of getting ahead is getting started. - Mark Twain',
  'It does not matter how slowly you go as long as you do not stop. - Confucius',
  'Believe you can and you are halfway there. - Theodore Roosevelt',
  'The only way to do great work is to love what you do. - Steve Jobs',
  'Your time is limited, do not waste it living someone else life. - Steve Jobs',
  'Strive not to be a success, but rather to be of value. - Albert Einstein',
  'The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt',
];

String _randomQuote() => _quotes[DateTime.now().microsecondsSinceEpoch % _quotes.length];

class QuoteExpansionRoute extends PageRoute<void> {
  QuoteExpansionRoute({
    required this.sourceRect,
    required this.sourceColor,
    this.pageScaleNotifier,
  });

  final Rect sourceRect;
  final Color sourceColor;
  final ValueNotifier<double>? pageScaleNotifier;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 280);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 280);

  @override
  bool get opaque => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return _QuoteModalPage(
      sourceRect: sourceRect,
      sourceColor: sourceColor,
      routeAnimation: animation,
      pageScaleNotifier: pageScaleNotifier,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

class _QuoteModalPage extends StatefulWidget {
  final Rect sourceRect;
  final Color sourceColor;
  final Animation<double> routeAnimation;
  final ValueNotifier<double>? pageScaleNotifier;

  const _QuoteModalPage({
    required this.sourceRect,
    required this.sourceColor,
    required this.routeAnimation,
    this.pageScaleNotifier,
  });

  @override
  State<_QuoteModalPage> createState() => _QuoteModalPageState();
}

class _QuoteModalPageState extends State<_QuoteModalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _driver;
  late Animation<double> _expansion;
  late Animation<double> _blur;
  late Animation<double> _cornerRadius;
  late Animation<double> _contentFadeOut;
  late Animation<double> _placeholderFadeOut;
  late Animation<double> _quoteFadeIn;

  String _quote = '';

  @override
  void initState() {
    super.initState();
    _quote = _randomQuote();

    _driver = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _expansion = CurvedAnimation(
      parent: _driver,
      curve: Curves.fastOutSlowIn,
    );

    _blur = CurvedAnimation(
      parent: _driver,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    _cornerRadius = CurvedAnimation(
      parent: _driver,
      curve: Curves.fastOutSlowIn,
    );

    _contentFadeOut = CurvedAnimation(
      parent: _driver,
      curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
    );

    _placeholderFadeOut = CurvedAnimation(
      parent: _driver,
      curve: const Interval(0.25, 0.5, curve: Curves.easeOut),
    );

    _quoteFadeIn = CurvedAnimation(
      parent: _driver,
      curve: const Interval(0.35, 0.6, curve: Curves.easeIn),
    );

    _driver.addListener(_updatePageScale);
    widget.routeAnimation.addListener(_sync);
    if (widget.routeAnimation.isCompleted) {
      _driver.value = 1.0;
    }
  }

  void _sync() {
    if (_driver.value != widget.routeAnimation.value) {
      _driver.value = widget.routeAnimation.value;
    }
  }

  void _updatePageScale() {
    final t = _driver.value;
    widget.pageScaleNotifier?.value = 1.0 - (0.04 * t);
  }

  @override
  void dispose() {
    widget.pageScaleNotifier?.value = 1.0;
    widget.routeAnimation.removeListener(_sync);
    _driver.removeListener(_updatePageScale);
    _driver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _driver,
      builder: (context, _) {
        final exp = _expansion.value;
        final srcRect = widget.sourceRect;
        final dstH = size.height;
        final dstW = size.width;

        final currentH = srcRect.height + (dstH - srcRect.height) * exp;
        final currentW = srcRect.width + (dstW - srcRect.width) * exp;
        final currentTop = srcRect.top * (1.0 - exp);
        final currentLeft = srcRect.left * (1.0 - exp);
        final radius = AppTheme.radiusCard * (1.0 - _cornerRadius.value);
        final blurSigma = (12.0 * (1.0 - _blur.value) / 2).round() * 2.0;

        final contentOpacity = 1.0 - _contentFadeOut.value;
        final placeholderOpacity = _contentFadeOut.value * (1.0 - _placeholderFadeOut.value);
        final quoteOpacity = _quoteFadeIn.value;

        return Stack(
          children: [
            Positioned(
              top: currentTop,
              left: currentLeft,
              width: currentW,
              height: currentH,
              child: RepaintBoundary(
                child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.sourceColor,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: contentOpacity.clamp(0.0, 1.0),
                          child: _buildOriginalContent(),
                        ),
                        Opacity(
                          opacity: placeholderOpacity.clamp(0.0, 1.0),
                          child: const Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'STRUCTURING YOUR FOCUS BLOCK...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: quoteOpacity.clamp(0.0, 1.0),
                          child: _buildQuoteContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 20,
              child: Opacity(
                opacity: quoteOpacity.clamp(0.0, 1.0),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.15),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(Icons.close, color: Colors.black87, size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOriginalContent() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'UP NEXT',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Course Name',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Course Code',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: Colors.black87, size: 18),
              SizedBox(width: 8),
              Text(
                'Time',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteContent() {
    final isDone = _quoteFadeIn.value >= 1.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            'STUDY QUOTE:',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isDone ? _quote : '',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 2),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48, right: 24),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.black54,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
