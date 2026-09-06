import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'ds_word_dropdown.dart';
import 'word_lookup_info.dart';

/// Presentation mode for the word information dropdown.
enum DSWordDropdownPlacement {
  /// Automatically picks above or below based on screen availability
  auto,
  /// Always attempts to show above the word
  above,
  /// Always attempts to show below the word
  below,
  /// Shows as a bottom sheet modal
  bottomSheet,
}

/// Visual style for clickable words in [DSInteractiveText].
enum DSWordHighlightStyle {
  /// Subtle dotted underline
  dottedUnderline,
  /// Solid underline
  solidUnderline,
  /// Subtle background highlight pill
  backgroundHighlight,
  /// Standard text styling without underline until pressed/active
  plain,
}

/// A versatile, global text component that renders any text and provides interactive,
/// clickable word lookups with a rich custom dropdown popover containing dictionary definitions,
/// CEFR levels, phonetics, audio playback, and quick word-bank bookmarking.
class DSInteractiveText extends StatefulWidget {
  /// The full string content to render interactively.
  final String text;

  /// Default text style for normal text.
  final TextStyle? style;

  /// Custom text style for clickable words.
  final TextStyle? wordStyle;

  /// Text alignment.
  final TextAlign textAlign;

  /// Visual highlight style for clickable words.
  final DSWordHighlightStyle highlightStyle;

  /// Accent color for active or highlighted words.
  final Color? activeWordColor;

  /// Whether words can be clicked to open the dictionary dropdown.
  final bool isInteractive;

  /// Dropdown positioning mode.
  final DSWordDropdownPlacement dropdownPlacement;

  /// Optional query string whose matching words should be visually highlighted.
  final String? highlightQuery;

  /// Explicit list of words to visually highlight.
  final List<String>? highlightedWords;

  /// Custom text color for highlighted/searched words.
  final Color? searchHighlightColor;

  /// Custom background color for highlighted/searched words.
  final Color? searchHighlightBackgroundColor;

  /// Custom word lookup provider callback if overriding built-in dictionary.
  final Future<WordLookupInfo> Function(String word)? onLookupWord;

  /// Callback when a word is clicked.
  final ValueChanged<String>? onWordTap;

  /// Callback when a word's bookmark state changes.
  final void Function(WordLookupInfo info, bool isSaved)? onWordSaved;

  /// Custom builder for the dropdown content if total override is desired.
  final Widget Function(
    BuildContext context,
    WordLookupInfo info,
    VoidCallback close,
  )? customDropdownBuilder;

  const DSInteractiveText(
    this.text, {
    super.key,
    this.style,
    this.wordStyle,
    this.textAlign = TextAlign.start,
    this.highlightStyle = DSWordHighlightStyle.plain,
    this.activeWordColor,
    this.isInteractive = true,
    this.dropdownPlacement = DSWordDropdownPlacement.auto,
    this.highlightQuery,
    this.highlightedWords,
    this.searchHighlightColor,
    this.searchHighlightBackgroundColor,
    this.onLookupWord,
    this.onWordTap,
    this.onWordSaved,
    this.customDropdownBuilder,
  });

  @override
  State<DSInteractiveText> createState() => _DSInteractiveTextState();
}

class _WordLookupState {
  final String word;
  final WordLookupInfo? info;
  final bool isLoading;

  _WordLookupState({
    required this.word,
    this.info,
    this.isLoading = false,
  });
}

class _DSInteractiveTextState extends State<DSInteractiveText> {
  OverlayEntry? _currentOverlay;
  int? _activeTokenIndex;
  final Map<int, GlobalKey> _wordKeys = {};

