import 'package:flutter/material.dart';
import '../design_system.dart';

/// Design System dedicated investigation & playground page for [DSInteractiveText].
class DSInteractiveTextPage extends StatelessWidget {
  final ThemeController themeController;
  final VoidCallback onBackToOverview;

  const DSInteractiveTextPage({
    super.key,
    required this.themeController,
    required this.onBackToOverview,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveTextPlaygroundScreen(
      onBack: onBackToOverview,
    );
  }
}
