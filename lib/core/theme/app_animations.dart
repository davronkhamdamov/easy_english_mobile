import 'package:flutter/animation.dart';

/// Centralized animation constants for smooth micro-animations.
class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve curveFast = Curves.easeOutCubic;
  static const Curve curveNormal = Curves.easeInOutCubic;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSpring = Curves.easeOutBack;
}
