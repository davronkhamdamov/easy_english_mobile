import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/placement_question.dart';
import 'placement_audio_player_widget.dart';
import 'placement_reading_passage_widget.dart';

class PlacementQuestionCard extends StatelessWidget {
  final PlacementQuestion question;
  final int? selectedOptionIndex;
  final ValueChanged<int> onSelectOption;
  final bool isPlayingAudio;
  final double audioProgress;
  final VoidCallback onToggleAudioPlay;

  const PlacementQuestionCard({
    super.key,
    required this.question,
    required this.selectedOptionIndex,
    required this.onSelectOption,
    required this.isPlayingAudio,
    required this.audioProgress,
    required this.onToggleAudioPlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.audioUrl != null && question.audioUrl!.isNotEmpty)
          PlacementAudioPlayerWidget(
            isPlaying: isPlayingAudio,
            progress: audioProgress,
            onTogglePlay: onToggleAudioPlay,
          ),
        if (question.passage != null && question.passage!.isNotEmpty)
          PlacementReadingPassageWidget(passage: question.passage!),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              question.questionText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(question.options.length, (index) {
          final isSelected = selectedOptionIndex == index;
          final optionLabel = String.fromCharCode(65 + index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: InkWell(
              onTap: () => onSelectOption(index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightSurfaceVariant),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        optionLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
