import 'package:flutter/material.dart';

/// Design system color palette providing tokens for both Light and Dark themes.
class AppColors {
  AppColors._();

  // Brand Accents
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryHover = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEF2FF);

  static const Color secondary = Color(0xFF0EA5E9); // Sky Blue
  static const Color secondaryLight = Color(0xFFE0F2FE);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFFECFDF5);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color danger = Color(0xFFEF4444); // Rose
  static const Color dangerHover = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFEF2F2);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightGlassBackground = Color(0xCCFFFFFF);
  static const Color lightGlassBorder = Color(0x60FFFFFF);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF151D2A);
  static const Color darkSurfaceVariant = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF2A364F);
  static const Color darkGlassBackground = Color(0x33151D2A);
  static const Color darkGlassBorder = Color(0x20FFFFFF);
}
