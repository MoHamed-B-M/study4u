import 'package:flutter/material.dart';

/// Port of Komi Store manga decoration modifiers:
/// `GridPaper.gridPaper`, `InkModifiers.screentone/screentoneFill/
/// screentoneCorner/speedLines/hardShadow` + `HeadlineMarker` stamp.
///
/// All painters draw behind/over content with zero-blur hard ink,
/// matching Komi's paper aesthetic.

class GridPaperPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double cell;

  const GridPaperPainter({
    required this.color,
    required this.opacity,
    this.cell = 26.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0;
    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPaperPainter old) =>
      old.color != color || old.opacity != opacity || old.cell != cell;
}

class ScreentonePainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double spacing;
  final double radius;

  const ScreentonePainter({
    required this.color,
    required this.opacity,
    this.spacing = 5.0,
    this.radius = 1.1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: opacity);
    for (double y = 0; y <= size.height; y += spacing) {
      for (double x = 0; x <= size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ScreentonePainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.spacing != spacing ||
      old.radius != radius;
}

class SpeedLinesPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final int spokes;
  final double strokeWidth;

  const SpeedLinesPainter({
    required this.color,
    this.opacity = 0.12,
    this.spokes = 60,
    this.strokeWidth = 1.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final reach =
        (size.width * size.width + size.height * size.height).abs();
    final r = reach > 0 ? _sqrt(reach) : 0.0;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = strokeWidth;
    for (int i = 0; i < spokes; i++) {
      final angle = 2 * 3.141592653589793 * i / spokes;
      final dx = _cos(angle) * r;
      final dy = _sin(angle) * r;
      canvas.drawLine(Offset(cx, cy), Offset(cx + dx, cy + dy), paint);
    }
  }

  double _sqrt(double v) {
    double x = v / 2;
    if (x == 0) return 0;
    for (int i = 0; i < 20; i++) {
      x = (x + v / x) / 2;
    }
    return x;
  }

  double _cos(double x) {
    x = x % (2 * 3.141592653589793);
    double term = 1.0, sum = 1.0, x2 = x * x;
    double fact = 1.0;
    for (int n = 1; n <= 8; n++) {
      fact *= (2 * n - 1) * (2 * n);
      term *= -x2;
      sum += term / fact;
    }
    return sum;
  }

  double _sin(double x) {
    x = x % (2 * 3.141592653589793);
    double term = x, sum = x, x2 = x * x;
    double fact = 1.0;
    for (int n = 1; n <= 8; n++) {
      fact *= (2 * n) * (2 * n + 1);
      term *= -x2;
      sum += term / fact;
    }
    return sum;
  }

  @override
  bool shouldRepaint(covariant SpeedLinesPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.spokes != spokes;
}

/// Grid-paper scaffold background (Komi `KomiScaffold` paper layer).
class MangaPaperBackground extends StatelessWidget {
  final Color paper;
  final Color gridInk;
  final double gridOpacity;
  final Widget child;

  const MangaPaperBackground({
    super.key,
    required this.paper,
    required this.gridInk,
    required this.gridOpacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: paper,
      child: CustomPaint(
        painter: GridPaperPainter(color: gridInk, opacity: gridOpacity),
        child: child,
      ),
    );
  }
}

/// Screentone overlay for a panel corner (Komi `screentoneCorner`).
class MangaScreentoneCorner extends StatelessWidget {
  final Color ink;
  final double opacity;
  final Widget child;

  const MangaScreentoneCorner({
    super.key,
    required this.ink,
    required this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          width: 120,
          height: 90,
          child: IgnorePointer(
            child: CustomPaint(
              painter: ScreentonePainter(color: ink, opacity: opacity),
            ),
          ),
        ),
      ],
    );
  }
}
