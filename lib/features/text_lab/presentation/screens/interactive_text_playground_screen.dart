import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/ads/admob_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../design_system/components/badge/ds_badge.dart';
import '../../../../design_system/components/button/ds_button.dart';
import '../../../../design_system/components/card/ds_card.dart';
import '../../../../design_system/components/interactive_text/ds_interactive_text.dart';
import '../../../../design_system/components/interactive_text/ds_word_dropdown.dart';
import '../../../../design_system/components/interactive_text/word_lookup_info.dart';
import '../../../../design_system/components/rich_markdown/ds_rich_markdown.dart';
import '../../../../design_system/components/rich_markdown/ds_rich_markdown_theme.dart';
import '../../../../design_system/pages/rich_markdown_page.dart';
import '../../../grammar/presentation/screens/grammar_article_screen.dart';
import '../../../grammar/presentation/screens/grammar_roadmap_screen.dart';
import '../../../sentence_builder/presentation/screens/sentence_builder_screen.dart';
import '../../../speaking/presentation/screens/speaking_screen.dart';
import '../../../writing/presentation/screens/writing_screen.dart';
import '../../../youtube_listening/presentation/screens/youtube_listening_screen.dart';
import 'ielts_article_test_screen.dart';

/// Categories available in the Language & AI Lab.
enum LabCategory {
  all,
  ieltsTestingLab,
  lookupWords,
  richMarkdown,
  sponsoredAds,
  sentenceBuilder,
  writingLab,
  speakingLab,
  grammarDiagnostics,
  listeningLab,
}

extension LabCategoryMeta on LabCategory {
  String get label {
    switch (this) {
      case LabCategory.all:
        return 'All Labs';
      case LabCategory.ieltsTestingLab:
        return 'IELTS Exam Lab';
      case LabCategory.lookupWords:
        return 'Look Up Words';
      case LabCategory.richMarkdown:
        return 'Rich Markdown';
      case LabCategory.sponsoredAds:
        return 'Sponsored Ads';
      case LabCategory.sentenceBuilder:
        return 'Sentence Builder';
      case LabCategory.writingLab:
        return 'AI Writing';
      case LabCategory.speakingLab:
        return 'Speaking & Voice';
      case LabCategory.grammarDiagnostics:
        return 'Grammar Diagnostics';
      case LabCategory.listeningLab:
        return 'Listening Lab';
    }
  }

  IconData get icon {
    switch (this) {
      case LabCategory.all:
        return Icons.grid_view_rounded;
      case LabCategory.ieltsTestingLab:
        return Icons.assignment_turned_in_rounded;
      case LabCategory.lookupWords:
        return Icons.text_snippet_rounded;
      case LabCategory.richMarkdown:
        return Icons.auto_stories_rounded;
      case LabCategory.sponsoredAds:
        return Icons.campaign_rounded;
      case LabCategory.sentenceBuilder:
        return Icons.construction_rounded;
      case LabCategory.writingLab:
        return Icons.edit_note_rounded;
      case LabCategory.speakingLab:
        return Icons.mic_rounded;
      case LabCategory.grammarDiagnostics:
        return Icons.spellcheck_rounded;
      case LabCategory.listeningLab:
        return Icons.play_circle_outline_rounded;
    }
  }
}

/// Preset reading articles for the Interactive Text Lab.
class PresetReadingSample {
  final String id;
  final String title;
  final String tag;
  final String passage;

  const PresetReadingSample({
    required this.id,
    required this.title,
    required this.tag,
    required this.passage,
  });
}

/// Dedicated experimentation and categorized playground screen for testing and exploring
/// interactive features, starting with the flagship Look Up Words (Interactive Text) feature,
/// accompanied by native advertisement integration.
class InteractiveTextPlaygroundScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const InteractiveTextPlaygroundScreen({super.key, this.onBack});

  @override
  State<InteractiveTextPlaygroundScreen> createState() =>
      _InteractiveTextPlaygroundScreenState();
}

