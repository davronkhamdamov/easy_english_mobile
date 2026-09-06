import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../components/badge/ds_badge.dart';
import '../components/button/ds_button.dart';
import '../components/card/ds_card.dart';
import '../components/rich_markdown/ds_rich_markdown.dart';
import '../components/rich_markdown/ds_rich_markdown_theme.dart';
import '../../../core/theme/app_theme.dart';
import 'component_page_wrapper.dart';

/// Design System dedicated investigation & playground page for [DSRichMarkdown].
class RichMarkdownPage extends StatefulWidget {
  final ThemeController? themeController;
  final VoidCallback? onBackToOverview;

  const RichMarkdownPage({
    super.key,
    this.themeController,
    this.onBackToOverview,
  });

  @override
  State<RichMarkdownPage> createState() => _RichMarkdownPageState();
}

class _RichMarkdownPageState extends State<RichMarkdownPage> {
  late final TextEditingController _controller;
  int _selectedPresetIndex = 0;

  // Customization knobs
  bool _selectable = false;
  bool _showLineNumbers = true;
  bool _enableWordLookup = true;
  double _baseFontSize = 15.0;

  static const List<Map<String, String>> _presets = [
    {
      'title': 'Full Feature Tour',
      'tag': 'All Formats',
      'markdown': '''# 🌟 Rich Markdown Component

Welcome to **DSRichMarkdown** — an advanced Markdown renderer supporting all CommonMark, GitHub Flavored Markdown (GFM), and extended rich features!

---

## 1. Typography & Inline Styles
You can use standard **bold text**, *italic emphasis*, ~~strikethrough text~~, and `inline_code()`.
We also support ==custom highlighters== and <mark>mark tags</mark>, plus superscripts E = mc^2^ and chemical formulas H~2~O.

Custom Badges: [badge:primary:IELTS Band 8.5] [badge:success:Passed] [badge:warning:Review Needed] [badge:danger:Critical]

---

## 2. GitHub Callout Alerts
> [!NOTE]
> This is a **Note** callout. Perfect for highlighting context and background info.

> [!TIP]
> **Pro Tip:** Read the questions before listening to the audio to anticipate answers!

> [!IMPORTANT]
> Time management is critical: spend no more than 20 minutes on Task 1.

> [!WARNING]
> Spelling and grammar errors will directly penalize your Lexical Resource score.

> [!CAUTION]
> Avoid memorized templates as examiners are trained to spot and penalize them.

---

## 3. Interactive Code Blocks
```dart
// Easy English Audio Player Engine
void playPronunciation(String word) async {
  final player = AudioPlayer();
  final audioUrl = 'https://api.easyenglish.uz/audio/\$word.mp3';
  await player.play(UrlSource(audioUrl));
  print('Playing phonetic audio for: \$word');
}
```

---

## 4. Rich Data Tables
| Band Score | CEFR Level | Description | Status |
| :--- | :--- | :--- | :--- |
| **9.0** | C2 Expert | Fluent with complete operational mastery | [badge:success:Fluent] |
| **8.0 - 8.5** | C1 Advanced | Fully operational command with minor slips | [badge:primary:Advanced] |
| **6.5 - 7.5** | B2 Competent | Effective command with occasional inaccuracies | [badge:warning:Target] |
| **5.0 - 6.0** | B1 Modest | Partial command coping in most situations | [badge:neutral:Foundational] |

---

## 5. Checklists & Task Lists
- [x] Master 570 Academic Word List (AWL) vocabulary items
- [x] Practice 4 full-length Listening tests under exam conditions
- [ ] Complete Task 2 essay on "Technological Innovation"
- [ ] Record 3 Part 2 Speaking cue cards

---

## 6. Embedded Media & Links
Explore official practice resources at [Cambridge English](https://www.cambridgeenglish.org) or visit the [IELTS IDP Portal](https://www.ieltsidp.com).
''',
    },
    {
      'title': 'IELTS Essay Rubric',
      'tag': 'Writing Diagnostic',
      'markdown': '''# 📝 IELTS Task 2 Essay Evaluation

**Prompt:** *Some people believe that artificial intelligence will replace teachers in the future. To what extent do you agree or disagree?*

---

### Candidate Response (Excerpt)
In the contemporary era, **artificial intelligence** has permeated various sectors, provoking debate regarding its potential to supersede human educators. While machine learning algorithms can provide ==personalized adaptive feedback==, I strongly contend that educators remain indispensable due to their empathetic guidance.

> [!TIP] Examiner Comment (Band 8.5)
> Excellent lexical density and sustained cohesive flow. Sentences demonstrate complex syntactic variety without compromising clarity.

### Band Breakdown
| Criterion | Score | Feedback |
| :--- | :--- | :--- |
| **Task Achievement** | **8.5** | Fully addresses all parts with clear position throughout |
| **Coherence & Cohesion** | **9.0** | Seamless paragraph transitions & logical progression |
| **Lexical Resource** | **8.5** | Sophisticated vocabulary (*permeated*, *supersede*, *indispensable*) |
| **Grammar Accuracy** | **8.5** | Wide range of complex structures with rare minor errors |

---

### Key Action Items for Improvement:
- [x] Diversify transitional adverbials across body paragraphs
- [ ] Strengthen concluding thesis with broader societal implications
- [ ] Review modal verb nuance in speculative argument clauses
''',
    },
    {
      'title': 'Grammar Diagnostics',
      'tag': 'Syntax & Rules',
      'markdown': '''# 🔍 Grammar Diagnostics: Subject-Verb Agreement

A thorough breakdown of subtle grammatical pitfalls frequently encountered in Academic English.

---

### Rule Overview
> [!NOTE] Rule Statement
> Singular indefinite pronouns (*each*, *every*, *neither*, *either*) strictly govern **singular verb forms** regardless of intervening prepositional modifiers.

#### ❌ Incorrect Usage:
`Each of the candidate responses have been scrutinised.`

#### ✅ Correct Usage:
`Each of the candidate responses has been scrutinised.`

---

### Collocation & Preposition Matrix
| Adjective | Preposition | Example Context |
| :--- | :--- | :--- |
| **capable** | `of` + gerund | *She is capable of solving algorithmic dilemmas.* |
| **adjacent** | `to` + noun | *The library is adjacent to the science center.* |
| **prone** | `to` + noun / -ing | *Learners are prone to making fossilised errors.* |
| **immune** | `to` / `from` | *No system is entirely immune to disruption.* |

> [!WARNING] Common Pitfall
> Do **not** use `despite of` — write either `despite the circumstance` or `in spite of the circumstance`.
''',
    },
    {
      'title': 'Technical Docs',
      'tag': 'Developer API',
      'markdown': '''# 🛠️ DSRichMarkdown Developer Guide

Render rich markdown with complete styling tokens, custom syntaxes, and event callbacks.

---

### Installation & Usage
```dart
import 'package:easy_english/design_system/design_system.dart';

// Render full rich markdown
DSRichMarkdown(
  markdownString,
  showLineNumbers: true,
  enableInteractiveWordLookup: true,
  onTapLink: (text, href, title) {
    print('Tapped link: \$href');
  },
)
```

### Supported Syntax Extensions
- **GitHub Alerts:** `> [!NOTE]`, `> [!TIP]`, `> [!WARNING]`, `> [!IMPORTANT]`, `> [!CAUTION]`
- **Highlights:** `==highlighter==` and `<mark>text</mark>`
- **Badges:** `[badge:variant:label]`
- **Math/Formulas:** Superscript `x^2^` and Subscript `H~2~O`
''',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _presets[0]['markdown']);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertMarkdown(String prefix, String suffix, {String fallback = 'text'}) {
    final text = _controller.text;
    final selection = _controller.selection;

    if (selection.start >= 0 && selection.end >= 0) {
      final selectedText = text.substring(selection.start, selection.end);
      final replacement = selectedText.isEmpty ? fallback : selectedText;
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$replacement$suffix',
      );
      _controller.text = newText;
      _controller.selection = TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + replacement.length,
      );
    } else {
      _controller.text = '$text\n$prefix$fallback$suffix';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = widget.themeController ?? ThemeController();

    return ComponentPageWrapper(
      title: 'DSRichMarkdown',
      subtitle:
          'Comprehensive Markdown engine supporting CommonMark, GFM, GitHub Alerts, copyable Code Blocks, Tables, Badges, Highlights & Word Lookup',
      category: 'Components',
      themeController: themeCtrl,
      onBackToOverview: widget.onBackToOverview,
      playground: _buildPlayground(context),
      matrix: _buildMatrix(context),
      codeSnippet: _buildCodeSnippet(context),
      specs: _buildSpecs(context),
    );
  }

