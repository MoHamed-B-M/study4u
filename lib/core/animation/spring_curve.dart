import 'dart:math' as math;
import 'package:flutter/widgets.dart';

class SpringCurve extends Curve {
  final double mass;
  final double stiffness;
  final double damping;

  const SpringCurve({
    this.mass = 1.0,
    this.stiffness = 400.0,
    this.damping = 20.0,
  });

  @override
  double transformInternal(double t) {
    const scale = 0.55;
    final tau = t / scale;
    if (tau >= 1) return 1;
    final omega0 = math.sqrt(stiffness / mass);
    final zeta = damping / (2 * math.sqrt(mass * stiffness));
    final omega = omega0 * math.sqrt(1 - zeta * zeta);
    final envelope = math.exp(-zeta * omega0 * tau);
    final phase = omega * tau;
    return (1 - envelope * math.cos(phase)).clamp(0.0, 1.0);
  }
}
