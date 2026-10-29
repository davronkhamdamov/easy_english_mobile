import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../design_system/components/badge/ds_badge.dart';
import '../../../../design_system/components/button/ds_button.dart';
import '../../../../design_system/components/interactive_text/word_lookup_info.dart';
import '../../data/datasources/word_definition_service.dart';
import '../../domain/entities/word_definition_entry.dart';
import '../widgets/word_definition_header.dart';
import '../widgets/word_sense_card.dart';

/// Full comprehensive Word Definition Screen displaying all meanings, senses,
/// UK/US pronunciations, and collocations in an article format.
class WordDefinitionScreen extends StatefulWidget {
  final String word;
  final WordDefinitionService? service;

  const WordDefinitionScreen({
    super.key,
    required this.word,
    this.service,
  });

  /// Convenient static helper to navigate to the definition of any word.
  static Future<void> open(BuildContext context, {required String word}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordDefinitionScreen(word: word),
      ),
    );
  }

  @override
  State<WordDefinitionScreen> createState() => _WordDefinitionScreenState();
}

class _WordDefinitionScreenState extends State<WordDefinitionScreen> {
  late final WordDefinitionService _service;
  final AudioPlayer _audioPlayer = AudioPlayer();

  WordDefinitionEntry? _entry;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPosFilter = 'All';

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? WordDefinitionService();
    _loadDefinition();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadDefinition() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final entry = await _service.getDefinition(widget.word);
      if (mounted) {
        setState(() {
          _entry = entry;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load definition for "${widget.word}".';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleBookmark() {
    if (_entry == null) return;
    HapticFeedback.selectionClick();
    WordLookupDictionaryService().toggleSaved(_entry!.word);
    final updatedSaved = WordLookupDictionaryService().isWordSaved(_entry!.word);

    setState(() {
      _entry = _entry!.copyWith(isSaved: updatedSaved);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedSaved
              ? 'Saved "${_entry!.word}" to IELTS Word Bank!'
              : 'Removed "${_entry!.word}" from IELTS Word Bank.',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyDefinition() {
    if (_entry == null) return;
    HapticFeedback.lightImpact();
    final buffer = StringBuffer();
    buffer.writeln('${_entry!.word} (${_entry!.partOfSpeech})');
    buffer.writeln('UK ${_entry!.ukPhonetic} • US ${_entry!.usPhonetic}\n');
    for (final s in _entry!.senses) {
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

  List<WordSense> get _filteredSenses {
    if (_entry == null) return const [];
    if (_selectedPosFilter == 'All') return _entry!.senses;
    return _entry!.senses
        .where((s) => s.partOfSpeech.toLowerCase() == _selectedPosFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = ThemeScope.maybeOf(context)?.palette ?? AppColors.currentPalette;

    return Scaffold(
      backgroundColor: isDark ? palette.darkBackground : palette.lightBackground,
      appBar: AppBar(
        title: Text(
          widget.word,
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
          ),
        ),
        actions: [
          if (_entry != null)
            IconButton(
              icon: Icon(
                _entry!.isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                color: _entry!.isSaved
                    ? AppColors.success
                    : (isDark ? palette.darkTextPrimary : palette.lightTextPrimary),
              ),
              tooltip: _entry!.isSaved ? 'Saved in Word Bank' : 'Save to Word Bank',
              onPressed: _toggleBookmark,
            ),
        ],
      ),
      body: _buildBody(isDark, palette),
    );
  }

  Widget _buildBody(bool isDark, AppColorPalette palette) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? palette.darkPrimary : palette.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading full definition for "${widget.word}"...',
              style: TextStyle(
                color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null || _entry == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: palette.darkTextMuted),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Definition not found.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLg.copyWith(
                  color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              DSButton(
                text: 'Try Again',
                variant: DSButtonVariant.outline,
                onPressed: _loadDefinition,
              ),
            ],
          ),
        ),
      );
    }

    final entry = _entry!;
    final filtered = _filteredSenses;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // 1. Article Header Card: Headword, POS, UK & US Phonetics + Audio + Copy Button
        WordDefinitionHeader(
          entry: entry,
          sharedAudioPlayer: _audioPlayer,
          onCopy: _copyDefinition,
        ),
        const SizedBox(height: AppSpacing.md),

        // 2. Part of Speech Filter Chips
        if (entry.allPartsOfSpeech.length > 1) ...[
          _buildFilterChips(entry, isDark, palette),
          const SizedBox(height: AppSpacing.md),
        ],

        // 3. Section Title with Meaning Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Meanings & Senses (${filtered.length})',
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                  color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            DSBadge(
              label: '${entry.senses.length} TOTAL',
              variant: DSBadgeVariant.neutral,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // 4. Sense Cards
        ...filtered.asMap().entries.map(
              (e) => WordSenseCard(
                key: ValueKey(e.value.id),
                sense: e.value,
                index: e.key,
                sharedAudioPlayer: _audioPlayer,
              ),
            ),

        // 5. Common IELTS Collocations & Idioms Card
        if (entry.collocations.isNotEmpty || entry.idioms.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildCollocationsCard(entry, isDark, palette),
        ],

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildFilterChips(WordDefinitionEntry entry, bool isDark, AppColorPalette palette) {
    final filters = ['All', ...entry.allPartsOfSpeech];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((pos) {
          final isSelected = _selectedPosFilter.toLowerCase() == pos.toLowerCase();
          final count = pos == 'All'
              ? entry.senses.length
              : entry.senses.where((s) => s.partOfSpeech.toLowerCase() == pos.toLowerCase()).length;

          final shortPos = pos == 'All' ? 'All' : formatPartOfSpeechShort(pos);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: shortPos,
                      style: TextStyle(
                        fontStyle: pos == 'All' ? FontStyle.normal : FontStyle.italic,
                        fontFamily: pos == 'All' ? null : 'Georgia',
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' ($count)',
                      style: const TextStyle(
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedPosFilter = pos),
              selectedColor: isDark ? palette.darkPrimary : palette.primary,
              backgroundColor: isDark ? palette.darkSurface : palette.lightSurface,
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? palette.darkBackground : Colors.white)
                    : (isDark ? palette.darkTextSecondary : palette.lightTextSecondary),
              ),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? palette.darkBorder : palette.lightBorder),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCollocationsCard(WordDefinitionEntry entry, bool isDark, AppColorPalette palette) {
    return Container(
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
          Row(
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 18,
                color: isDark ? palette.darkTextPrimary : palette.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'IELTS Collocations & Phrases',
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...entry.collocations.map(
                (col) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? palette.darkSurfaceVariant : palette.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? palette.darkBorder : palette.lightBorder,
                    ),
                  ),
                  child: Text(
                    col,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                    ),
                  ),
                ),
              ),
              ...entry.idioms.map(
                (idiom) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5))
                          .withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    idiom,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