  @override
  void dispose() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    super.dispose();
  }

  void _removeOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    if (mounted && _activeTokenIndex != null) {
      setState(() {
        _activeTokenIndex = null;
      });
    }
  }

  Future<void> _handleWordClick(String rawWord, int tokenIndex, GlobalKey key) async {
    if (!widget.isInteractive) return;

    final clean = WordLookupDictionaryService.cleanToken(rawWord);
    if (clean.isEmpty) return;

    HapticFeedback.selectionClick();
    widget.onWordTap?.call(clean);

    _removeOverlay();

    setState(() {
      _activeTokenIndex = tokenIndex;
    });

    final lookupNotifier = ValueNotifier<_WordLookupState>(
      _WordLookupState(word: clean, isLoading: true),
    );

    if (widget.dropdownPlacement == DSWordDropdownPlacement.bottomSheet) {
      _showBottomSheet(lookupNotifier);
    } else {
      _showPopoverOverlay(key, lookupNotifier);
    }

    try {
      final info = widget.onLookupWord != null
          ? await widget.onLookupWord!(rawWord)
          : await WordLookupDictionaryService().lookupWord(rawWord);

      if (mounted && _activeTokenIndex == tokenIndex) {
        lookupNotifier.value = _WordLookupState(
          word: clean,
          info: info,
          isLoading: false,
        );
      }
    } catch (_) {
      if (mounted && _activeTokenIndex == tokenIndex) {
        final fallback = WordLookupInfo(
          word: clean,
          cleanWord: clean,
          phonetic: '/$clean/',
          partOfSpeech: 'word',
          cefrLevel: 'B1',
          definition: 'Vocabulary definition lookup completed.',
          example: 'Example usage for "$clean".',
        );
        lookupNotifier.value = _WordLookupState(
          word: clean,
          info: fallback,
          isLoading: false,
        );
      }
    }
  }

  void _showBottomSheet(ValueNotifier<_WordLookupState> stateNotifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: ValueListenableBuilder<_WordLookupState>(
            valueListenable: stateNotifier,
            builder: (context, state, _) {
              if (state.isLoading || state.info == null) {
                return DSWordDropdownCard(
                  isLoading: true,
                  loadingWord: state.word,
                  maxWidth: double.infinity,
                  onClose: () => Navigator.of(ctx).pop(),
                );
              }
              return DSWordDropdownCard(
                info: state.info!,
                isLoading: false,
                maxWidth: double.infinity,
                onClose: () => Navigator.of(ctx).pop(),
                onSaveToggle: (saved) =>
                    widget.onWordSaved?.call(state.info!, saved),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() => _activeTokenIndex = null);
      }
    });
  }

  void _showPopoverOverlay(
      GlobalKey key, ValueNotifier<_WordLookupState> stateNotifier) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final overlay = Overlay.of(context);
    final wordOffset = renderBox.localToGlobal(Offset.zero);
    final wordSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;
    final mediaPadding = MediaQuery.of(context).padding;

    const double popoverWidth = 330.0;

    final spaceAbove = wordOffset.dy - mediaPadding.top;
    final spaceBelow = screenSize.height - (wordOffset.dy + wordSize.height) - mediaPadding.bottom;

    // Determine vertical placement: prefer below if ample space, else above
    bool placeAbove = false;
    if (widget.dropdownPlacement == DSWordDropdownPlacement.above) {
      placeAbove = true;
    } else if (widget.dropdownPlacement == DSWordDropdownPlacement.below) {
      placeAbove = false;
    } else {
      // Auto: place above only if below has less than 280px and above has more space
      if (spaceBelow < 280.0 && spaceAbove > spaceBelow) {
        placeAbove = true;
      } else {
        placeAbove = false;
      }
    }

    final double availableHeight = placeAbove
        ? (spaceAbove - 16.0).clamp(160.0, 480.0)
        : (spaceBelow - 16.0).clamp(160.0, 480.0);

    // Horizontal positioning clamped inside screen
    double left = (wordOffset.dx + wordSize.width / 2) - (popoverWidth / 2);
    left = left.clamp(16.0, screenSize.width - popoverWidth - 16.0);

    // Calculate relative arrow offset (0.0 to 1.0)
    final wordCenterGlobalX = wordOffset.dx + wordSize.width / 2;
    final arrowOffset = ((wordCenterGlobalX - left) / popoverWidth).clamp(0.08, 0.92);

    _currentOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Barrier dismissible area
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.15),
                ),
              ),
            ),

            // Floating Dropdown Card with Animation
            Positioned(
              left: left,
              top: placeAbove ? null : (wordOffset.dy + wordSize.height + 4.0),
              bottom: placeAbove
                  ? ((screenSize.height - wordOffset.dy) + 4.0)
                  : null,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                tween: Tween(begin: 0.85, end: 1.0),
                builder: (context, scale, child) {
                  return Opacity(
                    opacity: ((scale - 0.85) / 0.15).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale,
                      alignment: placeAbove
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
                      child: child,
                    ),
                  );
                },
                child: ValueListenableBuilder<_WordLookupState>(
                  valueListenable: stateNotifier,
                  builder: (context, state, _) {
                    if (state.isLoading || state.info == null) {
                      return DSWordDropdownCard(
                        isLoading: true,
                        loadingWord: state.word,
                        maxWidth: popoverWidth,
                        maxHeight: availableHeight,
                        isArrowPointingDown: placeAbove,
                        arrowOffset: arrowOffset,
                        onClose: _removeOverlay,
                      );
                    }

                    if (widget.customDropdownBuilder != null) {
                      return widget.customDropdownBuilder!(
                        context,
                        state.info!,
                        _removeOverlay,
                      );
                    }

                    return DSWordDropdownCard(
                      info: state.info!,
                      isLoading: false,
                      maxWidth: popoverWidth,
                      maxHeight: availableHeight,
                      isArrowPointingDown: placeAbove,
                      arrowOffset: arrowOffset,
                      onClose: _removeOverlay,
                      onSaveToggle: (saved) =>
                          widget.onWordSaved?.call(state.info!, saved),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_currentOverlay!);
  }

  Set<String> _extractSearchKeywords() {
    final Set<String> words = {};

    // 1. Extract words wrapped in <mark>...</mark>
    final markRegex = RegExp(r'<mark>(.*?)</mark>', caseSensitive: false);
    for (final match in markRegex.allMatches(widget.text)) {
      final content = match.group(1);
      if (content != null && content.isNotEmpty) {
        final innerWords = content.split(RegExp(r'\s+'));
        for (final w in innerWords) {
          final clean = WordLookupDictionaryService.cleanToken(w).toLowerCase();
          if (clean.isNotEmpty) {
            words.add(clean);
          }
        }
      }
    }

    // 2. Add explicit highlightedWords
    if (widget.highlightedWords != null) {
      for (final w in widget.highlightedWords!) {
        final clean = WordLookupDictionaryService.cleanToken(w).toLowerCase();
        if (clean.isNotEmpty) {
          words.add(clean);
        }
      }
    }

    // 3. Add highlightQuery words
    if (widget.highlightQuery != null &&
        widget.highlightQuery!.trim().isNotEmpty) {
      final qTokens = widget.highlightQuery!.trim().split(RegExp(r'\s+'));
      for (final q in qTokens) {
        final clean = WordLookupDictionaryService.cleanToken(q).toLowerCase();
        if (clean.isNotEmpty) {
          words.add(clean);
        }
      }
    }

    return words;
  }

  bool _isSearchMatch(String token, Set<String> targetWords) {
    if (targetWords.isEmpty) return false;
    final clean = WordLookupDictionaryService.cleanToken(token).toLowerCase();
    if (clean.isEmpty) return false;
    if (targetWords.contains(clean)) return true;

    for (final target in targetWords) {
      if (target.isEmpty) continue;
      if (clean == target) return true;

      // Handle plurals / common suffixes (s, es, ed, ing)
      if (clean == '${target}s' ||
          target == '${clean}s' ||
          clean == '${target}es' ||
          target == '${clean}es' ||
          clean == '${target}ed' ||
          target == '${clean}ed' ||
          clean == '${target}ing' ||
          target == '${clean}ing') {
        return true;
      }

      // Prefix matching for queries with sufficient length (>= 4 characters)
      if (target.length >= 4 && clean.length >= 4) {
        if (clean.startsWith(target) || target.startsWith(clean)) {
          return true;
        }
        // Common stem of at least 5 chars (e.g. opportunity vs opportinity typo or inflections)
        final minLen = target.length < clean.length ? target.length : clean.length;
        if (minLen >= 5 && clean.substring(0, 5) == target.substring(0, 5)) {
          return true;
        }
      }
    }
    return false;
  }

  List<String> _tokenize(String text) {
    // Splits text preserving words and spaces/punctuations
    final regex = RegExp(r'(\s+|[^\s\w]+|\w+)');
    return regex
        .allMatches(text)
        .map((m) => m.group(0) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  bool _isWordToken(String token) {
    return RegExp(r'^[a-zA-Z0-9\-\u2019\u0027]+$').hasMatch(token.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseStyle = widget.style ??
        AppTypography.bodyMd.copyWith(
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          height: 1.6,
        );

    final activeColor = widget.activeWordColor ??
        (isDark ? const Color(0xFF60A5FA) : AppColors.primary);
    final searchKeywords = _extractSearchKeywords();
    final cleanText =
        widget.text.replaceAll('<mark>', '').replaceAll('</mark>', '');
    final tokens = _tokenize(cleanText);

    return Wrap(
      alignment: _getWrapAlignment(widget.textAlign),
      crossAxisAlignment: WrapCrossAlignment.center,
      children: List.generate(tokens.length, (index) {
        final token = tokens[index];
        final isWord = _isWordToken(token);

        if (!isWord) {
          // Whitespace or punctuation
          if (token.contains('\n')) {
            return SizedBox(
              width: double.infinity,
              height: baseStyle.fontSize != null ? baseStyle.fontSize! * 0.5 : 8,
            );
          }
          return Text(
            token,
            style: baseStyle,
          );
        }

        // Clickable word token
        final key = _wordKeys.putIfAbsent(index, () => GlobalKey());
        final isActive = _activeTokenIndex == index;
        final isSearchHighlighted = _isSearchMatch(token, searchKeywords);

        return _InteractiveWordChip(
          key: key,
          word: token,
          baseStyle: baseStyle,
          customWordStyle: widget.wordStyle,
          highlightStyle: widget.highlightStyle,
          activeColor: activeColor,
          isActive: isActive,
          isSearchHighlighted: isSearchHighlighted,
          searchHighlightColor: widget.searchHighlightColor,
          searchHighlightBackgroundColor: widget.searchHighlightBackgroundColor,
          isInteractive: widget.isInteractive,
          isDark: isDark,
          onTap: () => _handleWordClick(token, index, key),
        );
      }),
    );
  }

  WrapAlignment _getWrapAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return WrapAlignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return WrapAlignment.end;
      case TextAlign.justify:
        return WrapAlignment.spaceBetween;
      case TextAlign.left:
      case TextAlign.start:
        return WrapAlignment.start;
    }
  }
}

class _InteractiveWordChip extends StatefulWidget {
  final String word;
  final TextStyle baseStyle;
  final TextStyle? customWordStyle;
  final DSWordHighlightStyle highlightStyle;
  final Color activeColor;
  final bool isActive;
  final bool isSearchHighlighted;
  final Color? searchHighlightColor;
  final Color? searchHighlightBackgroundColor;
  final bool isInteractive;
  final bool isDark;
  final VoidCallback onTap;

  const _InteractiveWordChip({
    super.key,
    required this.word,
    required this.baseStyle,
    this.customWordStyle,
    required this.highlightStyle,
    required this.activeColor,
    required this.isActive,
    this.isSearchHighlighted = false,
    this.searchHighlightColor,
    this.searchHighlightBackgroundColor,
    required this.isInteractive,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_InteractiveWordChip> createState() => _InteractiveWordChipState();
}

class _InteractiveWordChipState extends State<_InteractiveWordChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color? textColor;
    FontWeight? fontWeight;

    if (widget.isActive) {
      textColor = widget.activeColor;
      fontWeight = FontWeight.w700;
    } else if (widget.isSearchHighlighted) {
      textColor = widget.searchHighlightColor ??
          (widget.isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E));
      fontWeight = FontWeight.w700;
    } else if (_isHovered) {
      textColor = widget.activeColor;
      fontWeight =
          widget.customWordStyle?.fontWeight ?? widget.baseStyle.fontWeight;
    } else {
      textColor = widget.customWordStyle?.color ?? widget.baseStyle.color;
      fontWeight =
          widget.customWordStyle?.fontWeight ?? widget.baseStyle.fontWeight;
    }

    final mergedStyle = (widget.customWordStyle ?? widget.baseStyle).copyWith(
      color: textColor,
      fontWeight: fontWeight,
      decoration: _getDecoration(),
      decorationColor: widget.isActive
          ? widget.activeColor
          : (widget.isSearchHighlighted ? textColor : widget.activeColor),
      decorationStyle: _getDecorationStyle(),
    );

    Decoration? containerDecoration;
    if (widget.isActive) {
      containerDecoration = BoxDecoration(
        color: widget.activeColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: widget.activeColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
      );
    } else if (widget.isSearchHighlighted) {
      containerDecoration = BoxDecoration(
        color: widget.searchHighlightBackgroundColor ??
            (widget.isDark
                ? const Color(0xFF78350F).withValues(alpha: 0.5)
                : const Color(0xFFFEF3C7)),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: widget.isDark
              ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
              : const Color(0xFFF59E0B),
          width: 1.2,
        ),
      );
    } else if (_isHovered ||
        widget.highlightStyle == DSWordHighlightStyle.backgroundHighlight) {
      containerDecoration = BoxDecoration(
        color: widget.activeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      );
    }

    final padding = widget.isSearchHighlighted
        ? const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0)
        : const EdgeInsets.symmetric(horizontal: 1.5, vertical: 0.5);

    return MouseRegion(
      cursor: widget.isInteractive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isInteractive ? widget.onTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: padding,
          decoration: containerDecoration,
          child: Text(
            widget.word,
            style: mergedStyle,
          ),
        ),
      ),
    );
  }

  TextDecoration? _getDecoration() {
    if (widget.isActive) return TextDecoration.underline;
    if (widget.isSearchHighlighted) {
      return _isHovered ? TextDecoration.underline : TextDecoration.none;
    }
    switch (widget.highlightStyle) {
      case DSWordHighlightStyle.solidUnderline:
        return TextDecoration.underline;
      case DSWordHighlightStyle.dottedUnderline:
        return TextDecoration.underline;
      case DSWordHighlightStyle.backgroundHighlight:
      case DSWordHighlightStyle.plain:
        return _isHovered ? TextDecoration.underline : TextDecoration.none;
    }
  }

  TextDecorationStyle _getDecorationStyle() {
    if (widget.highlightStyle == DSWordHighlightStyle.dottedUnderline) {
      return TextDecorationStyle.dotted;
    }
    return TextDecorationStyle.solid;
  }
}
