import 'package:flutter/material.dart';

/// Defines a color palette theme token specification.
/// Tailored for the Obsidian OLED minimal and monochromatic color scheme.
class AppColorPalette {
  final String id;
  final String name;
  final String description;
  final String badge;
  final List<Color> previewColors;

  // Light Mode Colors
  final Color lightBackground;
  final Color lightSurface;
  final Color lightSurfaceVariant;
  final Color lightBorder;
  final Color lightTextPrimary;
  final Color lightTextSecondary;
  final Color lightTextMuted;
  final Color lightGlassBackground;
  final Color lightGlassBorder;

  // Dark Mode Colors
  final Color darkBackground;
  final Color darkSurface;
  final Color darkSurfaceVariant;
  final Color darkBorder;
  final Color darkTextPrimary;
  final Color darkTextSecondary;
  final Color darkTextMuted;
  final Color darkGlassBackground;
  final Color darkGlassBorder;

  // Accent and Brand Colors
  final Color primary;
  final Color primaryHover;
  final Color primaryLight;
  final Color secondary;
  final Color secondaryLight;

  final Color darkPrimary;
  final Color darkPrimaryHover;
  final Color darkPrimaryLight;

  const AppColorPalette({
    required this.id,
    required this.name,
    required this.description,
    required this.badge,
    required this.previewColors,
    required this.lightBackground,
    required this.lightSurface,
    required this.lightSurfaceVariant,
    required this.lightBorder,
    required this.lightTextPrimary,
    required this.lightTextSecondary,
    required this.lightTextMuted,
    required this.lightGlassBackground,
    required this.lightGlassBorder,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkSurfaceVariant,
    required this.darkBorder,
    required this.darkTextPrimary,
    required this.darkTextSecondary,
    required this.darkTextMuted,
    required this.darkGlassBackground,
    required this.darkGlassBorder,
    required this.primary,
    required this.primaryHover,
    required this.primaryLight,
    required this.secondary,
    required this.secondaryLight,
    required this.darkPrimary,
    required this.darkPrimaryHover,
    required this.darkPrimaryLight,
  });

  /// Obsidian OLED - Ultra deep true pitch black minimal with crisp studio white contrast
  static const AppColorPalette obsidian = AppColorPalette(
    id: 'obsidian',
    name: 'Obsidian OLED',
    description: 'Pitch OLED pure black with crisp studio white contrast',
    badge: 'OLED Black',
    previewColors: [
      Color(0xFF000000),
      Color(0xFF333333),
      Color(0xFFD4D4D4),
      Color(0xFFFFFFFF),
    ],
    // Light
    lightBackground: Color(0xFFFFFFFF),
    lightSurface: Color(0xFFF5F5F7),
    lightSurfaceVariant: Color(0xFFEBEBEF),
    lightBorder: Color(0xFFDCDCE0),
    lightTextPrimary: Color(0xFF000000),
    lightTextSecondary: Color(0xFF505055),
    lightTextMuted: Color(0xFF8E8E93),
    lightGlassBackground: Color(0xCCFFFFFF),
    lightGlassBorder: Color(0x60DCDCE0),
    // Dark
    darkBackground: Color(0xFF000000),
    darkSurface: Color(0xFF121214),
    darkSurfaceVariant: Color(0xFF1C1C1F),
    darkBorder: Color(0xFF2C2C30),
    darkTextPrimary: Color(0xFFFFFFFF),
    darkTextSecondary: Color(0xFFAAAAAF),
    darkTextMuted: Color(0xFF707075),
    darkGlassBackground: Color(0x331C1C1F),
    darkGlassBorder: Color(0x20707075),
    // Accents
    primary: Color(0xFF000000),
    primaryHover: Color(0xFF1A1A1A),
    primaryLight: Color(0xFFF5F5F7),
    secondary: Color(0xFF505055),
    secondaryLight: Color(0xFFEBEBEF),
    darkPrimary: Color(0xFFFFFFFF),
    darkPrimaryHover: Color(0xFFF0F0F5),
    darkPrimaryLight: Color(0xFF1C1C1F),
  );

  /// Default active palette
  static const AppColorPalette defaultPalette = obsidian;

  /// Active palettes list containing the selected Obsidian OLED palette
  static const List<AppColorPalette> allPalettes = [
    obsidian,
  ];

  /// Find palette by its unique string ID. Defaults to [obsidian].
  static AppColorPalette fromId(String? id) {
    if (id == null || id.isEmpty) return obsidian;
    return allPalettes.firstWhere(
      (p) => p.id == id,
      orElse: () => obsidian,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppColorPalette &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
