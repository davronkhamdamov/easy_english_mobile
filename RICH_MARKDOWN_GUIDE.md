# 📖 Writing Rich Content with `DSRichMarkdown`

This documentation outlines how to write rich text, grammar articles, lesson notes, and tutorials using the `DSRichMarkdown` component in the Easy English Design System.

---

## 1. Quick Widget Usage in Flutter

To render rich markdown content anywhere in the app:

```dart
import 'package:easy_english/design_system/design_system.dart';

DSRichMarkdown(
  '''
  # Your Markdown Content
  Write your lesson text here...
  ''',
  enableInteractiveWordLookup: true, // Enables tap-to-lookup dictionary popovers
  selectable: false,                 // Set true for native text selection
)
```

---

## 2. Text Formatting & Highlights

| Formatting | Markdown Syntax | Visual Result |
| :--- | :--- | :--- |
| **Bold** | `**Important rule**` | **Important rule** |
| *Italic* | `*Emphasis word*` | *Emphasis word* |
| ~~Strikethrough~~ | `~~Incorrect form~~` | ~~Incorrect form~~ |
| `Inline Code` | `` `a university` `` | Monospace capsule |
| **Highlight Mark** | `==essential concept==` or `<mark>key rule</mark>` | Amber highlight pill (adapts to Light/Dark mode) |
| **Superscript** | `E = mc^2^` or `10^th^` | Small elevated text |
| **Subscript** | `H~2~O` | Small lowered text |

---

## 3. GitHub-Style Alert Callout Boxes

Use alert callouts to emphasize key rules, helpful strategies, and high-frequency traps.

### 📌 Note Callout
```markdown
> [!NOTE]
> General background context or information.
```

### 💡 Pro Tip Callout
```markdown
> [!TIP]
> Use this formula to achieve IELTS Band 7.5+ in Task 2 writing.
```

### 📢 Important Rule Callout
```markdown
> [!IMPORTANT] Phonetic Rule: Sound, Not Spelling!
> The choice between **a** and **an** is determined by the initial phonetic sound, not spelling.
```

### ⚠️ Warning Callout (Common Pitfalls)
```markdown
> [!WARNING] High-Frequency Error
> ❌ Do not say: *I am living here since 5 years.*
> ✅ Say: *I have lived here for 5 years.*
```

### 🛑 Caution Callout (Penalties & Traps)
```markdown
> [!CAUTION]
> Avoid memorized templates in IELTS speaking—examiners will penalize score bands.
```

---

## 4. UI Badges & Status Chips

Add colored badge chips inline anywhere in paragraphs, headers, or table cells:

```markdown
[badge:primary:IELTS Band 8.5]
[badge:success:Correct Form]
[badge:warning:In Progress]
[badge:danger:Common Mistake]
[badge:neutral:A2 - B2]
```

---

## 5. Tables (GitHub Flavored Markdown)

Tables automatically format with alternating row backgrounds and clean borders:

```markdown
| Rule Condition | Correct Form | Example Phrase | Status |
| :--- | :--- | :--- | :--- |
| **Consonant Sound** | Use `a` | `a university`, `a European` | [badge:success:Valid] |
| **Vowel Sound** | Use `an` | `an honest man`, `an hour` | [badge:success:Valid] |
| **Plural / General** | Zero Article | `Researchers analyze data` | [badge:warning:Rule] |
```

---

## 6. Code Blocks with macOS Header & Copy Button

Fenced code blocks include syntax styling, language badges, macOS window dots, and 1-click clipboard copy:

````markdown
```dart
void checkArticle(String word) {
  if (word.startsWithVowelSound()) {
    print('Use an');
  } else {
    print('Use a');
  }
}
```
````

---

## 7. Lists & Task Checklists

### Bullet & Numbered Lists
```markdown
- Singular countable nouns require determiners.
- General uncountable nouns omit the definite article.
  - Sub-item with indentation.

1. Read the passage carefully.
2. Identify target vocabulary.
3. Complete the knowledge check quiz.
```

### Task Checklists
```markdown
- [x] Check vowel sounds vs spelling (`an hour` vs `a house`)
- [x] Verify subject-verb agreement with singular pronouns
- [ ] Practice conditionals in the Exercise screen
```

---

## 8. Complete Article Template

Below is a complete template demonstrating all features together:

```markdown
# 📚 Master English Articles: A, An, The & Zero Article

Articles are among the most frequent words in English, yet they present continuous hurdles for second-language learners.

---

## 1. The Indefinite Articles: "A" vs "An"

Indefinite articles refer to **non-specific singular countable nouns**.

> [!IMPORTANT] Phonetic Rule: Sound, Not Spelling!
> The choice between **a** and **an** is determined by the ==initial phonetic sound== of the following word, *not* the written vowel letter.

| Rule Condition | Correct Form | Example Phrase | Common Pitfall |
| :--- | :--- | :--- | :--- |
| **Consonant Sound** | Use `a` | `a university` (/juː/) | ❌ *an university* |
| **Vowel Sound** | Use `an` | `an honest man` (/ɒ/) | ❌ *a hour* |

---

## 2. Checklist for IELTS Writing

- [x] Check every singular countable noun has an article (`a`, `an`, `the`).
- [x] Avoid using `the` with general abstract nouns (`education`, `science`).
- [ ] Practice topic in [badge:primary:Grammar Exercise Screen].
```
