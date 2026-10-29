import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../design_system/components/badge/ds_badge.dart';
import '../../../../design_system/components/button/ds_button.dart';
import '../../data/datasources/word_definition_service.dart';
import '../../data/datasources/word_search_history_service.dart';
import '../../data/datasources/word_suggestion_service.dart';
import '../../domain/repositories/word_bank_repository.dart';
import '../providers/word_bank_provider.dart';
import 'flashcard_review_screen.dart';
import 'word_definition_screen.dart';

/// Full-featured IELTS Vocabulary Screen designed for the main navigation bar.
///
/// Features:
/// - Clean layout with top SM-2 Spaced Repetition Hero Card.
/// - Debounced "bounce search" as user types or hits enter (no direct exact lookup on enter).
/// - Tapping anywhere outside input dismisses keyboard.
/// - Clicking a word shows loading indicator on that option itself (never on the input).
/// - Search input value is preserved as it is when clicking options.
/// - Tapping suggestions or history items opens full word definitions.
/// - Persistent search history on successful word definition lookups.
/// - Proper Material ink splash wrapping for all ListTile components.
class VocabularyScreen extends StatefulWidget {
  final WordBankRepository? repository;
  final WordSearchHistoryService? historyService;
  final WordSuggestionService? suggestionService;
  final WordDefinitionService? definitionService;

  const VocabularyScreen({
    super.key,
    this.repository,
    this.historyService,
    this.suggestionService,
    this.definitionService,
  });

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  late final WordBankProvider _provider;
  late final WordSearchHistoryService _historyService;
  late final WordSuggestionService _suggestionService;
  late final WordDefinitionService _definitionService;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<WordSearchHistoryItem> _searchHistory = [];
  List<WordSuggestion> _suggestions = [];
  bool _isSearching = false;
  String? _loadingWord;

  @override
  void initState() {
    super.initState();
    _provider = WordBankProvider(repository: widget.repository);
    _provider.addListener(_onStateChange);
    _provider.loadWordBank();

    _historyService = widget.historyService ?? WordSearchHistoryService();
    _suggestionService = widget.suggestionService ?? WordSuggestionService();
    _definitionService = widget.definitionService ?? WordDefinitionService();

    _loadHistory();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _provider.removeListener(_onStateChange);
    _provider.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.loadHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  /// Triggers the debounced autocomplete search ("bounce search") immediately.
  Future<void> _triggerBounceSearch([String? query]) async {
    _debounceTimer?.cancel();
    final clean = (query ?? _searchController.text).trim();

    if (clean.isEmpty) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final suggestions = await _suggestionService.getSuggestions(clean);
      if (mounted && _searchController.text.trim() == clean) {
        setState(() {
          _suggestions = suggestions;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  /// Debounced trigger while typing
  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final clean = query.trim();

    if (clean.isEmpty) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _triggerBounceSearch(clean);
    });
  }

  /// Executes full dictionary lookup when a specific suggestion or word is chosen
  Future<void> _handleSearch(String query) async {
    _debounceTimer?.cancel();
    final cleanWord = query.trim();
    if (cleanWord.isEmpty) return;

    setState(() {
      _loadingWord = cleanWord.toLowerCase();
    });

    try {
      final entry = await _definitionService.getDefinition(cleanWord);
      final hasRealSense = entry.senses.isNotEmpty &&
          !entry.senses.any((s) =>
              s.definition.contains('No dictionary definition found') ||
              s.definition.contains('not found in the dictionary'));

      if (hasRealSense) {
        // Search finished with success: add to search history
        await _historyService.addSuccessfulSearch(
          word: entry.word,
          partOfSpeech: entry.partOfSpeech,
          definition: entry.senses.first.definition,
        );
        final updatedHistory = await _historyService.loadHistory();

        if (mounted) {
          setState(() {
            _loadingWord = null;
            _searchHistory = updatedHistory;
          });
          // Input value is NOT set, kept as it is!
          WordDefinitionScreen.open(context, word: entry.word);
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingWord = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No dictionary definition found for "$cleanWord"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingWord = null;
        });
      }
    }
  }

  void _startFlashcardReview() {
    final state = _provider.state;
    final reviewItems =
        state.dueFlashcards.isNotEmpty ? state.dueFlashcards : state.wordItems;
    if (reviewItems.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlashcardReviewScreen(initialItems: reviewItems),
      ),
    );
  }

