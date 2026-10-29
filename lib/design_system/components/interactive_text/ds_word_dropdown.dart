import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/word_bank/domain/entities/word_definition_entry.dart';
import '../../../features/word_bank/presentation/screens/word_definition_screen.dart';
import 'word_lookup_info.dart';

/// Custom animated dropdown popup card that displays detailed vocabulary information
/// for a selected word with audio pronunciation, CEFR level, definitions, and actions.
class DSWordDropdownCard extends StatefulWidget {
  final WordLookupInfo? info;
  final String? loadingWord;
  final bool isLoading;
  final VoidCallback onClose;
  final ValueChanged<bool>? onSaveToggle;
  final bool isArrowPointingDown;
  final double arrowOffset;
  final double maxWidth;
  final double? maxHeight;

  const DSWordDropdownCard({
    super.key,
    this.info,
    this.loadingWord,
    this.isLoading = false,
    required this.onClose,
    this.onSaveToggle,
    this.isArrowPointingDown = false,
    this.arrowOffset = 0.5,
    this.maxWidth = 340.0,
    this.maxHeight,
  });

  @override
  State<DSWordDropdownCard> createState() => _DSWordDropdownCardState();
}

class _DSWordDropdownCardState extends State<DSWordDropdownCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.info?.isSaved ?? false;
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant DSWordDropdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.info != null &&
        (oldWidget.info == null || oldWidget.info!.word != widget.info!.word)) {
      _isSaved = widget.info!.isSaved;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPronunciation() async {
    if (widget.info == null) return;
    try {
      HapticFeedback.lightImpact();
      final clean = WordLookupDictionaryService.cleanToken(widget.info!.cleanWord);
      final url = widget.info!.audioUrl ??
          'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(clean)}&type=1';
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  void _handleCopy() {
    if (widget.info == null) return;
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(
      text: '${widget.info!.word} (${widget.info!.phonetic}) - ${widget.info!.definition}',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "${widget.info!.word}" definition to clipboard!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleToggleSave() {
    if (widget.info == null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isSaved = !_isSaved;
    });
    WordLookupDictionaryService().toggleSaved(widget.info!.cleanWord);
    widget.onSaveToggle?.call(_isSaved);
  }

  Color _getCefrColor(String cefr) {
    switch (cefr.toUpperCase()) {
      case 'C2':
      case 'C1':
        return AppColors.accentGreenDark;
      case 'B2':
      case 'B1':
        return AppColors.accentGreen;
      case 'A2':
      case 'A1':
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xF0181A20)
        : const Color(0xF8FFFFFF);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.08);

    final isCurrentlyLoading = widget.isLoading || widget.info == null;

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight ?? 480.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.isArrowPointingDown)
              _buildArrowPointer(isUp: true, isDark: isDark),

            // Popover Card Content
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: borderColor, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.16),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: isCurrentlyLoading
                        ? _buildLoadingBody(isDark)
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row: Word, Phonetic, Audio, Badges, Close Button
                                _buildHeader(isDark),
                                const SizedBox(height: AppSpacing.sm),

                                // Real Dictionary Definition
                                _buildDefinition(isDark),

                                // Example in Context (only when genuine example is available)
                                if (widget.info!.example != null &&
                                    widget.info!.example!.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildExample(isDark),
                                ],

                                // Synonyms & Collocations (only when genuine synonyms exist)
                                if (widget.info!.synonyms.isNotEmpty ||
                                    widget.info!.collocations.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildTags(isDark),
                                ],

                                const SizedBox(height: AppSpacing.md),
                                const Divider(height: 1),
                                const SizedBox(height: AppSpacing.sm),

                                // Footer Action Buttons
                                _buildFooterActions(isDark),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),

            if (widget.isArrowPointingDown)
              _buildArrowPointer(isUp: false, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBody(bool isDark) {
    final word = widget.loadingWord ?? widget.info?.word ?? 'Loading word...';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      word,
                      style: AppTypography.h2.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              onPressed: widget.onClose,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Searching vocabulary & definitions...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildArrowPointer({required bool isUp, required bool isDark}) {
    final arrowColor = isDark
        ? const Color(0xF0181A20)
        : const Color(0xF8FFFFFF);

    return Align(
      alignment: Alignment(widget.arrowOffset * 2 - 1, 0),
      child: CustomPaint(
        size: const Size(18, 8),
        painter: _TrianglePainter(
          color: arrowColor,
          isPointingUp: isUp,
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final info = widget.info!;
    final cefrColor = _getCefrColor(info.cefrLevel);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Word & Phonetic
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: InkWell(
                      onTap: () {
                        widget.onClose();
                        WordDefinitionScreen.open(context, word: info.word);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              info.word,
                              style: AppTypography.h2.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (info.cefrLevel.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    // CEFR Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cefrColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: cefrColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        info.cefrLevel,
                        style: TextStyle(
                          color: cefrColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                  if (info.partOfSpeech.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    // Part of Speech Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        formatPartOfSpeechShort(info.partOfSpeech),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (info.phonetic.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      info.phonetic,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: isDark ? AppColors.accentGreen : AppColors.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (info.audioUrl != null) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _playPronunciation,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.accentGreen : AppColors.primary).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlayingAudio
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded,
                            size: 15,
                            color: isDark ? AppColors.accentGreen : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),

        // Close Button
        InkWell(
          onTap: widget.onClose,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefinition(bool isDark) {
    final info = widget.info!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 6),
            child: Icon(
              Icons.menu_book_rounded,
              size: 13,
              color: isDark ? AppColors.accentGreen : AppColors.primary,
            ),
          ),
          Expanded(
            child: Text(
              info.definition,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExample(bool isDark) {
    final info = widget.info!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: (isDark ? AppColors.accentGreen : AppColors.primary).withValues(alpha: 0.8),
            width: 3,
          ),
        ),
      ),
      child: Text(
        '“${info.example}”',
        style: TextStyle(
          fontSize: 12.5,
          fontStyle: FontStyle.italic,
          height: 1.3,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }

  Widget _buildTags(bool isDark) {
    final info = widget.info!;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (info.synonyms.isNotEmpty) ...[
          Text(
            'Synonyms:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          ...info.synonyms.take(3).map(
                (syn) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    syn,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
        ],
      ],
    );
  }

  Widget _buildFooterActions(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Save to Word Bank toggle button
        InkWell(
          onTap: _handleToggleSave,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isSaved
                  ? AppColors.success.withValues(alpha: 0.15)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isSaved
                    ? AppColors.success.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                  size: 15,
                  color: _isSaved ? AppColors.success : (isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(width: 5),
                Text(
                  _isSaved ? 'Saved in Bank' : 'Save Word',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isSaved ? AppColors.success : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Quick Definition, Copy, and Pronounce buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                widget.onClose();
                WordDefinitionScreen.open(context, word: widget.info!.word);
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.auto_stories_outlined,
                  size: 17,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: _handleCopy,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: _playPronunciation,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.volume_up_rounded,
                  size: 18,
                  color: isDark ? AppColors.accentGreen : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool isPointingUp;

  _TrianglePainter({required this.color, required this.isPointingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isPointingUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isPointingUp != isPointingUp;
  }
}