class _InteractiveTextPlaygroundScreenState
    extends State<InteractiveTextPlaygroundScreen> {
  LabCategory _selectedCategory = LabCategory.all;

  // --- Look Up Words State ---
  static const List<PresetReadingSample> _samples = [
    PresetReadingSample(
      id: 'ielts_reading',
      title: 'IELTS Academic Reading',
      tag: 'Band 8.5 Passage',
      passage:
          'Space exploration pushes the boundaries of human engineering and scientific curiosity. In the modern era, smartphones and satellite communications have become ubiquitous across the globe. Researchers must articulate their findings with meticulous precision to mitigate potential orbital hazards and foster technological innovation.',
    ),
    PresetReadingSample(
      id: 'cognitive_science',
      title: 'Cognitive Neuroscience',
      tag: 'Language Acquisition',
      passage:
          'Regular reading stimulates cognitive resilience and lexical expansion in bilingual learners. To comprehend complex academic literature, students scrutinize grammatical patterns and adopt a pragmatic approach to mastering nuanced collocations.',
    ),
    PresetReadingSample(
      id: 'speaking_cue_card',
      title: 'IELTS Speaking Cue Card',
      tag: 'Model Answer',
      passage:
          'I would like to describe an eloquent mentor whose lucid lectures inspired my passion for global economics. Her profound paradigm shift transformed traditional classroom discourse into a dynamic exploration of real-world problem solving.',
    ),
  ];

  late PresetReadingSample _selectedSample;
  late final TextEditingController _customTextController;

  bool _isCustomMode = false;
  DSWordDropdownPlacement _placement = DSWordDropdownPlacement.auto;
  DSWordHighlightStyle _highlightStyle = DSWordHighlightStyle.dottedUnderline;
  double _fontSize = 15.0;
  final TextAlign _textAlign = TextAlign.start;
  final Color _accentColor = AppColors.primary;

  final List<String> _lookupHistory = [];
  int _savedCount = 0;



  // --- Rich Markdown Lab State ---
  static const List<Map<String, String>> _markdownLabSamples = [
    {
      'title': 'IELTS Band 8.5 Analysis',
      'tag': 'Academic Rubric',
      'content': '''# 🌟 IELTS Academic Essay Evaluation

The debate over **technological automation** in pedagogical environments continues to provoke divergent viewpoints. While artificial intelligence offers ==customized learning pathways==, human educators remain indispensable for nurturing critical discernment.

> [!TIP] IELTS Examiner Band 8.5 Tip
> Sustained topic development combined with sophisticated lexical collocation (*e.g.*, *pedagogical environments*, *nurturing discernment*) elevates Lexical Resource to Band 9.0.

---

### Evaluation Criteria Matrix
| Assessment Area | Band | Status | Evidence |
| :--- | :--- | :--- | :--- |
| **Task Response** | **8.5** | [badge:success:Mastered] | Clear position throughout |
| **Coherence & Flow** | **9.0** | [badge:primary:Flawless] | Logical paragraph cohesion |
| **Lexical Variety** | **8.5** | [badge:success:Advanced] | High lexical density |
| **Grammar Variety** | **8.5** | [badge:success:Passed] | Diverse subordinate clauses |

---

### Student Action Items:
- [x] Complete timed IELTS Task 2 practice essay
- [x] Review Academic Word List collocations for Task 1
- [ ] Record speaking responses on educational paradigms
- [ ] Practice 3 listening sections with speed 1.25x

```dart
// Band Score Calculator logic
double computeOverallBand(List<double> scores) {
  final avg = scores.reduce((a, b) => a + b) / scores.length;
  // Round up to nearest half-band
  return (avg * 2).round() / 2.0;
}
```
''',
    },
    {
      'title': 'Grammar Diagnostics & Rules',
      'tag': 'Syntax Linter',
      'content': '''# 🔍 Grammar Diagnostics: Prepositional Collocations

A systematic breakdown of frequent grammatical errors in IELTS academic writing.

> [!NOTE] Fundamental Rule
> The preposition `despite` never takes `of`. Always write **despite the evidence** or **in spite of the evidence**.

> [!WARNING] High-Frequency Error
> Avoid: `She is capable to analyze complex data.`
> Correct: `She is capable of analyzing complex data.`

---

### Collocation Reference Table
| Adjective | Governed Preposition | Example Context |
| :--- | :--- | :--- |
| **proficient** | `in` + noun / gerund | *Proficient in academic writing* |
| **detrimental** | `to` + noun | *Detrimental to cognitive agility* |
| **conducive** | `to` + noun | *Conducive to lexical acquisition* |
''',
    },
    {
      'title': 'Complete GFM Spec Showcase',
      'tag': 'All Markdown Elements',
      'content': '''# 🚀 Full Markdown & Rich Extensions

Supports standard CommonMark, GitHub Flavored Markdown (GFM), and custom UI components:

## Inline Formatting
- **Bold text**, *Italic emphasis*, ~~Strikethrough~~, and `inline_code()`.
- Highlights: ==golden highlight== and <mark>mark badge</mark>.
- Math: Einstein's E = mc^2^ and Water H~2~O.

## GitHub Callout Alert Boxes
> [!NOTE]
> General contextual info and informational note.

> [!TIP]
> Helpful examination strategy or pro tip.

> [!IMPORTANT]
> Crucial instructions and exam timing requirements.

> [!WARNING]
> Warnings regarding penalization or common traps.

> [!CAUTION]
> High-risk mistakes to avoid during test conditions.

## Badges & Statuses
[badge:primary:IELTS 8.5] [badge:success:Passed] [badge:warning:In Progress] [badge:danger:Failed]
''',
    },
  ];

  late final TextEditingController _markdownInputController;
  bool _markdownCustomMode = false;
  int _markdownSampleIndex = 0;
  bool _markdownSelectable = false;
  bool _markdownShowLineNumbers = true;
  bool _markdownWordLookup = true;
  double _markdownFontSize = 14.5;

  // --- Sentence Builder State ---
  final TextEditingController _sentenceInputController = TextEditingController(
    text: 'Researchers must articulate complex data with meticulous precision.',
  );
  bool _isSentenceChecked = true;
  int _sentenceScore = 92;
  String _sentenceFeedback =
      'Outstanding! Perfect usage of "meticulous" as an adjective modifying "precision". High lexical band score.';

  // --- AI Writing State ---
  int _selectedWritingCriterion = 0; // 0: Task, 1: Coherence, 2: Lexical, 3: Grammar

  // --- Speaking Lab State ---
  bool _isPlayingAudio = false;
  bool _isRecording = false;
  bool _hasRecorded = true;
  double _speakingMatchScore = 96.0;

  // --- Grammar Diagnostics State ---
  int _selectedMistakeIndex = 0;
  bool _isGrammarFixed = false;
  final List<Map<String, dynamic>> _grammarMistakes = [
    {
      'original': 'Space exploration allow researchers to discover new technologies.',
      'corrected': 'Space exploration allows researchers to discover new technologies.',
      'errorWord': 'allow',
      'fixWord': 'allows',
      'rule': 'Subject-Verb Agreement: "exploration" is a singular noun, requiring the third-person singular verb "allows".',
      'category': 'Subject-Verb Agreement',
    },
    {
      'original': 'She is capable to solve complicated algorithmic problems.',
      'corrected': 'She is capable of solving complicated algorithmic problems.',
      'errorWord': 'to solve',
      'fixWord': 'of solving',
      'rule': 'Preposition Collocation: The adjective "capable" is followed by the preposition "of" + gerund (-ing).',
      'category': 'Preposition Usage',
    },
    {
      'original': 'Despite of the heavy rain, the examination continued.',
      'corrected': 'Despite the heavy rain, the examination continued.',
      'errorWord': 'Despite of',
      'fixWord': 'Despite',
      'rule': 'Prepositional Form: "Despite" is used without "of" (contrast with "in spite of").',
      'category': 'Conjunction & Preposition',
    },
  ];

  // --- Listening Lab State ---
  bool _isPlayingVideoSnippet = false;
  double _playbackSpeed = 1.0;

  // --- IELTS Test Lab State ---
  int _ieltsLabQuestionIndex = 0; // 0: MCQ Single, 1: Fill Blank, 2: TFNG, 3: Matching Headings
  String? _ieltsLabSelectedOption;
  String? _ieltsLabTfngOption;
  final TextEditingController _ieltsLabBlankController =
      TextEditingController(text: 'evapotranspiration');
  String? _ieltsLabSelectedHeading;

  @override
  void initState() {
    super.initState();
    _selectedSample = _samples.first;
    _customTextController = TextEditingController(
      text:
          'Tap any word in this sentence to experience the custom interactive dropdown with live dictionary phonetics and audio playback!',
    );
    _markdownInputController = TextEditingController(
      text: _markdownLabSamples.first['content'],
    );
  }

  @override
  void dispose() {
    _customTextController.dispose();
    _markdownInputController.dispose();
    _sentenceInputController.dispose();
    _ieltsLabBlankController.dispose();
    super.dispose();
  }

  void _onWordTapped(String word) {
    if (!_lookupHistory.contains(word)) {
      setState(() {
        _lookupHistory.insert(0, word);
        if (_lookupHistory.length > 8) {
          _lookupHistory.removeLast();
        }
      });
    }
  }

  void _onWordSaved(WordLookupInfo info, bool isSaved) {
    setState(() {
      _savedCount =
          isSaved ? _savedCount + 1 : (_savedCount > 0 ? _savedCount - 1 : 0);
    });
  }

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.science_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Interactive Lab Hub',
              style: AppTypography.h3.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
              )
            : null,
        elevation: 0,
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bookmark_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Saved: $_savedCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lab Intro Banner
            _buildHeroBanner(isDark),
            const SizedBox(height: 16),

            // Category Filter Navigation Bar
            _buildCategoryFilterBar(isDark),
            const SizedBox(height: 20),

            // 1. LOOK UP WORDS (Interactive Text) - Always first category as requested
            if (_selectedCategory == LabCategory.all ||
                _selectedCategory == LabCategory.lookupWords) ...[
              _buildCategoryHeader(
                title: '1. Look Up Words (Interactive Reader)',
                subtitle:
                    'Tap any word in real time to trigger live IPA phonetics, instant dictionary definition & bookmarking.',
                category: LabCategory.lookupWords,
                badgeText: 'CORE FEATURE',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildLookupWordsExample(isDark),
              const SizedBox(height: 20),
            ],

            // 2. IELTS COMPREHENSIVE TESTING LAB (New Testing Page)
            if (_selectedCategory == LabCategory.all ||
                _selectedCategory == LabCategory.ieltsTestingLab) ...[
              _buildCategoryHeader(
                title: '2. IELTS Academic Reading & Testing Lab',
                subtitle:
                    'Simulate authentic IELTS tests using rich article passages with Multiple Choice, Fill in Blanks, True/False/Not Given, Matching Headings & Features.',
                category: LabCategory.ieltsTestingLab,
                badgeText: 'FULL EXAM SIMULATOR',
                isDark: isDark,
                onOpenFull: () =>
                    _navigateToScreen(const IeltsArticleTestScreen()),
              ),
              const SizedBox(height: 12),
              _buildIeltsTestLabExample(isDark),
              const SizedBox(height: 24),
            ],

            // 3. RICH MARKDOWN LAB (New Component)
            if (_selectedCategory == LabCategory.all ||
                _selectedCategory == LabCategory.richMarkdown) ...[
              _buildCategoryHeader(
                title: '3. Grammar Article & Rich Markdown Engine',
                subtitle:
                    'Read full masterclass lessons with GitHub callout alerts, interactive copyable code blocks, GFM tables, checklists, custom badges & instant word lookup.',
                category: LabCategory.richMarkdown,
                badgeText: 'RICH FORMATTING',
                isDark: isDark,
                onOpenFull: () =>
                    _navigateToScreen(const GrammarArticleScreen()),
              ),
              const SizedBox(height: 12),
              _buildRichMarkdownLabExample(isDark),
              const SizedBox(height: 24),
            ],

            // SPONSORED NATIVE AD SECTION
            if (_selectedCategory == LabCategory.all ||
                _selectedCategory == LabCategory.sponsoredAds) ...[
              _buildCategoryHeader(
                title: 'Sponsored Learning Partner (Native Ad)',
                subtitle:
                    'High-quality curated educational tools & Cambridge IELTS official practice resources.',
                category: LabCategory.sponsoredAds,
                badgeText: 'SPONSORED',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildAdSection(isDark),
              const SizedBox(height: 24),
            ],

            // 2. SENTENCE BUILDER LAB
            if (_selectedCategory == LabCategory.all ||
                _selectedCategory == LabCategory.sentenceBuilder) ...[
              _buildCategoryHeader(
                title: '2. Sentence Builder (Syntax & Collocation)',
                subtitle:
                    'Construct high-scoring sentences using target IELTS vocabulary and receive instant AI grammar analysis.',
                category: LabCategory.sentenceBuilder,
                badgeText: 'INTERACTIVE BUILDER',
                isDark: isDark,
                onOpenFull: () =>
                    _navigateToScreen(const SentenceBuilderScreen()),
              ),
              const SizedBox(height: 12),
              _buildSentenceBuilderExample(isDark),
              const SizedBox(height: 24),
            ],

            // 3. AI WRITING LAB
            if (_selectedCategory == LabCategory.all ||
                _selectedCategory == LabCategory.writingLab) ...[
              _buildCategoryHeader(
                title: '3. AI Writing Assistant (Diagnostic & Rubric)',
                subtitle:
                    'Examine multi-criterion IELTS Band 8.5 essay scoring breakdown with annotated lexical & coherence highlights.',
                category: LabCategory.writingLab,
                badgeText: 'EVALUATION ENGINE',
                isDark: isDark,
                onOpenFull: () => _navigateToScreen(const WritingScreen()),
              ),
              const SizedBox(height: 12),
              _buildWritingLabExample(isDark),
              const SizedBox(height: 24),
            ],

            // 4. SPEAKING & PRONUNCIATION LAB
            if (_selectedCategory == LabCategory.all ||
                _selectedCategory == LabCategory.speakingLab) ...[
              _buildCategoryHeader(
                title: '4. Speaking & Pronunciation (Voice & Phonetics)',
                subtitle:
                    'Practice syllable stress, listen to native phonetic audio, and evaluate spoken accuracy with speech waveforms.',
                category: LabCategory.speakingLab,
                badgeText: 'VOICE AI',
                isDark: isDark,
                onOpenFull: () => _navigateToScreen(const SpeakingScreen()),
              ),
              const SizedBox(height: 12),
              _buildSpeakingLabExample(isDark),
              const SizedBox(height: 24),
            ],

            // 5. GRAMMAR DIAGNOSTICS LAB
            if (_selectedCategory == LabCategory.all ||
                _selectedCategory == LabCategory.grammarDiagnostics) ...[
              _buildCategoryHeader(
                title: '5. Grammar Diagnostics (Error Detection & Fix)',
                subtitle:
                    'Identify subtle grammatical slips, analyze rule explanations, and apply instant one-tap corrections.',
                category: LabCategory.grammarDiagnostics,
                badgeText: 'SMART LINTER',
                isDark: isDark,
                onOpenFull: () =>
                    _navigateToScreen(const GrammarRoadmapScreen()),
              ),
              const SizedBox(height: 12),
              _buildGrammarDiagnosticsExample(isDark),
              const SizedBox(height: 24),
            ],

            // 6. VIDEO & LISTENING LAB
            if (_selectedCategory == LabCategory.all ||
                _selectedCategory == LabCategory.listeningLab) ...[
              _buildCategoryHeader(
                title: '6. Video & Listening (Interactive Transcripts)',
                subtitle:
                    'Synchronized video playback with interactive clickable subtitle text for native immersive listening.',
                category: LabCategory.listeningLab,
                badgeText: 'IMMERSIVE MEDIA',
                isDark: isDark,
                onOpenFull: () =>
                    _navigateToScreen(const YoutubeListeningScreen()),
              ),
              const SizedBox(height: 12),
              _buildListeningLabExample(isDark),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TOP BANNER & CATEGORY NAVIGATION
  // ==========================================

  Widget _buildHeroBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E2638),
                  const Color(0xFF161A26),
                ]
              : [
                  const Color(0xFFEBF3FF),
                  const Color(0xFFF3F7FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DSBadge(
                label: 'LAB CATEGORIES & PLAYGROUND',
                variant: DSBadgeVariant.primary,
              ),
              const Spacer(),
              Icon(
                Icons.bolt_rounded,
                size: 18,
                color: isDark ? AppColors.primary : AppColors.primaryHover,
              ),
              const SizedBox(width: 4),
              Text(
                '6 Interactive Labs + Ads',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.primary : AppColors.primaryHover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Interactive Text Lab',
            style: AppTypography.h2.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Explore live interactive tools by category starting with Look Up Words and integrated native sponsor placements.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterBar(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: LabCategory.values.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              avatar: Icon(
                category.icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              label: Text(category.label),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12.5,
              ),
              onSelected: (val) {
                if (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = category);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryHeader({
    required String title,
    required String subtitle,
    required LabCategory category,
    required String badgeText,
    required bool isDark,
    VoidCallback? onOpenFull,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppTypography.h2.copyWith(
                  fontSize: 17,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onOpenFull != null) ...[
              DSButton(
                text: 'Launch Tool →',
                variant: DSButtonVariant.ghost,
                size: DSButtonSize.sm,
                onPressed: onOpenFull,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.5,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CATEGORY 1: LOOK UP WORDS (INTERACTIVE TEXT)
  // ==========================================

  Widget _buildLookupWordsExample(bool isDark) {
    final displayText = _isCustomMode
        ? _customTextController.text
        : _selectedSample.passage;

    return DSCard(
      variant: DSCardVariant.elevated,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.touch_app_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                _isCustomMode
                    ? 'Custom Text Sandbox'
                    : _selectedSample.title,
                style: AppTypography.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isCustomMode ? 'Live Sandbox' : _selectedSample.tag,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode switch tabs
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Curated Passages')),
                  selected: !_isCustomMode,
                  onSelected: (val) {
                    if (val) setState(() => _isCustomMode = false);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Custom Sandbox')),
                  selected: _isCustomMode,
                  onSelected: (val) {
                    if (val) setState(() => _isCustomMode = true);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!_isCustomMode) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _samples.map((sample) {
                  final isSelected = sample.id == _selectedSample.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(sample.title),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedSample = sample);
                      },
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            TextField(
              controller: _customTextController,
              maxLines: 2,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Type or paste English text to explore words...',
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
          ],

          // Interactive Text Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF13151B)
                  : const Color(0xFFF9FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: DSInteractiveText(
              displayText,
              textAlign: _textAlign,
              style: TextStyle(
                fontSize: _fontSize,
                height: 1.6,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              highlightStyle: _highlightStyle,
              activeWordColor: _accentColor,
              dropdownPlacement: _placement,
              onWordTap: _onWordTapped,
              onWordSaved: _onWordSaved,
            ),
          ),
          const SizedBox(height: 12),

          // Mini Controls Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Placement:', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  DropdownButton<DSWordDropdownPlacement>(
                    value: _placement,
                    isDense: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: DSWordDropdownPlacement.auto,
                        child: Text('Auto', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: DSWordDropdownPlacement.above,
                        child: Text('Above', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: DSWordDropdownPlacement.below,
                        child: Text('Below', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: DSWordDropdownPlacement.bottomSheet,
                        child: Text('Sheet', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _placement = val);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Style:', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  DropdownButton<DSWordHighlightStyle>(
                    value: _highlightStyle,
                    isDense: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: DSWordHighlightStyle.dottedUnderline,
                        child: Text('Dotted', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: DSWordHighlightStyle.solidUnderline,
                        child: Text('Solid', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: DSWordHighlightStyle.backgroundHighlight,
                        child: Text('Highlight', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: DSWordHighlightStyle.plain,
                        child: Text('Plain', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _highlightStyle = val);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Size:', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  DropdownButton<double>(
                    value: _fontSize,
                    isDense: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 13.0, child: Text('13px', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 15.0, child: Text('15px', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 17.0, child: Text('17px', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 19.0, child: Text('19px', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _fontSize = val);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Lookup session history chips
          if (_lookupHistory.isNotEmpty) ...[
            const Divider(height: 20),
            Text(
              'Session Lookups:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _lookupHistory.map((w) {
                return InkWell(
                  onTap: () => _showQuickWordDialog(w),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_rounded,
                            size: 11, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          w,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORY 2: RICH MARKDOWN LAB (NEW)
  // ==========================================

  Widget _buildRichMarkdownLabExample(bool isDark) {
    final currentSample = _markdownLabSamples[_markdownSampleIndex];
    final displayMarkdown = _markdownCustomMode
        ? _markdownInputController.text
        : (currentSample['content'] ?? '');

    final markdownTheme = isDark
        ? DSRichMarkdownThemeData.dark(baseFontSize: _markdownFontSize)
        : DSRichMarkdownThemeData.light(baseFontSize: _markdownFontSize);

    return DSCard(
      variant: DSCardVariant.elevated,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_stories_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                _markdownCustomMode
                    ? 'Custom Markdown Editor'
                    : currentSample['title']!,
                style: AppTypography.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _markdownCustomMode ? 'Live Editor' : currentSample['tag']!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sample switch tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(_markdownLabSamples.length, (i) {
                  final isSelected = !_markdownCustomMode && _markdownSampleIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(_markdownLabSamples[i]['title']!),
                      selected: isSelected,
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _markdownCustomMode = false;
                            _markdownSampleIndex = i;
                          });
                        }
                      },
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    avatar: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Custom Editor'),
                    selected: _markdownCustomMode,
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _markdownCustomMode = true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Custom mode editor field
          if (_markdownCustomMode) ...[
            TextField(
              controller: _markdownInputController,
              maxLines: 5,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Type markdown syntax (# Heading, > [!NOTE], ```dart, etc.)...',
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),

            // Quick Insert Toolbar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMarkdownHelperChip('+ Note Alert', () {
                    _markdownInputController.text += '\n> [!NOTE]\n> Important note content here.\n';
                    setState(() {});
                  }),
                  _buildMarkdownHelperChip('+ Tip Alert', () {
                    _markdownInputController.text += '\n> [!TIP]\n> Pro strategy tip for IELTS candidates.\n';
                    setState(() {});
                  }),
                  _buildMarkdownHelperChip('+ Code Block', () {
                    _markdownInputController.text += '\n```dart\nvoid main() {\n  print("Easy English Mobile");\n}\n```\n';
                    setState(() {});
                  }),
                  _buildMarkdownHelperChip('+ Table', () {
                    _markdownInputController.text += '\n| Criterion | Score | Status |\n| :--- | :--- | :--- |\n| Lexical Resource | 8.5 | [badge:success:Passed] |\n';
                    setState(() {});
                  }),
                  _buildMarkdownHelperChip('+ Highlight', () {
                    _markdownInputController.text += ' ==critical lexical item== ';
                    setState(() {});
                  }),
                  _buildMarkdownHelperChip('+ Badge', () {
                    _markdownInputController.text += ' [badge:primary:Band 8.5] ';
                    setState(() {});
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Rendered Rich Markdown Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF13151B)
                  : const Color(0xFFF9FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: DSRichMarkdown(
              displayMarkdown,
              themeData: markdownTheme,
              selectable: _markdownSelectable,
              showLineNumbers: _markdownShowLineNumbers,
              enableInteractiveWordLookup: _markdownWordLookup,
              onWordTap: _onWordTapped,
              onWordSaved: _onWordSaved,
              onTapLink: (text, href, title) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped link: ${href ?? text}'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Toggles & Settings Bar
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                onTap: () => setState(() => _markdownWordLookup = !_markdownWordLookup),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _markdownWordLookup
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: _markdownWordLookup
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                    const SizedBox(width: 4),
                    const Text('Word Lookup Popover', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              InkWell(
                onTap: () => setState(() => _markdownShowLineNumbers = !_markdownShowLineNumbers),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _markdownShowLineNumbers
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: _markdownShowLineNumbers
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                    const SizedBox(width: 4),
                    const Text('Code Line Numbers', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              InkWell(
                onTap: () => setState(() => _markdownSelectable = !_markdownSelectable),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _markdownSelectable
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: _markdownSelectable
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                    const SizedBox(width: 4),
                    const Text('Selectable Text', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Size:', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  DropdownButton<double>(
                    value: _markdownFontSize,
                    isDense: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 13.0, child: Text('13px', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 14.5, child: Text('14.5px', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 16.0, child: Text('16px', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 18.0, child: Text('18px', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _markdownFontSize = val);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Action Launch Full Showcase Button
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              DSButton(
                text: 'Read Full Grammar Article 📖',
                variant: DSButtonVariant.secondary,
                size: DSButtonSize.sm,
                onPressed: () => _navigateToScreen(const GrammarArticleScreen()),
              ),
              DSButton(
                text: 'Markdown Playground →',
                variant: DSButtonVariant.ghost,
                size: DSButtonSize.sm,
                onPressed: () => _navigateToScreen(const RichMarkdownPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownHelperChip(String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }


  // ==========================================
  // SPONSORED NATIVE AD INTEGRATION SECTION
  // ==========================================

  Widget _buildAdSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Live Google AdMob Banner
        const AdMobBannerWidget(
          adSize: AdSize.banner,
        ),
        const SizedBox(height: 12),

        // 2. Google AdMob Formats & Test Actions
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on_rounded,
                          size: 18, color: AppColors.accentGreenDark),
                      const SizedBox(width: 6),
                      Text(
                        'Google AdMob Ads (${AdMobService.useTestAds ? "Test Mode" : "Live"})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        AdMobService.useTestAds = !AdMobService.useTestAds;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AdMobService.useTestAds
                              ? 'Switched to Google Sample Test Ads (100% fill rate)'
                              : 'Switched to your Real Production Ad Unit (ca-app-pub-3040613611393529/9398408010)'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: DSBadge(
                      label: AdMobService.useTestAds
                          ? 'TEST ADS (ACTIVE)'
                          : 'LIVE PRODUCTION',
                      variant: AdMobService.useTestAds
                          ? DSBadgeVariant.warning
                          : DSBadgeVariant.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Test all Google ad formats. Rewarded ads give users in-app rewards when completed.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Rewarded Video Action
                  DSButton(
                    text: 'Rewarded Video (+5 Credits)',
                    variant: DSButtonVariant.primary,
                    size: DSButtonSize.sm,
                    leftIcon: const Icon(Icons.video_collection_rounded, size: 14),
                    onPressed: () {
                      AdMobService.showRewardedAd(
                        onUserEarnedReward: (reward) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🎉 Earned +${reward.amount} ${reward.type} for watching video ad!',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Interstitial Ad Action
                  DSButton(
                    text: 'Interstitial Ad',
                    variant: DSButtonVariant.outline,
                    size: DSButtonSize.sm,
                    leftIcon: const Icon(Icons.fullscreen_rounded, size: 14),
                    onPressed: () {
                      AdMobService.showInterstitialAd(
                        onAdClosed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Interstitial Ad closed.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // App Open Ad Action
                  DSButton(
                    text: 'App Open Ad',
                    variant: DSButtonVariant.outline,
                    size: DSButtonSize.sm,
                    leftIcon: const Icon(Icons.open_in_browser_rounded, size: 14),
                    onPressed: () {
                      AdMobService.showAppOpenAd(
                        onAdClosed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('App Open Ad closed.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Rewarded Interstitial Action
                  DSButton(
                    text: 'Rewarded Interstitial',
                    variant: DSButtonVariant.outline,
                    size: DSButtonSize.sm,
                    leftIcon: const Icon(Icons.card_giftcard_rounded, size: 14),
                    onPressed: () {
                      AdMobService.showRewardedInterstitialAd(
                        onUserEarnedReward: (reward) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🎉 Earned +${reward.amount} ${reward.type} from Rewarded Interstitial!',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CATEGORY 2: SENTENCE BUILDER LAB
  // ==========================================

  Widget _buildSentenceBuilderExample(bool isDark) {
    return DSCard(
      variant: DSCardVariant.elevated,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded,
                  size: 18, color: AppColors.accentGreenDark),
              const SizedBox(width: 6),
              Text(
                'Target Word: meticulous (adj.)',
                style: AppTypography.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const DSBadge(
            label: 'C1 ADVANCED',
            variant: DSBadgeVariant.success,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Definition: Showing great attention to detail; very careful and precise.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Interactive input field
          TextField(
            controller: _sentenceInputController,
            maxLines: 2,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Compose a sentence using "meticulous"...',
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 10),

          // Suggestion pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ActionChip(
                label: const Text('Try: "meticulous analysis"'),
                onPressed: () {
                  setState(() {
                    _sentenceInputController.text =
                        'The researcher carried out a meticulous analysis of the survey data.';
                  });
                },
              ),
              ActionChip(
                label: const Text('Try: "meticulous attention"'),
                onPressed: () {
                  setState(() {
                    _sentenceInputController.text =
                        'Her meticulous attention to grammatical detail helped her achieve Band 8.5.';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action row
          Row(
            children: [
              DSButton(
                text: 'Evaluate Sentence',
                variant: DSButtonVariant.primary,
                size: DSButtonSize.sm,
                leftIcon: const Icon(Icons.check_circle_outline_rounded),
                onPressed: () {
                  setState(() {
                    _isSentenceChecked = true;
                    _sentenceScore = 94;
                    _sentenceFeedback =
                        'Excellent syntactic complexity and authentic C1 collocation usage.';
                  });
                },
              ),
              const Spacer(),
              if (_isSentenceChecked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Score: $_sentenceScore/100',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          if (_isSentenceChecked) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF131F1A)
                    : const Color(0xFFEBF7F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _sentenceFeedback,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORY 3: AI WRITING LAB
  // ==========================================

  Widget _buildWritingLabExample(bool isDark) {
    final List<Map<String, dynamic>> criteria = [
      {'name': 'Task Achievement', 'score': 'Band 8.5', 'color': AppColors.primary},
      {'name': 'Coherence', 'score': 'Band 8.0', 'color': AppColors.secondary},
      {'name': 'Lexical Resource', 'score': 'Band 9.0', 'color': AppColors.success},
      {'name': 'Grammar Accuracy', 'score': 'Band 8.5', 'color': AppColors.warning},
    ];

    return DSCard(
      variant: DSCardVariant.elevated,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'IELTS Task 2 Diagnostic Rubric',
                style: AppTypography.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const DSBadge(
            label: 'OVERALL: 8.5',
            variant: DSBadgeVariant.primary,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prompt card snippet
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Prompt: "Does technological advancement promote individual isolation or global connectivity?"',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Criteria Tabs
          Row(
            children: List.generate(criteria.length, (i) {
              final isSel = _selectedWritingCriterion == i;
              final scoreStr = criteria[i]['score'] as String;
              final nameStr = criteria[i]['name'] as String;
              return Expanded(
                child: InkWell(
                  onTap: () =>
                      setState(() => _selectedWritingCriterion = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Text(
                          scoreStr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : AppColors.primary,
                          ),
                        ),
                        Text(
                          nameStr.split(' ').first,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSel
                                ? Colors.white70
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Diagnostic detail box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF161A24)
                  : const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: criteria[_selectedWritingCriterion]['color'] as Color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${criteria[_selectedWritingCriterion]['name']} Analysis',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _getWritingCriterionFeedback(_selectedWritingCriterion),
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWritingCriterionFeedback(int index) {
    switch (index) {
      case 0:
        return 'Fully addresses all parts of the task with a well-developed position throughout. Arguments are supported with lucid, nuanced real-world examples.';
      case 1:
        return 'Skillfully manages paragraph transitions. Uses varied cohesive devices (e.g. "Consequently", "On the other hand") without noticeable mechanical repetition.';
      case 2:
        return 'Wide range of C1/C2 lexical items used with full flexibility and precision (e.g. "ubiquitous connectivity", "mitigate adverse ramifications").';
      case 3:
      default:
        return 'Majority of structures are complex sentences with error-free punctuation, subordinate clauses, and appropriate passive transformations.';
    }
  }

  // ==========================================
  // CATEGORY 4: SPEAKING & PRONUNCIATION LAB
  // ==========================================

  Widget _buildSpeakingLabExample(bool isDark) {
    return DSCard(
      variant: DSCardVariant.elevated,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.record_voice_over_rounded,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 6),
              Text(
                'Phonetics & Stress Analyzer',
                style: AppTypography.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const DSBadge(
            label: 'IPA ANALYSIS',
            variant: DSBadgeVariant.warning,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word & Syllable display
          Center(
            child: Column(
              children: [
                const Text(
                  'ubiquitous',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '/juːˈbɪk.wɪ.təs/',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _isPlayingAudio
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _isPlayingAudio = true);
                        Future.delayed(const Duration(milliseconds: 900), () {
                          if (mounted) setState(() => _isPlayingAudio = false);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Syllable breakdown pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'u • BIQ • ui • tous  (Stress on 2nd syllable)',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recording action area
          Row(
            children: [
              Expanded(
                child: DSButton(
                  text: _isRecording ? 'Listening...' : 'Record & Analyze',
                  variant: _isRecording
                      ? DSButtonVariant.danger
                      : DSButtonVariant.primary,
                  size: DSButtonSize.sm,
                  leftIcon: Icon(_isRecording ? Icons.mic : Icons.mic_none),
                  onPressed: () {
                    setState(() => _isRecording = !_isRecording);
                    if (_isRecording) {
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _isRecording = false;
                            _hasRecorded = true;
                            _speakingMatchScore = 98.0;
                          });
                        }
                      });
                    }
                  },
                ),
              ),
              if (_hasRecorded) ...[
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.speed_rounded,
                          size: 16, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        '${_speakingMatchScore.toStringAsFixed(0)}% Match',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORY 5: GRAMMAR DIAGNOSTICS LAB
  // ==========================================

  Widget _buildGrammarDiagnosticsExample(bool isDark) {
    final currentMistake = _grammarMistakes[_selectedMistakeIndex];

    return DSCard(
      variant: DSCardVariant.elevated,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.spellcheck_rounded,
                  size: 18, color: AppColors.danger),
              const SizedBox(width: 6),
              Text(
                'Live Error Detector & Rule',
                style: AppTypography.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          DSBadge(
            label: currentMistake['category'] as String,
            variant: DSBadgeVariant.danger,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mistake switcher pills
          Row(
            children: List.generate(_grammarMistakes.length, (i) {
              final isSel = _selectedMistakeIndex == i;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: FilterChip(
                  label: Text('Sample #${i + 1}'),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedMistakeIndex = i;
                        _isGrammarFixed = false;
                      });
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Diff Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? (_isGrammarFixed
                      ? const Color(0xFF131F1A)
                      : const Color(0xFF221518))
                  : (_isGrammarFixed
                      ? const Color(0xFFEBF7F0)
                      : const Color(0xFFFDECEE)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isGrammarFixed
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.danger.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isGrammarFixed
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      size: 16,
                      color:
                          _isGrammarFixed ? AppColors.success : AppColors.danger,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isGrammarFixed
                          ? 'Corrected Sentence:'
                          : 'Original with Error:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isGrammarFixed
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _isGrammarFixed
                      ? currentMistake['corrected'] as String
                      : currentMistake['original'] as String,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Rule Explanation
          Text(
            'Grammar Rule: ${currentMistake['rule']}',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Fix button
          DSButton(
            text: _isGrammarFixed ? 'Reset Sample' : 'Apply 1-Tap Correction',
            variant: _isGrammarFixed
                ? DSButtonVariant.outline
                : DSButtonVariant.primary,
            size: DSButtonSize.sm,
            leftIcon: Icon(_isGrammarFixed
                ? Icons.restart_alt_rounded
                : Icons.auto_fix_high_rounded),
            onPressed: () {
              setState(() => _isGrammarFixed = !_isGrammarFixed);
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORY 6: VIDEO & LISTENING LAB
  // ==========================================

  Widget _buildListeningLabExample(bool isDark) {
    return DSCard(
      variant: DSCardVariant.elevated,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.ondemand_video_rounded,
                  size: 18, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(
                'Synchronized Transcript Player',
                style: AppTypography.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const DSBadge(
            label: 'YOU-LISTEN',
            variant: DSBadgeVariant.neutral,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock Video Frame
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  iconSize: 42,
                  icon: Icon(
                    _isPlayingVideoSnippet
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(
                        () => _isPlayingVideoSnippet = !_isPlayingVideoSnippet);
                  },
                ),
                Positioned(
                  bottom: 8,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '01:24 / 04:50',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 12,
                  child: PopupMenuButton<double>(
                    initialValue: _playbackSpeed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_playbackSpeed}x',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                      const PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)')),
                      const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                      const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                    ],
                    onSelected: (spd) => setState(() => _playbackSpeed = spd),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Interactive Transcript with DSInteractiveText
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.subtitles_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Live Interactive Subtitle (Tap words below):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                DSInteractiveText(
                  'The cognitive architecture of memory demonstrates how episodic experiences are consolidated into long-term recall.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  onWordTap: _onWordTapped,
                  onWordSaved: _onWordSaved,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // IELTS COMPREHENSIVE TEST LAB EXAMPLE
  // ==========================================

  Widget _buildIeltsTestLabExample(bool isDark) {
    return DSCard(
      variant: DSCardVariant.elevated,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_turned_in_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'IELTS Reading & Question Simulator',
                style: AppTypography.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const DSBadge(
            label: 'C1 ACADEMIC • BAND 8.5',
            variant: DSBadgeVariant.primary,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article Context Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF19202E) : const Color(0xFFF1F5FD),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const DSBadge(label: 'Urban Architecture', variant: DSBadgeVariant.neutral),
                    const SizedBox(width: 8),
                    const DSBadge(label: 'Passage 2', variant: DSBadgeVariant.primary),
                    const Spacer(),
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '14 min read',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'The Urban Canopy: Vertical Forests & Biophilic Architecture',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                DSRichMarkdown(
                  '''By contrast, vertical canopies mitigate ambient thermal loading via ==evapotranspiration==—a physiological process whereby vegetation absorbs groundwater through roots and releases moisture vapor through stomata. Exterior wall temperatures drop by up to **14°C**, reducing mechanical HVAC requirements by **28%**.

> [!NOTE] Key Academic Collocation
> **Evapotranspiration** combines soil evaporation and plant transpiration for thermal equilibrium.''',
                  themeData: isDark
                      ? DSRichMarkdownThemeData.dark(baseFontSize: 13.5)
                      : DSRichMarkdownThemeData.light(baseFontSize: 13.5),
                  enableInteractiveWordLookup: true,
                  onWordTap: _onWordTapped,
                  onWordSaved: _onWordSaved,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Question Type Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.quiz_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Interactive Question Types:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              const DSBadge(label: 'LIVE DEMO', variant: DSBadgeVariant.success),
            ],
          ),
          const SizedBox(height: 10),

          // Question Type Switch Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildIeltsTypeChip(0, 'Multiple Choice (MCQ)', isDark),
                _buildIeltsTypeChip(1, 'Fill in the Blank', isDark),
                _buildIeltsTypeChip(2, 'True / False / Not Given', isDark),
                _buildIeltsTypeChip(3, 'Matching Headings', isDark),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Active Demo Question
          if (_ieltsLabQuestionIndex == 0) _buildIeltsLabMcqDemo(isDark),
          if (_ieltsLabQuestionIndex == 1) _buildIeltsLabBlankDemo(isDark),
          if (_ieltsLabQuestionIndex == 2) _buildIeltsLabTfngDemo(isDark),
          if (_ieltsLabQuestionIndex == 3) _buildIeltsLabHeadingDemo(isDark),

          const SizedBox(height: 16),

          // Launch Full IELTS Test Page Button
          DSButton(
            text: 'Launch Full IELTS Exam Page (3 Articles & 20+ Questions) →',
            variant: DSButtonVariant.primary,
            size: DSButtonSize.lg,
            fullWidth: true,
            leftIcon: const Icon(Icons.launch_rounded, size: 18),
            onPressed: () => _navigateToScreen(const IeltsArticleTestScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildIeltsTypeChip(int index, String label, bool isDark) {
    final isSelected = _ieltsLabQuestionIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
        onSelected: (val) {
          if (val) {
            setState(() => _ieltsLabQuestionIndex = index);
          }
        },
      ),
    );
  }

  Widget _buildIeltsLabMcqDemo(bool isDark) {
    final options = [
      'A: Reflecting ultraviolet photons',
      'B: Evapotranspiration of absorbed groundwater',
      'C: Creating permanent shadow cones across boulevards',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141720) : const Color(0xFFF9FAFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Q: According to Paragraph B, what is the primary mechanism by which vertical forests alleviate ambient heat?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          const SizedBox(height: 10),
          ...options.map((opt) {
            final letter = opt.split(':').first;
            final isSelected = _ieltsLabSelectedOption == letter;
            final isCorrect = letter == 'B';

            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _ieltsLabSelectedOption = letter);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isCorrect
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.danger.withValues(alpha: 0.15))
                        : (isDark ? Colors.white10 : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? (isCorrect ? AppColors.success : AppColors.danger)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(opt, style: const TextStyle(fontSize: 13)),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          size: 18,
                          color: isCorrect ? AppColors.success : AppColors.danger,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_ieltsLabSelectedOption == 'B')
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                '✓ Correct! "evapotranspiration—a physiological process whereby vegetation absorbs groundwater..."',
                style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIeltsLabBlankDemo(bool isDark) {
    final text = _ieltsLabBlankController.text.trim().toLowerCase();
    final isCorrect = text == 'evapotranspiration';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141720) : const Color(0xFFF9FAFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Q: Complete the sentence (NO MORE THAN TWO WORDS):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.warning),
          ),
          const SizedBox(height: 6),
          const Text(
            'Vertical canopies mitigate ambient thermal loading via the biological process of ______.',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ieltsLabBlankController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Type answer...',
              filled: true,
              fillColor: isDark ? Colors.white10 : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: isCorrect ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isCorrect ? '✓ Match found in Paragraph B!' : 'Target answer from passage: "evapotranspiration"',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isCorrect ? AppColors.success : AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIeltsLabTfngDemo(bool isDark) {
    final isTrue = _ieltsLabTfngOption == 'TRUE';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141720) : const Color(0xFFF9FAFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Q: The total vegetated area of Milan\'s Bosco Verticale is approximately ten times the land footprint it occupies.',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['TRUE', 'FALSE', 'NOT GIVEN'].map((opt) {
              final isSelected = _ieltsLabTfngOption == opt;
              final isCorr = opt == 'TRUE';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _ieltsLabTfngOption = opt);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isCorr
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.danger.withValues(alpha: 0.15))
                            : (isDark ? Colors.white10 : Colors.white),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? (isCorr ? AppColors.success : AppColors.danger)
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? (isCorr ? AppColors.success : AppColors.danger)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_ieltsLabTfngOption != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                isTrue
                    ? '✓ Correct! Paragraph A: 30,000 m² biomass on a 3,000 m² footprint (exactly 10x).'
                    : 'Paragraph A confirms 30,000 m² on 3,000 m² footprint (10x), so TRUE is correct.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isTrue ? AppColors.success : AppColors.danger,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIeltsLabHeadingDemo(bool isDark) {
    final headings = [
      'i. Financial reservations and maintenance practicalities',
      'ii. Thermodynamic advantages and ambient cooling',
      'iii. Psychological equilibrium and stress alleviation',
    ];
    final isCorrect = _ieltsLabSelectedHeading == 'ii';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141720) : const Color(0xFFF9FAFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Q: Match Paragraph B (ambient cooling and evapotranspiration) to its heading:',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ...headings.map((h) {
            final key = h.split('.').first.trim();
            final isSelected = _ieltsLabSelectedHeading == key;
            final isCorr = key == 'ii';

            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _ieltsLabSelectedHeading = key);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isCorr
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.danger.withValues(alpha: 0.15))
                        : (isDark ? Colors.white10 : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? (isCorr ? AppColors.success : AppColors.danger)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(h, style: const TextStyle(fontSize: 12.5))),
                      if (isSelected)
                        Icon(
                          isCorr ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          size: 18,
                          color: isCorr ? AppColors.success : AppColors.danger,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_ieltsLabSelectedHeading != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                isCorrect
                    ? '✓ Correct! Heading ii captures the thermodynamic cooling mechanisms of Paragraph B.'
                    : 'Heading ii (Thermodynamic advantages) best captures Paragraph B.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? AppColors.success : AppColors.danger,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // QUICK DIALOG POPUP
  // ==========================================

  Future<void> _showQuickWordDialog(String word) async {
    final info = await WordLookupDictionaryService().lookupWord(word);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: DSWordDropdownCard(
            info: info,
            onClose: () => Navigator.of(ctx).pop(),
            onSaveToggle: (saved) => _onWordSaved(info, saved),
          ),
        ),
      ),
    );
  }
}
