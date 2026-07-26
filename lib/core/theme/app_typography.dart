import 'package:flutter/material.dart';

/// Typography design tokens scaling from caption to display titles.
class AppTypography {
  AppTypography._();

  // Font Sizes
  static const double fontXs = 12.0;
  static const double fontSm = 14.0;
  static const double fontMd = 16.0;
  static const double fontLg = 18.0;
  static const double fontXl = 20.0;
  static const double font2Xl = 24.0;
  static const double font3Xl = 32.0;

  // Text Styles (Neutral base, color mapped dynamically via theme)
  static const TextStyle display = TextStyle(
    fontSize: font3Xl,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: font2Xl,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: fontXl,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: fontLg,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: fontLg,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: fontMd,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: fontSm,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontXs,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.35,
  );

  static const TextStyle label = TextStyle(
    fontSize: fontSm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle button = TextStyle(
    fontSize: fontSm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const TextStyle code = TextStyle(
    fontSize: fontSm,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}
