import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../state/speaking_state.dart';

class SpeakingTimerReadout extends StatelessWidget {
  final SpeakingState state;

  const SpeakingTimerReadout({super.key, required this.state});

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String label = 'Ready to Practice';
    Color color = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    int displaySecs = state.recordingDuration;
    final targetSecs = state.currentPrompt?.speakTimeSeconds ?? 120;

    if (state.practiceState == PracticeState.preparing) {
      label = 'Preparation Timer';
      color = AppColors.warning;
      displaySecs = state.prepDuration;
    } else if (state.practiceState == PracticeState.recording) {
      label = 'Recording Audio...';
      color = AppColors.danger;
    } else if (state.practiceState == PracticeState.recorded) {
      label = 'Audio Captured';
      color = AppColors.success;
    } else if (state.practiceState == PracticeState.evaluating) {
      label = 'AI Examiner Evaluating...';
      color = AppColors.primary;
    }

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.practiceState == PracticeState.preparing
              ? _formatDuration(displaySecs)
              : '${_formatDuration(displaySecs)} / ${_formatDuration(targetSecs)}',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
