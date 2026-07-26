import 'package:flutter/material.dart';

/// Shadow tokens for soft depth and glassmorphism highlights.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> sm(bool isDark) => [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> md(bool isDark) => [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> lg(bool isDark) => [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> glow(Color color, {double blurRadius = 16, double spread = 0}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: blurRadius,
          spreadRadius: spread,
        ),
      ];
}
