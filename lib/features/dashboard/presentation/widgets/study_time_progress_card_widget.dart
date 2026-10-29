import 'package:flutter/material.dart';

/// Represents a category segment within the learning time progress bar.
class LearningTimeSegment {
  final String key;
  final String label;
  final String duration;
  final int minutes;
  final double alpha;
  final IconData? icon;

  const LearningTimeSegment({
    required this.key,
    required this.label,
    required this.duration,
    required this.minutes,
    this.alpha = 1.0,
    this.icon,
  });
}

/// Study Time / Learning Time Progress Card ("Card 1") inspired by Apple Watch / Health widgets.
/// Features a segmented progress bar with interactive tooltips showing what has been
/// practiced (e.g. Grammar, Vocabulary, Listening) when clicking on a bar.
class StudyTimeProgressCardWidget extends StatefulWidget {
  final String title;
  final String totalTime;
  final String grammarTime;
  final String vocabTime;
  final String practiceTime;
  final String? listeningTime;
  final List<LearningTimeSegment>? segments;
  final VoidCallback? onTap;
  final ValueChanged<LearningTimeSegment>? onSegmentTap;
  final String Function(LearningTimeSegment)? tooltipMessageBuilder;

  const StudyTimeProgressCardWidget({
    super.key,
    this.title = 'Learning time',
    this.totalTime = '01:47:19',
    this.grammarTime = '57m',
    this.vocabTime = '24m',
    this.practiceTime = '26m',
    this.listeningTime,
    this.segments,
    this.onTap,
    this.onSegmentTap,
    this.tooltipMessageBuilder,
  });

  @override
  State<StudyTimeProgressCardWidget> createState() =>
      _StudyTimeProgressCardWidgetState();
}

