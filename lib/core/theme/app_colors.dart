import 'package:flutter/material.dart';

/// Design system color palette providing tokens for both Light and Dark themes.
/// Configured using the custom slate & monochrome color scale:
/// - Bright Snow (#F8F9FA)
/// - Platinum (#E9ECEF)
/// - Alabaster Grey (#DEE2E6)
/// - Pale Slate (#CED4DA)
/// - Pale Slate 2 (#ADB5BD)
/// - Slate Grey (#6C757D)
/// - Iron Grey (#495057)
/// - Gunmetal (#343A40)
/// - Carbon Black (#212529)
class AppColors {
  AppColors._();

  // Custom Palette Tokens
  static const Color brightSnow = Color(0xFFF8F9FA);
  static const Color platinum = Color(0xFFE9ECEF);
  static const Color alabasterGrey = Color(0xFFDEE2E6);
  static const Color paleSlate = Color(0xFFCED4DA);
  static const Color paleSlate2 = Color(0xFFADB5BD);
  static const Color slateGrey = Color(0xFF6C757D);
  static const Color ironGrey = Color(0xFF495057);
  static const Color gunmetal = Color(0xFF343A40);
  static const Color carbonBlack = Color(0xFF212529);

  // Main Brand Accents
  static const Color primary = carbonBlack; // Main Brand Color
  static const Color primaryHover = gunmetal;
  static const Color primaryLight = platinum;

  static const Color secondary = ironGrey;
  static const Color secondaryLight = alabasterGrey;

  // Lime / Green Accent (matches login screen progress & icons)
  static const Color accentGreen = Color(0xFF7CD327); // Vibrant lime green
  static const Color accentGreenDark = Color(0xFF48782B); // Muted dark green
  static const Color accentGreenLight = Color(0xFFE8F8D8);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFFECFDF5);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color danger = Color(0xFFEF4444); // Rose
  static const Color dangerHover = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFEF2F2);

  // Social & Auth Surface Colors
  static const Color socialAppleBg = carbonBlack;
  static const Color socialGoogleBg = platinum;
  static const Color socialGuestBg = platinum;

  // Light Mode Colors
  static const Color lightBackground = brightSnow;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = platinum;
  static const Color lightTextPrimary = carbonBlack;
  static const Color lightTextSecondary = ironGrey;
  static const Color lightTextMuted = slateGrey;
  static const Color lightBorder = alabasterGrey;
  static const Color lightGlassBackground = Color(0xCCF8F9FA);
  static const Color lightGlassBorder = Color(0x60DEE2E6);

  // Dark Mode Colors
  static const Color darkBackground = carbonBlack;
  static const Color darkSurface = gunmetal;
  static const Color darkSurfaceVariant = ironGrey;
  static const Color darkTextPrimary = brightSnow;
  static const Color darkTextSecondary = paleSlate;
  static const Color darkTextMuted = paleSlate2;
  static const Color darkBorder = ironGrey;
  static const Color darkGlassBackground = Color(0x33343A40);
  static const Color darkGlassBorder = Color(0x20ADB5BD);
}
