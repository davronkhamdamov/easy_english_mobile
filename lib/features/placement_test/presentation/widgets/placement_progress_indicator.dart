import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/diagnostic_session.dart';

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

  IconData _getSectionIcon(String section) {
    final lower = section.toLowerCase();
    if (lower.contains('listening')) return Icons.headphones;
    if (lower.contains('reading')) return Icons.menu_book;
    if (lower.contains('vocab')) return Icons.translate;
    return Icons.spellcheck;
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

    final sectionTitle = q.section.isNotEmpty ? q.section : 'General';

    return Column(
      children: [
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getSectionIcon(sectionTitle),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$sectionTitle (${q.cefrLevel})',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: session.totalQuestions > 0
              ? (session.currentQuestionIndex + 1) / session.totalQuestions
              : 0.0,
          backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
      ],
    );
  }
}
