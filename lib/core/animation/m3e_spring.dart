import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

class M3ESpring {
  M3ESpring._();

  static SpringDescription spatial({
    double mass = 1.0,
    double stiffness = 400.0,
    double damping = 20.0,
  }) =>
      SpringDescription(mass: mass, stiffness: stiffness, damping: damping);

  static SpringDescription effects({
    double mass = 1.0,
    double stiffness = 200.0,
    double damping = 30.0,
  }) =>
      SpringDescription(mass: mass, stiffness: stiffness, damping: damping);

  static TickerFuture animate(
    AnimationController controller, {
    double? from,
    required double to,
    SpringDescription? spring,
    double velocity = 0.0,
  }) {
    final sim = SpringSimulation(
      spring ?? spatial(),
      from ?? controller.value,
      to,
      velocity,
    );
    return controller.animateWith(sim);
  }

  static bool isReducedMotion(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;
}
