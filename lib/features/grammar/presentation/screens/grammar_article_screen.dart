import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../design_system/components/badge/ds_badge.dart';
import '../../../../design_system/components/button/ds_button.dart';
import '../../../../design_system/components/card/ds_card.dart';
import '../../../../design_system/components/rich_markdown/ds_rich_markdown.dart';
import '../../../../design_system/components/rich_markdown/ds_rich_markdown_theme.dart';
import '../../domain/entities/grammar_topic.dart';
import 'grammar_exercise_screen.dart';

/// Article model for grammar lessons.
class GrammarArticleData {
  final String id;
  final String title;
  final String category;
  final String cefrLevel;
  final String readTime;
  final String markdownContent;
  final List<GrammarQuizQuestion> quizQuestions;

  const GrammarArticleData({
    required this.id,
    required this.title,
    required this.category,
    required this.cefrLevel,
    required this.readTime,
    required this.markdownContent,
    required this.quizQuestions,
  });
}

/// Mini quiz question model for article knowledge check.
class GrammarQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const GrammarQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// Full comprehensive Grammar Article page rendered with [DSRichMarkdown],
/// supporting rich alerts, tables, formulas, interactive word lookups, and knowledge checks.
class GrammarArticleScreen extends StatefulWidget {
  final String? initialArticleId;
  final GrammarTopic? topic;
  final List<GrammarTopic>? allTopics;

  const GrammarArticleScreen({
    super.key,
    this.initialArticleId,
    this.topic,
    this.allTopics,
  });

  @override
  State<GrammarArticleScreen> createState() => _GrammarArticleScreenState();
}

