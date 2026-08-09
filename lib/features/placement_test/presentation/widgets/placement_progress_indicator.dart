import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/diagnostic_session.dart';
import '../../domain/entities/diagnostic_skill.dart';

class PlacementProgressIndicator extends StatelessWidget {
  final DiagnosticSession session;
  final VoidCallback onOpenPalette;

  const PlacementProgressIndicator({
    super.key,
    required this.session,
    required this.onOpenPalette,
  });

  String _formatTimer(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  IconData _getSkillIcon(DiagnosticSkill skill) {
    switch (skill) {
      case DiagnosticSkill.grammar:
        return Icons.spellcheck;
      case DiagnosticSkill.vocabulary:
        return Icons.translate;
      case DiagnosticSkill.reading:
        return Icons.menu_book;
      case DiagnosticSkill.listening:
        return Icons.headphones;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final q = session.currentQuestion;
    final remainingSecs = session.remainingSeconds;

    Color timerColor = AppColors.primary;
    if (remainingSecs < 60) {
      timerColor = AppColors.danger;
    } else if (remainingSecs < 180) {
      timerColor = AppColors.warning;
    }

    return Column(
      children: [
        // Top Header: Skill Badge + Countdown Timer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skill Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getSkillIcon(q.skill),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${q.skill.displayName} (${q.cefrLevel})',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Countdown Timer Widget
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: timerColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: timerColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: timerColor),
                    const SizedBox(width: 6),
                    Text(
                      _formatTimer(remainingSecs),
                      style: TextStyle(
                        color: timerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Progress Bar
        LinearProgressIndicator(
          value: (session.currentQuestionIndex + 1) / session.totalQuestions,
          backgroundColor: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
      ],
    );
  }
}