class _StudyTimeProgressCardWidgetState
    extends State<StudyTimeProgressCardWidget> {
  String? _selectedSegmentKey;
  final Map<String, GlobalKey<TooltipState>> _tooltipKeys = {};

  GlobalKey<TooltipState> _getTooltipKey(String key) {
    return _tooltipKeys.putIfAbsent(key, () => GlobalKey<TooltipState>());
  }

  int _parseMinutes(String text, {required int fallback}) {
    final match = RegExp(r'(\d+)\s*m').firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? fallback;
    }
    final numMatch = RegExp(r'\d+').firstMatch(text);
    if (numMatch != null) {
      return int.tryParse(numMatch.group(0)!) ?? fallback;
    }
    return fallback;
  }

  List<LearningTimeSegment> _getEffectiveSegments() {
    if (widget.segments != null && widget.segments!.isNotEmpty) {
      return widget.segments!;
    }
    final effectiveListening = widget.listeningTime ?? widget.practiceTime;
    return [
      LearningTimeSegment(
        key: 'grammar',
        label: 'Grammar',
        duration: widget.grammarTime,
        minutes: _parseMinutes(widget.grammarTime, fallback: 57),
        alpha: 1.0,
        icon: Icons.menu_book_rounded,
      ),
      LearningTimeSegment(
        key: 'vocabulary',
        label: 'Vocabulary',
        duration: widget.vocabTime,
        minutes: _parseMinutes(widget.vocabTime, fallback: 24),
        alpha: 0.55,
        icon: Icons.spellcheck_rounded,
      ),
      LearningTimeSegment(
        key: 'listening',
        label: 'Listening',
        duration: effectiveListening,
        minutes: _parseMinutes(effectiveListening, fallback: 26),
        alpha: 0.25,
        icon: Icons.headphones_rounded,
      ),
    ];
  }

  void _handleSegmentTap(LearningTimeSegment segment) {
    _getTooltipKey(segment.key).currentState?.ensureTooltipVisible();
    setState(() {
      _selectedSegmentKey =
          _selectedSegmentKey == segment.key ? null : segment.key;
    });
    widget.onSegmentTap?.call(segment);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = theme.colorScheme.surface;
    final textPrimaryColor = theme.colorScheme.onSurface;
    final textSecondaryColor = theme.colorScheme.onSurfaceVariant;
    final badgeBgColor =
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    final cardBorder = Border.all(
      color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
      width: 1,
    );
    final cardShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ];

    final segments = _getEffectiveSegments();

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(22),
        border: cardBorder,
        boxShadow: cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedSegmentKey = null;
            });
            widget.onTap?.call();
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Graduation Cap Capsule Badge (with optional Learning time title)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline
                          .withValues(alpha: isDark ? 0.15 : 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        color: textPrimaryColor,
                        size: 18,
                      ),
                      if (widget.title.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: textPrimaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Digital Timer Readout
                Text(
                  widget.totalTime,
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),

                // Breakdown String (e.g., 57m • 24m • 26m)
                _buildBreakdownRow(
                  segments,
                  textSecondaryColor,
                  textPrimaryColor,
                  isDark,
                ),
                const SizedBox(height: 14),

                // Segmented Monochrome Timeline Bar with Clickable Tooltips
                _buildSegmentedBar(textPrimaryColor, segments, isDark),
                const SizedBox(height: 10),

                // Bottom Session Dots Row (Monochrome)
                _buildDotTimeline(textPrimaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    List<LearningTimeSegment> segments,
    Color textSecondaryColor,
    Color textPrimaryColor,
    bool isDark,
  ) {
    return Row(
      children: [
        for (int i = 0; i < segments.length; i++) ...[
          if (i > 0)
            Text(
              ' • ',
              style: TextStyle(color: textSecondaryColor, fontSize: 13),
            ),
          _buildBreakdownItem(
            segment: segments[i],
            textSecondaryColor: textSecondaryColor,
            textPrimaryColor: textPrimaryColor,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildBreakdownItem({
    required LearningTimeSegment segment,
    required Color textSecondaryColor,
    required Color textPrimaryColor,
    required bool isDark,
  }) {
    final isSelected = _selectedSegmentKey == segment.key;
    final tooltipMsg = widget.tooltipMessageBuilder?.call(segment) ??
        '${segment.label}: ${segment.duration} practised';

    return Tooltip(
      key: Key('study_time_breakdown_tooltip_${segment.key}'),
      message: tooltipMsg,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: false,
      verticalOffset: 12,
      child: GestureDetector(
        key: Key('study_time_breakdown_${segment.key}'),
        onTap: () => _handleSegmentTap(segment),
        child: Text(
          segment.duration,
          style: TextStyle(
            color: isSelected ? textPrimaryColor : textSecondaryColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedBar(
    Color primaryColor,
    List<LearningTimeSegment> segments,
    bool isDark,
  ) {
    return Container(
      height: 24,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: [
            for (int i = 0; i < segments.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Expanded(
                flex: segments[i].minutes > 0 ? segments[i].minutes : 1,
                child: _buildBarSegment(segments[i], primaryColor, isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBarSegment(
    LearningTimeSegment segment,
    Color primaryColor,
    bool isDark,
  ) {
    final isSelected = _selectedSegmentKey == segment.key;
    final tooltipMsg = widget.tooltipMessageBuilder?.call(segment) ??
        '${segment.label}: ${segment.duration} practised';

    return Tooltip(
      key: _getTooltipKey(segment.key),
      message: tooltipMsg,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: false,
      verticalOffset: 16,
      showDuration: const Duration(seconds: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('study_time_bar_${segment.key}'),
          onTap: () => _handleSegmentTap(segment),
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: segment.alpha),
              borderRadius: BorderRadius.circular(4),
              border: isSelected
                  ? Border.all(
                      color: isDark ? Colors.white : Colors.black,
                      width: 1.5,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotTimeline(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(14, (index) {
        final isActive =
            index == 1 || index == 5 || index == 6 || index == 10 || index == 11;
        return Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? primaryColor.withValues(alpha: 0.8)
                : primaryColor.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}
