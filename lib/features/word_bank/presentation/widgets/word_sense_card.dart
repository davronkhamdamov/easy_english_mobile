import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../design_system/components/badge/ds_badge.dart';
import '../../domain/entities/word_definition_entry.dart';

/// Card component rendering a single sense / meaning of a word,
/// adhering to Cambridge/Oxford dictionary typography and Obsidian OLED theme.
class WordSenseCard extends StatefulWidget {
  final WordSense sense;
  final int index;
  final AudioPlayer? sharedAudioPlayer;

  const WordSenseCard({
    super.key,
    required this.sense,
    required this.index,
    this.sharedAudioPlayer,
  });

  @override
  State<WordSenseCard> createState() => _WordSenseCardState();
}

class _WordSenseCardState extends State<WordSenseCard> {
  AudioPlayer? _localPlayer;
  AudioPlayer get _audioPlayer => widget.sharedAudioPlayer ?? (_localPlayer ??= AudioPlayer());

  String? _currentlyPlayingUrl;

  @override
  void dispose() {
    _localPlayer?.dispose();
    super.dispose();
  }

  Future<void> _playExampleAudio(String text, String? directUrl) async {
    HapticFeedback.lightImpact();
    final url = directUrl ??
        'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(text)}&type=1';
    setState(() => _currentlyPlayingUrl = url);

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Audio playback error: $e');
    } finally {
      if (mounted) setState(() => _currentlyPlayingUrl = null);
    }
  }

  DSBadgeVariant _badgeVariantForCefr(String cefr) {
    switch (cefr.toUpperCase()) {
      case 'C2':
      case 'C1':
        return DSBadgeVariant.danger;
      case 'B2':
      case 'B1':
        return DSBadgeVariant.warning;
      case 'A2':
      case 'A1':
      default:
        return DSBadgeVariant.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = ThemeScope.maybeOf(context)?.palette ?? AppColors.currentPalette;
    final sense = widget.sense;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? palette.darkSurface : palette.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? palette.darkBorder : palette.lightBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sense Header: "work noun (ACTIVITY)"
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${sense.word} ',
                        style: AppTypography.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: -0.2,
                          color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '${sense.shortPartOfSpeech} ',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                        ),
                      ),
                      if (sense.guideWord.isNotEmpty)
                        TextSpan(
                          text: '(${sense.guideWord})',
                          style: AppTypography.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: -0.2,
                            color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (sense.cefrLevel.isNotEmpty) ...[
                DSBadge(
                  label: sense.cefrLevel,
                  variant: _badgeVariantForCefr(sense.cefrLevel),
                ),
                const SizedBox(width: 6),
              ],
              if (sense.grammaticalCode.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? palette.darkSurfaceVariant
                        : palette.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? palette.darkBorder : palette.lightBorder,
                    ),
                  ),
                  child: Text(
                    sense.grammaticalCode,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Definition Text
          Text(
            sense.definition,
            style: AppTypography.bodyMd.copyWith(
              fontSize: 14.5,
              height: 1.45,
              color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
            ),
          ),

          // Examples with highlighted pattern/collocation
          if (sense.examples.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? palette.darkSurfaceVariant.withValues(alpha: 0.6)
                    : palette.lightSurfaceVariant.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                    color: isDark ? palette.darkPrimary : palette.primary,
                    width: 3.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sense.examples.map((ex) => _buildExampleRow(ex, isDark, palette)).toList(),
              ),
            ),
          ],

          // Synonyms & Collocations tags
          if (sense.synonyms.isNotEmpty || sense.collocations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (sense.synonyms.isNotEmpty) ...[
                  Text(
                    'Synonyms:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? palette.darkTextMuted : palette.lightTextMuted,
                    ),
                  ),
                  ...sense.synonyms.take(4).map(
                        (syn) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isDark ? palette.darkSurfaceVariant : palette.lightSurfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? palette.darkBorder : palette.lightBorder,
                            ),
                          ),
                          child: Text(
                            syn,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                            ),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleRow(WordSenseExample ex, bool isDark, AppColorPalette palette) {
    final isPlaying = _currentlyPlayingUrl == ex.audioUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? palette.darkTextPrimary : palette.primary,
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                ),
                children: [
                  if (ex.pattern.isNotEmpty)
                    TextSpan(
                      text: '${ex.pattern} ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dotted,
                      ),
                    ),
                  TextSpan(
                    text: ex.sentence,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _playExampleAudio(ex.fullText, ex.audioUrl),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Icon(
                isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                size: 16,
                color: isPlaying
                    ? (isDark ? Colors.white : AppColors.primary)
                    : (isDark ? palette.darkTextMuted : palette.lightTextMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
