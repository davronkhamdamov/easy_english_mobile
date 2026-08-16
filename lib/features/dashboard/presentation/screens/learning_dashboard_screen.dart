import 'package:flutter/material.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_screen.dart';

/// Learning Dashboard Screen.
/// Renders the primary redesigned dashboard screen.
class LearningDashboardScreen extends StatelessWidget {
  final DashboardRepository? repository;

  const LearningDashboardScreen({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return DashboardScreen(repository: repository, initialIndex: 0);
  }
}
