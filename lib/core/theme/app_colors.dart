import 'package:flutter/material.dart';
import 'app_palette.dart';

/// Design system color palette providing tokens for both Light and Dark themes.
/// Standardized globally on the Obsidian OLED minimal monochromatic palette.
class AppColors {
  AppColors._();

  // Active palette configuration (Dedicated Obsidian OLED)
  static AppColorPalette currentPalette = AppColorPalette.obsidian;

  // Obsidian OLED Monochrome Scale Tokens
  static const Color pitchBlack = Color(0xFF000000);
  static const Color obsidianDark = Color(0xFF121214);
  static const Color obsidianElevated = Color(0xFF1C1C1F);
  static const Color obsidianBorder = Color(0xFF2C2C30);
  static const Color titaniumGrey = Color(0xFFAAAAAF);
  static const Color mutedGrey = Color(0xFF707075);
  static const Color borderGrey = Color(0xFFDCDCE0);
  static const Color lightGrey = Color(0xFFEBEBEF);
  static const Color pureSnow = Color(0xFFF5F5F7);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Backward-compatible scale aliases mapped to the Obsidian OLED spectrum
  static const Color brightSnow = pureWhite;
  static const Color platinum = lightGrey;
  static const Color alabasterGrey = borderGrey;
  static const Color paleSlate = titaniumGrey;
  static const Color paleSlate2 = mutedGrey;
  static const Color slateGrey = mutedGrey;
  static const Color ironGrey = obsidianBorder;
  static const Color gunmetal = obsidianDark;
  static const Color carbonBlack = pitchBlack;

  // Main Brand Accents (Obsidian OLED)
  static const Color primary = pitchBlack; // Light mode primary: pure pitch black
  static const Color primaryHover = Color(0xFF1A1A1A);
  static const Color primaryLight = pureSnow;

  static const Color secondary = Color(0xFF505055);
  static const Color secondaryLight = lightGrey;

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
  static const Color socialAppleBg = pitchBlack;
  static const Color socialGoogleBg = lightGrey;
  static const Color socialGuestBg = lightGrey;

  // Light Mode Colors (Obsidian Light Minimal)
  static const Color lightBackground = pureWhite;
  static const Color lightSurface = pureSnow;
  static const Color lightSurfaceVariant = lightGrey;
  static const Color lightTextPrimary = pitchBlack;
  static const Color lightTextSecondary = Color(0xFF505055);
  static const Color lightTextMuted = Color(0xFF8E8E93);
  static const Color lightBorder = borderGrey;
  static const Color lightGlassBackground = Color(0xCCFFFFFF);
  static const Color lightGlassBorder = Color(0x60DCDCE0);

  // Dark Mode Colors (Obsidian OLED True Pitch Black)
  static const Color darkBackground = pitchBlack; // Pure #000000 OLED
  static const Color darkSurface = obsidianDark; // Deep #121214 surface
  static const Color darkSurfaceVariant = obsidianElevated; // #1C1C1F
  static const Color darkTextPrimary = pureWhite; // Crisp #FFFFFF text
  static const Color darkTextSecondary = titaniumGrey; // #AAAAAF
  static const Color darkTextMuted = mutedGrey; // #707075
  static const Color darkBorder = obsidianBorder; // #2C2C30
  static const Color darkGlassBackground = Color(0x331C1C1F);
  static const Color darkGlassBorder = Color(0x20707075);

  /// Helper to get the active primary color from the current BuildContext theme.
  static Color primaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
}