class _GrammarArticleScreenState extends State<GrammarArticleScreen> {
  static const List<GrammarArticleData> _defaultArticles = [
    GrammarArticleData(
      id: 'articles_guide',
      title: 'English Articles: A, An, The & Zero Article',
      category: 'Determiners & Nouns',
      cefrLevel: 'A2 - B2',
      readTime: '5 min read',
      markdownContent: '''# 📚 Master English Articles: A, An, The & Zero Article

Articles are among the most frequent words in English, yet they present continuous hurdles for second-language learners. Understanding when to specify with **the**, generalize with **a/an**, or omit articles entirely is crucial for achieving high accuracy in academic writing and IELTS Band 7.0+.

---

## 1. The Indefinite Articles: "A" vs "An"

Indefinite articles refer to **non-specific** or **singular countable nouns** introduced for the first time.

> [!IMPORTANT] Phonetic Rule: Sound, Not Spelling!
> The choice between **a** and **an** is determined by the **initial phonetic sound** of the following word, *not* the written vowel letter.

| Rule Condition | Correct Form | Example Phrase | Common Pitfall |
| :--- | :--- | :--- | :--- |
| **Consonant Sound** | Use `a` | `a university` (/juː/), `a European`, `a one-way street` | ❌ *an university* |
| **Vowel Sound** | Use `an` | `an honest man` (/ɒ/), `an hour`, `an MBA graduate` | ❌ *a hour* |
| **Uncountable Nouns** | **No a/an** | `information`, `advice`, `research`, `furniture` | ❌ *an advice* |

> [!INFO] Quick Rule Formula
> **[A / An]** + **[Singular Countable Noun]** = First mention or any member of a group  
> *Example:* "She is conducting an investigation into urban mobility."

---

## 2. The Definite Article: "The"

Use **the** when both the speaker/writer and the listener/reader know the exact identity of the noun, or when the noun is **unique**.

### Key Usage Scenarios:
1. **Uniqueness:** Objects of which there is only one.
   - `The sun`, `the moon`, `the Internet`, `the atmosphere`.
2. **Second Mention:** When a noun has already been introduced.
   - *We conducted ==a preliminary survey==. **The survey** revealed compelling trends.*
3. **Superlatives & Ordinal Numbers:**
   - `The highest band score`, `the third chapter`, `the most influential factor`.
4. **Specified with Post-Modifiers (of-phrases / relative clauses):**
   - *The impact ==of climate change== on biodiversity.*

> [!TIP] IELTS Academic Writing Strategy
> In Task 1 data descriptions, always specify trends and variables with definite articles:
> `The percentage of car commuters...` (Specific data series)
> `The sharpest increase occurred in 2024...` (Superlative modifier)

---

## 3. Geographic Names: When to Use "The"

Geographical article rules follow precise syntactic structures:

| Category | Rule | Examples | Status |
| :--- | :--- | :--- | :--- |
| **Singular Countries** | No article (Zero) | `Uzbekistan`, `Germany`, `Japan`, `Canada` | [badge:neutral:Zero Article] |
| **Plural / Union Countries** | Use `The` | `The United Kingdom`, `The Netherlands`, `The USA` | [badge:primary:Use "The"] |
| **Mountain Ranges** | Use `The` | `The Himalayas`, `The Alps`, `The Andes` | [badge:primary:Use "The"] |
| **Individual Mountain Peaks** | No article | `Mount Everest`, `Mount Fuji`, `Kilimanjaro` | [badge:neutral:Zero Article] |
| **Oceans, Seas & Rivers** | Use `The` | `The Pacific Ocean`, `The Thames`, `The Nile` | [badge:primary:Use "The"] |

---

## 4. The Zero Article (No Article Needed)

The **Zero Article** (omission of an article) is applied in generalized academic statements:

> [!NOTE] Generalizing Principle
> When talking about things, concepts, or plural nouns **in general**, do **not** use `the`.

- ✅ *`Researchers` analyze data to discover patterns.* (General researchers everywhere)
- ❌ *`The researchers` analyze data to discover patterns.* (Incorrect unless referring to a specific previously mentioned team)
- ✅ *`Education` is the cornerstone of economic prosperity.* (Abstract uncountable noun)
- ❌ *`The education` is the cornerstone...* (Incorrect generalisation)

---

## 5. Summary Checklist for Writing & Speaking

- [x] Check every singular countable noun has an article or determiner (`a`, `an`, `the`, `my`, `this`).
- [x] Verify `a` vs `an` based on spoken initial phonetics (e.g., `an hour` vs `a historic day`).
- [x] Avoid using `the` with abstract uncountable nouns used in a general sense (`science`, `health`, `society`).
- [ ] Review country names and ensure unions/plurals include `The`.
''',
      quizQuestions: [
        GrammarQuizQuestion(
          question: 'Choose the correct sentence:',
          options: [
            'She applied for an scholarship at an university.',
            'She applied for a scholarship at a university.',
            'She applied for a scholarship at an university.',
            'She applied for the scholarship at the university in general.',
          ],
          correctIndex: 1,
          explanation: '"University" begins with the consonant sound /j/ (y-sound), so it takes "a university", not "an".',
        ),
        GrammarQuizQuestion(
          question: 'Which of the following geographical names requires "the"?',
          options: [
            'Mount Everest',
            'France',
            'United Kingdom',
            'Lake Baikal',
          ],
          correctIndex: 2,
          explanation: 'Countries containing political descriptions like "Kingdom", "States", or "Republic" take the definite article: "The United Kingdom".',
        ),
        GrammarQuizQuestion(
          question: 'Fill in the blank: "_____ research requires patience and meticulous methodology."',
          options: [
            'A',
            'An',
            'The',
            'Zero Article (No article)',
          ],
          correctIndex: 3,
          explanation: '"Research" is an uncountable noun used in a general statement, so it takes zero article.',
        ),
      ],
    ),
    GrammarArticleData(
      id: 'conditionals_guide',
      title: 'Conditional Sentences: Zero to 3rd & Mixed',
      category: 'Complex Sentences',
      cefrLevel: 'B1 - C1',
      readTime: '6 min read',
      markdownContent: '''# ⚡ Conditional Sentences: From Zero to Mixed

Conditional clauses express hypothetical scenarios, cause-effect relationships, and speculative reasoning in formal English.

---

## 1. Quick Structure & Formula Matrix

| Type | Condition Clause (If) | Result Clause | Function | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Zero** | `If + Present Simple` | `Present Simple` | Universal scientific facts & truths | [badge:neutral:Fact] |
| **First** | `If + Present Simple` | `Will + Base Verb` | Real & likely future possibilities | [badge:primary:Likely] |
| **Second** | `If + Past Simple` | `Would + Base Verb` | Hypothetical / unreal present or future | [badge:warning:Unreal Present] |
| **Third** | `If + Past Perfect` | `Would have + Past Participle` | Imaginary past events & regrets | [badge:danger:Unreal Past] |

> [!INFO] Advanced Inversion Formula (High Band Score)
> Instead of: *"If the government had enacted the policy..."*  
> Write: **"Had the government enacted the policy, societal outcomes would have improved."**

> [!TIP] IELTS Band 8.5 Tip: Formal Inversions
> In formal academic essays, replace standard `if` with inverted structures:
> - `Were governments to subsidize renewable energy...` (2nd Conditional Inversion)
> - `Had researchers conducted longitudinal trials...` (3rd Conditional Inversion)

---

## 2. Common Pitfall: "Would" in the If-Clause

> [!WARNING] Common Grammatical Slip
> Never place `would` or `will` inside the conditional *if-clause*!
> - ❌ *If you will study hard, you will pass.*
> - ✅ *If you study hard, you will pass.*
> - ❌ *If I would have known, I would have intervened.*
> - ✅ *If I had known, I would have intervened.*
''',
      quizQuestions: [
        GrammarQuizQuestion(
          question: 'Which sentence correctly demonstrates formal conditional inversion?',
          options: [
            'Had we recognized the warning signs, we would have mitigated the risks.',
            'If we had recognized the warning signs, we would mitigated the risks.',
            'Were we recognized the warning signs, we would have mitigated the risks.',
            'Had we recognize the warning signs, we would have mitigated the risks.',
          ],
          correctIndex: 0,
          explanation: '"Had we recognized..." is the correct inverted third conditional form replacing "If we had recognized...".',
        ),
      ],
    ),
    GrammarArticleData(
      id: 'subject_verb_agreement',
      title: 'Subject-Verb Agreement: Advanced Diagnostics',
      category: 'Syntax & Accuracy',
      cefrLevel: 'B1 - B2',
      readTime: '4 min read',
      markdownContent: '''# 🔍 Subject-Verb Agreement Rules & Pitfalls

Subject-verb agreement seems straightforward, yet intervening prepositional phrases and collective nouns frequently trigger errors.

---

## 1. Intervening Modifiers Trap

The verb agrees with the **core subject**, *not* with the noun in the prepositional modifier.

> [!IMPORTANT] Core Subject Rule
> Ignore the words between subject and verb:
> - *The collection of historic artifacts **is** on exhibition.* (`collection` is singular)
> - *The participants in the clinical study **are** monitored weekly.* (`participants` is plural)

---

## 2. Indefinite Pronouns Rule

| Pronoun Class | Examples | Governed Verb | Status |
| :--- | :--- | :--- | :--- |
| **Always Singular** | `Each`, `Every`, `Everyone`, `Neither`, `Either` | **Singular Verb** | [badge:primary:Singular] |
| **Always Plural** | `Both`, `Few`, `Several`, `Many` | **Plural Verb** | [badge:success:Plural] |
| **Variable (SANAM)** | `Some`, `Any`, `None`, `All`, `More` | Depends on context noun | [badge:warning:Variable] |

> [!WARNING] Pitfall: Neither / Either
> ❌ *Neither of the candidate solutions are viable.*
> ✅ *Neither of the candidate solutions **is** viable.*
''',
      quizQuestions: [
        GrammarQuizQuestion(
          question: 'Select the grammatically accurate sentence:',
          options: [
            'The bouquet of freshly picked flowers smell wonderful.',
            'The bouquet of freshly picked flowers smells wonderful.',
            'Each of the students have submitted their assignment.',
            'A wide range of technological innovations are being demonstrated.',
          ],
          correctIndex: 1,
          explanation: '"The bouquet" is the singular head noun, requiring the singular verb "smells".',
        ),
      ],
    ),
    GrammarArticleData(
      id: 'relative_clauses',
      title: 'Relative & Noun Clauses: Cohesion & Band 8+ Structures',
      category: 'Complex Sentences',
      cefrLevel: 'B2 - C1',
      readTime: '5 min read',
      markdownContent: '''# 🔗 Relative & Noun Clauses in Academic Writing

Relative clauses and noun clauses allow you to combine ideas efficiently, eliminating choppy short sentences and showcasing complex grammar.

---

## 1. Defining vs Non-Defining Relative Clauses

| Clause Type | Purpose | Commas Required? | Pronoun Restrictions |
| :--- | :--- | :--- | :--- |
| **Defining** | Identifies *which* specific item is meant | ❌ No commas | Can use `that`, `which`, `who` |
| **Non-Defining** | Adds extra, non-essential information | ✅ Yes, commas around clause | Never use `that`! Only `which`, `who` |

> [!IMPORTANT] The "That" Rule in Non-Defining Clauses
> Never use **that** inside a non-defining relative clause enclosed in commas:
> - ❌ *The new laboratory, that opened last month, features state-of-the-art equipment.*
> - ✅ *The new laboratory, **which** opened last month, features state-of-the-art equipment.*

---

## 2. Reduced Relative Clauses (Participle Clauses)

To make your academic sentences more concise, reduce relative clauses to present or past participle phrases:

> [!INFO] Relative Clause Reduction Formula
> **Full Form:** *"The participants who were selected for the study received stipends."*  
> **Reduced Form:** *"The participants selected for the study received stipends."*

> [!TIP] Band 8+ Cohesion Strategy
> Use sentential relative clauses with `which` to comment on an entire preceding clause:
> - *Global temperatures rose by 1.2°C, **which alarmed researchers worldwide**.*
''',
      quizQuestions: [
        GrammarQuizQuestion(
          question: 'Which sentence correctly punctuation-wise uses a non-defining relative clause?',
          options: [
            'Dr. Miller, who pioneered this methodology, delivered the keynote address.',
            'Dr. Miller that pioneered this methodology delivered the keynote address.',
            'Dr. Miller, that pioneered this methodology, delivered the keynote address.',
            'Dr. Miller who pioneered this methodology, delivered the keynote address.',
          ],
          correctIndex: 0,
          explanation: 'Non-defining clauses require commas and must use "who" (never "that") for persons.',
        ),
      ],
    ),
    GrammarArticleData(
      id: 'passive_voice',
      title: 'Passive Voice Mastery: Academic Reporting & Impersonal Style',
      category: 'Academic Style',
      cefrLevel: 'B2 - C1',
      readTime: '5 min read',
      markdownContent: '''# 🧪 Passive Voice for Academic & Scientific Writing

In scientific and academic discourse, the **action or result** is often more significant than the agent who performed it. Passive voice creates an objective, impersonal tone essential for IELTS Task 1 and Task 2.

---

## 1. Formation Formula

> [!INFO] Basic Passive Formula
> **[Subject]** + **[Appropriate tense of "be"]** + **[Past Participle (V3)]** (+ *[by Agent]*)  
> *Example:* "Five millilitres of solvent were added to the solution."

---

## 2. Impersonal Passive Structures (Reporting Verbs)

When presenting opinions, theories, or general consensus without attributing to yourself:

| Active Reporting | Impersonal Passive Structure | Formality |
| :--- | :--- | :--- |
| *People believe that...* | `It is believed that...` / `X is believed to be...` | [badge:primary:Formal] |
| *Scientists claim that...* | `It is widely claimed that...` | [badge:success:Academic] |
| *Many expect that...* | `The initiative is expected to reduce emissions...` | [badge:primary:Formal] |

> [!TIP] IELTS Task 1 Process Description
> In Task 1 manufacturing or natural cycle diagrams, 80%+ of verbs should be in the passive voice:
> - *The raw cocoa beans are harvested, cleaned, and fermented before being roasted.*
''',
      quizQuestions: [
        GrammarQuizQuestion(
          question: 'Convert into formal impersonal passive: "People widely acknowledge that solar power reduces emissions."',
          options: [
            'It is widely acknowledged that solar power reduces emissions.',
            'Solar power was widely acknowledging to reduce emissions.',
            'It was acknowledging widely that solar power reduce emissions.',
            'People are acknowledged that solar power is reducing emissions.',
          ],
          correctIndex: 0,
          explanation: '"It is widely acknowledged that..." is the correct formal impersonal passive construction.',
        ),
      ],
    ),
  ];