  static String _shortPos(String pos) {
    final lower = pos.toLowerCase();
    if (lower == 'noun') return 'n';
    if (lower == 'verb') return 'v';
    if (lower == 'adjective') return 'adj';
    if (lower == 'adverb') return 'adv';
    if (lower == 'preposition') return 'prep';
    return lower;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = ThemeScope.maybeOf(context)?.palette ?? AppColors.currentPalette;
    final state = _provider.state;

    // Wrap in GestureDetector to dismiss keyboard on outside tap
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: isDark ? palette.darkBackground : palette.lightBackground,
        appBar: AppBar(
          title: Text(
            'Vocabulary',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              letterSpacing: -0.5,
              color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: const [],
        ),
        body: RefreshIndicator(
          onRefresh: _provider.loadWordBank,
          color: isDark ? palette.darkPrimary : palette.primary,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.md,
            ),
            children: [
              // 1. Debounced Search Bar (triggers bounce search on typing or enter)
              _buildSearchBar(isDark, palette),
              const SizedBox(height: AppSpacing.md),

              // 2. SM-2 Flashcard Stats & Quick Review Hero Card ("keep top card")
              _buildFlashcardHeroCard(state, isDark, palette),
              const SizedBox(height: AppSpacing.md),

              // 3. Dynamic Section below top card:
              // - Word suggestions while typing or after pressing enter
              // - Search history when searches finish with success
              // - Clean blank page state when empty
              if (_searchController.text.trim().isNotEmpty) ...[
                _buildSuggestionsSection(isDark, palette),
              ] else if (_searchHistory.isNotEmpty) ...[
                _buildSearchHistorySection(isDark, palette),
              ] else ...[
                _buildBlankPagePlaceholder(isDark, palette),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppColorPalette palette) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? palette.darkSurface : palette.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? palette.darkBorder : palette.lightBorder,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
          fontSize: 14.5,
        ),
        textInputAction: TextInputAction.search,
        onChanged: _onQueryChanged,
        onSubmitted: (query) {
          // Pressing enter triggers bounce search and hides keyboard (does not look for exact word)
          FocusScope.of(context).unfocus();
          _triggerBounceSearch(query);
        },
        decoration: InputDecoration(
          hintText: 'Search or type word to look up...',
          hintStyle: TextStyle(
            color: isDark ? palette.darkTextMuted : palette.lightTextMuted,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
            size: 20,
          ),
          // No loading indicator on input - only clear icon when text exists
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                  tooltip: 'Clear',
                  onPressed: () {
                    _searchController.clear();
                    _onQueryChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFlashcardHeroCard(dynamic state, bool isDark, AppColorPalette palette) {
    final hasDue = state.dueTodayCount > 0;

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
                Icons.style_rounded,
                size: 20,
                color: isDark ? palette.darkPrimary : palette.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Spaced Repetition (SM-2)',
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                  ),
                ),
              ),
              DSBadge(
                label: '${state.masteredCount} MASTERED',
                variant: DSBadgeVariant.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatPill(
                label: 'Total Words',
                value: '${state.totalWordsCount}',
                isDark: isDark,
                palette: palette,
              ),
              const SizedBox(width: 8),
              _buildStatPill(
                label: 'Due Today',
                value: '${state.dueTodayCount}',
                isDark: isDark,
                palette: palette,
                highlight: hasDue,
              ),
              const SizedBox(width: 8),
              _buildStatPill(
                label: 'Retention',
                value: state.totalWordsCount > 0
                    ? '${((state.masteredCount / state.totalWordsCount) * 100).toInt()}%'
                    : '100%',
                isDark: isDark,
                palette: palette,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: DSButton(
              text: hasDue
                  ? 'Review Due Cards (${state.dueTodayCount})'
                  : 'Practice Flashcards',
              variant: hasDue ? DSButtonVariant.primary : DSButtonVariant.outline,
              leftIcon: const Icon(Icons.play_arrow_rounded, size: 18),
              onPressed: _startFlashcardReview,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required bool isDark,
    required AppColorPalette palette,
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? palette.darkSurfaceVariant : palette.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: highlight
                ? (isDark ? palette.darkPrimary : palette.primary)
                : (isDark ? palette.darkBorder : palette.lightBorder),
            width: highlight ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: highlight
                    ? (isDark ? palette.darkPrimary : palette.primary)
                    : (isDark ? palette.darkTextPrimary : palette.lightTextPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(bool isDark, AppColorPalette palette) {
    if (_suggestions.isEmpty && !_isSearching) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Text(
                'No suggestions found for "${_searchController.text.trim()}"',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              DSButton(
                text: 'Look up in Dictionary',
                variant: DSButtonVariant.outline,
                onPressed: () => _handleSearch(_searchController.text),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: isDark ? palette.darkPrimary : palette.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Suggestions',
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                  color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ..._suggestions.map((suggestion) {
          final query = _searchController.text.toLowerCase();
          final word = suggestion.word;
          final matchIndex = word.toLowerCase().indexOf(query);
          final isItemLoading = _loadingWord == word.toLowerCase();

          // Wrapped in Material with shape for proper ink splashes and no assertions
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: isDark ? palette.darkSurface : palette.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: BorderSide(
                  color: isDark ? palette.darkBorder : palette.lightBorder,
                  width: 1.0,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: isDark ? palette.darkTextMuted : palette.lightTextMuted,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: matchIndex >= 0
                          ? RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                                ),
                                children: [
                                  TextSpan(
                                    text: word.substring(0, matchIndex),
                                  ),
                                  TextSpan(
                                    text: word.substring(matchIndex, matchIndex + query.length),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? palette.darkPrimary : palette.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: word.substring(matchIndex + query.length),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              word,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                              ),
                            ),
                    ),
                    if (suggestion.partOfSpeech != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        suggestion.partOfSpeech!,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                        ),
                      ),
                    ],
                    if (suggestion.cefrLevel != null) ...[
                      const SizedBox(width: 8),
                      DSBadge(
                        label: suggestion.cefrLevel!,
                        variant: DSBadgeVariant.neutral,
                      ),
                    ],
                  ],
                ),
                subtitle: suggestion.meaningHint != null
                    ? Text(
                        suggestion.meaningHint!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? palette.darkTextMuted : palette.lightTextMuted,
                        ),
                      )
                    : null,
                // Loading indicator directly on the option when clicked
                trailing: isItemLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? palette.darkPrimary : palette.primary,
                        ),
                      )
                    : Icon(
                        Icons.north_west_rounded,
                        size: 16,
                        color: isDark ? palette.darkTextMuted : palette.lightTextMuted,
                      ),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  // Keep input value as it is (do NOT overwrite _searchController.text)
                  _handleSearch(suggestion.word);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchHistorySection(bool isDark, AppColorPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Search History',
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5,
                      color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${_searchHistory.length})',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? palette.darkTextMuted : palette.lightTextMuted,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                  await _historyService.clearHistory();
                  setState(() {
                    _searchHistory = [];
                  });
                },
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? palette.darkTextMuted : palette.lightTextMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ..._searchHistory.map((item) {
          final isItemLoading = _loadingWord == item.word.toLowerCase();

          // Wrapped in Material with shape for proper ink splashes and no assertions
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: isDark ? palette.darkSurface : palette.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: BorderSide(
                  color: isDark ? palette.darkBorder : palette.lightBorder,
                  width: 1.0,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                ),
                title: Row(
                  children: [
                    Text(
                      item.word,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? palette.darkTextPrimary : palette.lightTextPrimary,
                      ),
                    ),
                    if (item.partOfSpeech != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _shortPos(item.partOfSpeech!),
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: isDark ? palette.darkTextSecondary : palette.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: item.definition != null
                    ? Text(
                        item.definition!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? palette.darkTextMuted : palette.lightTextMuted,
                        ),
                      )
                    : null,
                // Loading indicator directly on the option when clicked
                trailing: isItemLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? palette.darkPrimary : palette.primary,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        color: isDark ? palette.darkTextMuted : palette.lightTextMuted,
                        tooltip: 'Remove',
                        onPressed: () async {
                          await _historyService.removeItem(item.word);
                          final updated = await _historyService.loadHistory();
                          setState(() {
                            _searchHistory = updated;
                          });
                        },
                      ),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  // Keep input value as it is (do NOT overwrite _searchController.text)
                  _handleSearch(item.word);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBlankPagePlaceholder(bool isDark, AppColorPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 44,
              color: isDark
                  ? palette.darkTextMuted.withValues(alpha: 0.5)
                  : palette.lightTextMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Search any word to explore full definitions, pronunciations, and examples',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? palette.darkTextMuted : palette.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
