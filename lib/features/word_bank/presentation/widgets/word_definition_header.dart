import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/word_definition_entry.dart';

/// Article header card for the word definition page, featuring headword typography,
/// part-of-speech indicators, and interactive UK/US phonetic pronunciations with audio.
class WordDefinitionHeader extends StatefulWidget {
  final WordDefinitionEntry entry;
  final AudioPlayer? sharedAudioPlayer;
  final VoidCallback? onCopy;

  const WordDefinitionHeader({
    super.key,
    required this.entry,
    this.sharedAudioPlayer,
    this.onCopy,
  });

  @override
  State<WordDefinitionHeader> createState() => _WordDefinitionHeaderState();
}

class _WordDefinitionHeaderState extends State<WordDefinitionHeader> {
  AudioPlayer? _localPlayer;
  AudioPlayer get _audioPlayer => widget.sharedAudioPlayer ?? (_localPlayer ??= AudioPlayer());

  String? _activeAudio;

  @override
  void dispose() {
    _localPlayer?.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context) {
    HapticFeedback.lightImpact();
    final entry = widget.entry;
    final buffer = StringBuffer();
    buffer.writeln('${entry.word} (${entry.partOfSpeech})');
    buffer.writeln('UK ${entry.ukPhonetic} • US ${entry.usPhonetic}\n');
    for (final s in entry.senses) {
      buffer.writeln('• ${s.displayTitle} ${s.cefrLevel} ${s.grammaticalCode}');
      buffer.writeln('  ${s.definition}');
      for (final ex in s.examples) {
        buffer.writeln('  - ${ex.fullText}');
      }
      buffer.writeln();
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Definition copied to clipboard!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _playPronunciation({required bool isUk}) async {
    HapticFeedback.lightImpact();
    final url = isUk
        ? (widget.entry.ukAudioUrl ??
            'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(widget.entry.word)}&type=1')
        : (widget.entry.usAudioUrl ??
            'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(widget.entry.word)}&type=2');

    final audioKey = isUk ? 'uk' : 'us';
    setState(() => _activeAudio = audioKey);

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Pronunciation playback error: $e');
    } finally {
      if (mounted) setState(() => _activeAudio = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = ThemeScope.maybeOf(context)?.palette ?? AppColors.currentPalette;
    final entry = widget.entry;

    final posList = entry.allPartsOfSpeech.isNotEmpty
        ? entry.allPartsOfSpeech
        : (entry.partOfSpeech.isNotEmpty ? [entry.partOfSpeech] : <String>[]);
    final shortPosLabel = posList.map((p) => formatPartOfSpeechShort(p)).join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
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
          // Word & Part of speech row
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                entry.word,
                style: AppTypography.h1.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  letterSpacing: -0.5,
                  color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                ),
              ),
              Tooltip(
                message: 'Copy word & definition',
                child: InkWell(
                  onTap: () {
                    if (widget.onCopy != null) {
                      widget.onCopy!();
                    } else {
                      _copyToClipboard(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 20,
                      color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isDark ? palette.darkSurfaceVariant : palette.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isDark ? palette.darkBorder : palette.lightBorder,
                  ),
                ),
                child: Text(
                  shortPosLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // UK & US Pronunciation strips: uk /wɜːk/   us /wɝːk/
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              // UK pronunciation
              _buildPronunciationPill(
                region: 'UK',
                phonetic: entry.ukPhonetic,
                isUk: true,
                isDark: isDark,
                palette: palette,
              ),

              // US pronunciation
              _buildPronunciationPill(
                region: 'US',
                phonetic: entry.usPhonetic,
                isUk: false,
                isDark: isDark,
                palette: palette,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPronunciationPill({
    required String region,
    required String phonetic,
    required bool isUk,
    required bool isDark,
    required AppColorPalette palette,
  }) {
    final isPlaying = _activeAudio == (isUk ? 'uk' : 'us');
    final accentColor = isUk ? const Color(0xFF3B82F6) : const Color(0xFFEF4444);

    return InkWell(
      onTap: () => _playPronunciation(isUk: isUk),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? palette.darkSurfaceVariant
              : palette.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPlaying
                ? accentColor
                : (isDark ? palette.darkBorder : palette.lightBorder),
            width: isPlaying ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                region,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              phonetic.isNotEmpty ? phonetic : '/${widget.entry.word}/',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isPlaying ? Icons.volume_up_rounded : Icons.volume_up_outlined,
              size: 16,
              color: isPlaying
                  ? accentColor
                  : (isDark ? palette.darkTextSecondary : palette.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
