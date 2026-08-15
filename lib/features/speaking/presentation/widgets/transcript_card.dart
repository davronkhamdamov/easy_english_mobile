import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../design_system/design_system.dart';

class TranscriptCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isTranscribing;
  final ValueChanged<String>? onChanged;

  const TranscriptCard({
    super.key,
    required this.controller,
    required this.isTranscribing,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.subtitles_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Audio Transcript',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isTranscribing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    tooltip: 'Copy Transcript',
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: controller.text),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transcript copied to clipboard'),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const Divider(height: 16),
            if (isTranscribing) ...[
              const LinearProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Transcribing audio via Whisper STT...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else
              TextField(
                controller: controller,
                maxLines: 4,
                onChanged: onChanged,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'Edit or type spoken response here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
          ],
        ),
      ),
    );
  }
}