  late List<GrammarArticleData> _articles;
  late GrammarArticleData _selectedArticle;
  double _fontSize = 15.0;
  bool _isBookmarked = false;
  final bool _enableWordLookup = true;
  final Map<int, int?> _selectedAnswers = {};
  final Map<int, bool> _answeredQuestions = {};

  @override
  void initState() {
    super.initState();
    _articles = List.from(_defaultArticles);

    // Merge any topics provided via allTopics
    if (widget.allTopics != null && widget.allTopics!.isNotEmpty) {
      for (final t in widget.allTopics!) {
        final art = _topicToArticle(t);
        final existingIdx = _articles.indexWhere((a) => a.id == art.id);
        if (existingIdx >= 0) {
          _articles[existingIdx] = art;
        } else {
          _articles.add(art);
        }
      }
    }

    if (widget.topic != null) {
      final topicArticle = _topicToArticle(widget.topic!);
      final existingIndex = _articles.indexWhere((a) => a.id == topicArticle.id);
      if (existingIndex >= 0) {
        _articles[existingIndex] = topicArticle;
      } else {
        _articles.insert(0, topicArticle);
      }
      _selectedArticle = topicArticle;
    } else if (widget.initialArticleId != null) {
      _selectedArticle = _articles.firstWhere(
        (a) => a.id == widget.initialArticleId,
        orElse: () => _articles.first,
      );
    } else {
      _selectedArticle = _articles.first;
    }
  }

