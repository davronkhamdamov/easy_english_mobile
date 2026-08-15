import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PlacementAudioPlayerWidget extends StatelessWidget {
  final bool isPlaying;
  final double progress;
  final VoidCallback onTogglePlay;

  const PlacementAudioPlayerWidget({
    super.key,
    required this.isPlaying,
    required this.progress,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.secondaryLight.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.secondary, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.headphones, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Listening Audio Recording',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: onTogglePlay,
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  ),
                  iconSize: 40,
                  color: AppColors.secondary,
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 30).round()}s / 30s',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