  // --- 1. PLAYGROUND ---
  Widget _buildPlayground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final markdownTheme = isDark
        ? DSRichMarkdownThemeData.dark(baseFontSize: _baseFontSize)
        : DSRichMarkdownThemeData.light(baseFontSize: _baseFontSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_presets.length, (i) {
              final preset = _presets[i];
              final isSelected = _selectedPresetIndex == i;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(preset['title']!),
                  selected: isSelected,
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: AppColors.primary,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedPresetIndex = i;
                        _controller.text = preset['markdown']!;
                      });
                    }
                  },
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),

        // Controls Bar
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch.adaptive(
                  value: _selectable,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _selectable = v),
                ),
                const SizedBox(width: 4),
                const Text('Selectable Text', style: TextStyle(fontSize: 13)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch.adaptive(
                  value: _showLineNumbers,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _showLineNumbers = v),
                ),
                const SizedBox(width: 4),
                const Text('Line Numbers', style: TextStyle(fontSize: 13)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch.adaptive(
                  value: _enableWordLookup,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() => _enableWordLookup = v),
                ),
                const SizedBox(width: 4),
                const Text('Word Lookup', style: TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Font Size Slider
        Row(
          children: [
            Text(
              'Font Size: ${_baseFontSize.toStringAsFixed(1)}px',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Expanded(
              child: Slider.adaptive(
                value: _baseFontSize,
                min: 12.0,
                max: 22.0,
                divisions: 10,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _baseFontSize = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Quick Insert Toolbar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildToolbarBtn('H1', () => _insertMarkdown('# ', '', fallback: 'Heading 1')),
              _buildToolbarBtn('H2', () => _insertMarkdown('## ', '', fallback: 'Heading 2')),
              _buildToolbarBtn('Bold', () => _insertMarkdown('**', '**', fallback: 'bold text')),
              _buildToolbarBtn('Italic', () => _insertMarkdown('*', '*', fallback: 'italic text')),
              _buildToolbarBtn('Mark', () => _insertMarkdown('==', '==', fallback: 'highlighted')),
              _buildToolbarBtn('Note', () => _insertMarkdown('> [!NOTE]\n> ', '', fallback: 'Note content')),
              _buildToolbarBtn('Tip', () => _insertMarkdown('> [!TIP]\n> ', '', fallback: 'Tip content')),
              _buildToolbarBtn('Code', () => _insertMarkdown('```dart\n', '\n```', fallback: 'void main() {}')),
              _buildToolbarBtn('Table', () => _insertMarkdown('| Header 1 | Header 2 |\n| :--- | :--- |\n| Cell 1 | Cell 2 |', '')),
              _buildToolbarBtn('Badge', () => _insertMarkdown('[badge:success:', ']', fallback: 'Verified')),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 1. Live Render Output Card
        DSCard(
          variant: DSCardVariant.elevated,
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Live Render Output',
                    style: AppTypography.label.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const DSBadge(label: 'REALTIME RENDER', variant: DSBadgeVariant.success),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13151B) : const Color(0xFFF9FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: DSRichMarkdown(
              _controller.text,
              themeData: markdownTheme,
              selectable: _selectable,
              showLineNumbers: _showLineNumbers,
              enableInteractiveWordLookup: _enableWordLookup,
              onWordTap: (word) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Word tapped in Markdown: "$word"'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Raw Markdown Editor Card
        DSCard(
          variant: DSCardVariant.outlined,
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.code_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Markdown Source Editor',
                    style: AppTypography.label.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              DSButton(
                text: 'Copy Source',
                variant: DSButtonVariant.ghost,
                size: DSButtonSize.sm,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _controller.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Markdown source copied!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            maxLines: 10,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Type markdown syntax here...',
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  // --- 2. MATRIX ---
  Widget _buildMatrix(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMatrixSection(
          'GitHub Callout Alert Boxes',
          '''
> [!NOTE]
> **Note Box:** Highlights helpful background context.

> [!TIP]
> **Tip Box:** Advice and pro strategies for high band scores.

> [!IMPORTANT]
> **Important Box:** Essential examination instructions.

> [!WARNING]
> **Warning Box:** Critical errors and penalty warnings.

> [!CAUTION]
> **Caution Box:** High-risk actions to avoid.
''',
        ),
        const SizedBox(height: 16),
        _buildMatrixSection(
          'Interactive Code Blocks with Copy Button',
          '''
```dart
// Audio speech recognition stream handler
void startRecognition(String targetSentence) {
  _speech.listen(
    onResult: (result) => evaluatePhoneticMatch(result.recognizedWords, targetSentence),
    listenFor: const Duration(seconds: 15),
  );
}
```
''',
        ),
        const SizedBox(height: 16),
        _buildMatrixSection(
          'GFM Data Tables & Checklists',
          '''
| Band Score | CEFR Level | Criteria Met |
| :--- | :--- | :--- |
| **8.5 - 9.0** | C2 Native Mastery | [badge:success:Flawless] |
| **7.0 - 8.0** | C1 Advanced Command | [badge:primary:Target] |
| **5.5 - 6.5** | B2 Competent | [badge:warning:Review] |

- [x] Master 570 Academic Word List items
- [x] Practice full-length Listening module
- [ ] Record 3 Speaking Part 2 cue cards
''',
        ),
      ],
    );
  }

  Widget _buildMatrixSection(String title, String markdown) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DSCard(
      variant: DSCardVariant.outlined,
      header: Text(
        title,
        style: AppTypography.label.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: DSRichMarkdown(
        markdown,
        showLineNumbers: true,
      ),
    );
  }

  // --- 3. CODE SNIPPET ---
  Widget _buildCodeSnippet(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSRichMarkdown(
          '''
### Basic Usage
```dart
import 'package:easy_english/design_system/design_system.dart';

// Render rich markdown
DSRichMarkdown(
  """
  # IELTS Academic Reading
  In modern discourse, **cognitive resilience** is essential.

  > [!TIP] Pro Tip
  > Skim the headings before reading the detailed passage.

  ```dart
  void analyzeScore() => print("Band 8.5");
  ```
  """,
  showLineNumbers: true,
  enableInteractiveWordLookup: true,
  onWordTap: (word) => print("Tapped: \$word"),
)
```

### Full Configuration Props
| Property | Type | Description |
| :--- | :--- | :--- |
| `data` | `String` | Raw Markdown content string |
| `themeData` | `DSRichMarkdownThemeData?` | Custom theme tokens (defaults to theme mode) |
| `selectable` | `bool` | Enables text selection & copy |
| `showLineNumbers` | `bool` | Toggles line numbers in code blocks |
| `enableInteractiveWordLookup` | `bool` | Enables word click dictionary popovers |
| `onTapLink` | `Function(text, href, title)?` | Intercepts link clicks |
| `customBuilders` | `Map<String, MarkdownElementBuilder>?` | Extensible custom HTML/MD builders |
''',
          showLineNumbers: true,
        ),
      ],
    );
  }

  // --- 4. SPECS ---
  Widget _buildSpecs(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSRichMarkdown(
          '''
### Specifications & Supported Standards
- **CommonMark Spec:** Full specification compliance for paragraphs, headings H1..H6, emphasis, strong, blockquotes, lists, images, and links.
- **GitHub Flavored Markdown (GFM):** Tables (`| col1 | col2 |`), strikethrough (`~~text~~`), autolinks, and task lists (`- [x]`, `- [ ]`).
- **GitHub Alerts:** `> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`, `> [!INFO]`, `> [!SUCCESS]`, `> [!QUESTION]`.
- **Extended Rich Syntaxes:**
  - Highlights: `==text==` and `<mark>text</mark>`
  - Badges: `[badge:variant:label]`
  - Superscript: `^text^` and Subscript: `~text~`
  - Code Block Mac Toolbar with language tag and clipboard copy button
  - Tap-to-zoom interactive image viewer
  - Live Vocabulary Lookup Integration with CEFR level, phonetic IPA, and audio playback.
''',
        ),
      ],
    );
  }

  Widget _buildToolbarBtn(String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