  GrammarArticleData _topicToArticle(GrammarTopic topic) {
    String content = topic.markdownContent;
    if (content.trim().isEmpty) {
      final buffer = StringBuffer();
      buffer.writeln('# 📚 ${topic.title}');
      buffer.writeln();
      if (topic.description.isNotEmpty) {
        buffer.writeln(topic.description);
        buffer.writeln();
      }
      buffer.writeln('---');
      buffer.writeln();
      if (topic.rules.isNotEmpty) {
        for (int i = 0; i < topic.rules.length; i++) {
          final rule = topic.rules[i];
          buffer.writeln('## ${i + 1}. ${rule.title}');
          buffer.writeln();
          if (rule.summary.isNotEmpty) {
            buffer.writeln('> [!NOTE] ${rule.summary}');
            buffer.writeln();
          }
          if (rule.detailedExplanation.isNotEmpty) {
            buffer.writeln(rule.detailedExplanation);
            buffer.writeln();
          }
          if (rule.examples.isNotEmpty) {
            buffer.writeln('### Key Examples:');
            for (final ex in rule.examples) {
              buffer.writeln('- `$ex`');
            }
            buffer.writeln();
          }
          if (rule.commonPitfalls.isNotEmpty) {
            buffer.writeln('> [!WARNING] Common Pitfalls');
            for (final pitfall in rule.commonPitfalls) {
              buffer.writeln('> - ❌ *$pitfall*');
            }
            buffer.writeln();
          }
          if (rule.tip != null && rule.tip!.isNotEmpty) {
            buffer.writeln('> [!TIP] Pro Tip');
            buffer.writeln('> ${rule.tip}');
            buffer.writeln();
          }
        }
      } else {
        buffer.writeln('## Core Concepts & Rules');
        buffer.writeln();
        buffer.writeln('> [!IMPORTANT] Essential Rule');
        buffer.writeln('> Understanding and practicing **${topic.title}** is crucial for IELTS Band 7.0+ accuracy.');
        buffer.writeln();
        buffer.writeln('Review the rules and exercises below to test your understanding.');
      }
      content = buffer.toString();
    }

    return GrammarArticleData(
      id: topic.id,
      title: topic.title,
      category: topic.category,
      cefrLevel: topic.cefrLevel,
      readTime: topic.readTime,
      markdownContent: content,
      quizQuestions: topic.exercises.map((e) {
        final corrIdx = e.options.indexWhere(
          (o) => o.trim().toLowerCase() == e.correctAnswer.trim().toLowerCase(),
        );
        return GrammarQuizQuestion(
          question: e.prompt.isNotEmpty ? e.prompt : (e.sentenceWithBlank ?? 'Question'),
          options: e.options,
          correctIndex: corrIdx >= 0 ? corrIdx : 0,
          explanation: e.explanation,
        );
      }).toList(),
    );
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Article saved to your Study Bookmarks!' : 'Removed from bookmarks.',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openExercise() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GrammarExerciseScreen(
          topic: widget.topic ??
              GrammarTopic(
                id: _selectedArticle.id,
                title: _selectedArticle.title,
                description: _selectedArticle.category,
                cefrLevel: _selectedArticle.cefrLevel,
                orderIndex: 1,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final markdownTheme = isDark
        ? DSRichMarkdownThemeData.dark(baseFontSize: _fontSize)
        : DSRichMarkdownThemeData.light(baseFontSize: _fontSize);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Grammar Masterclass',
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        actions: [
          // Text Size Action
          PopupMenuButton<double>(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Adjust text size',
            onSelected: (size) => setState(() => _fontSize = size),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 13.5, child: Text('Small (13.5px)')),
              const PopupMenuItem(value: 15.0, child: Text('Standard (15px)')),
              const PopupMenuItem(value: 17.0, child: Text('Large (17px)')),
              const PopupMenuItem(value: 19.0, child: Text('Extra Large (19px)')),
            ],
          ),
          // Bookmark Action
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? AppColors.primary : null,
            ),
            tooltip: 'Bookmark article',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Meta Banner Card
            _buildArticleHeaderCard(isDark),
            const SizedBox(height: 16),

            // Primary Rich Markdown Body (Rendered seamlessly directly on page)
            DSRichMarkdown(
              _selectedArticle.markdownContent,
              themeData: markdownTheme,
              enableInteractiveWordLookup: _enableWordLookup,
              showLineNumbers: true,
              onWordTap: (word) {
                // Handled by DSRichMarkdown interactive popover
              },
              onTapLink: (text, href, title) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped link: ${href ?? text}'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Knowledge Check Mini Quiz Section
            if (_selectedArticle.quizQuestions.isNotEmpty) ...[
              _buildKnowledgeCheckSection(isDark),
              const SizedBox(height: 24),
            ],

            // Action Practice Button
            _buildFooterActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleHeaderCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2638), const Color(0xFF161A26)]
              : [const Color(0xFFEBF3FF), const Color(0xFFF3F7FF)],
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
              DSBadge(
                label: _selectedArticle.cefrLevel,
                variant: DSBadgeVariant.primary,
              ),
              const SizedBox(width: 8),
              DSBadge(
                label: _selectedArticle.category,
                variant: DSBadgeVariant.neutral,
              ),
              const Spacer(),
              Icon(
                Icons.schedule_rounded,
                size: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                _selectedArticle.readTime,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _selectedArticle.title,
            style: AppTypography.h2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Master core grammatical rules, comparative formulas, and native collocations with instant interactive word definitions.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeCheckSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Knowledge Check (${_selectedArticle.quizQuestions.length} Questions)',
                  style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const DSBadge(label: 'QUICK QUIZ', variant: DSBadgeVariant.success),
          ],
        ),
        const SizedBox(height: 14),
        // Questions List
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_selectedArticle.quizQuestions.length, (qIndex) {
          final q = _selectedArticle.quizQuestions[qIndex];
          final selectedOption = _selectedAnswers[qIndex];
          final isAnswered = _answeredQuestions[qIndex] ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13151B) : const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${qIndex + 1}. ${q.question}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(q.options.length, (optIndex) {
                  final optionText = q.options[optIndex];
                  final isSelected = selectedOption == optIndex;
                  final isCorrect = optIndex == q.correctIndex;

                  Color itemBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
                  Color itemBg = Colors.transparent;

                  if (isAnswered) {
                    if (isCorrect) {
                      itemBorder = AppColors.success;
                      itemBg = AppColors.success.withValues(alpha: 0.12);
                    } else if (isSelected && !isCorrect) {
                      itemBorder = AppColors.danger;
                      itemBg = AppColors.danger.withValues(alpha: 0.12);
                    }
                  } else if (isSelected) {
                    itemBorder = AppColors.primary;
                    itemBg = AppColors.primary.withValues(alpha: 0.08);
                  }

                  return InkWell(
                    onTap: isAnswered
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedAnswers[qIndex] = optIndex;
                              _answeredQuestions[qIndex] = true;
                            });
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: itemBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: itemBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isAnswered && isCorrect
                                    ? AppColors.success
                                    : (isSelected ? AppColors.primary : itemBorder),
                                width: 1.5,
                              ),
                              color: isAnswered && isCorrect
                                  ? AppColors.success
                                  : (isSelected ? AppColors.primary : Colors.transparent),
                            ),
                            child: isAnswered && isCorrect
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : (isSelected
                                    ? const Icon(Icons.circle, size: 10, color: Colors.white)
                                    : null),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              optionText,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (isAnswered) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedOption == q.correctIndex
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          selectedOption == q.correctIndex
                              ? Icons.check_circle_outline_rounded
                              : Icons.info_outline_rounded,
                          size: 16,
                          color: selectedOption == q.correctIndex
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            q.explanation,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    ],
  );
}

  Widget _buildFooterActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: DSButton(
            text: 'Practice Exercises →',
            variant: DSButtonVariant.primary,
            size: DSButtonSize.lg,
            customBackgroundColor:
                isDark ? AppColors.brightSnow : AppColors.carbonBlack,
            customTextColor:
                isDark ? AppColors.carbonBlack : AppColors.brightSnow,
            leftIcon: const Icon(Icons.fitness_center_rounded, size: 18),
            onPressed: _openExercise,
          ),
        ),
      ],
    );
  }
}
