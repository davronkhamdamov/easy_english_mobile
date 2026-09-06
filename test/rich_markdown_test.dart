import 'package:easy_english/design_system/components/rich_markdown/ds_rich_markdown.dart';
import 'package:easy_english/design_system/components/rich_markdown/ds_rich_markdown_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DSRichMarkdown Widget Tests', () {
    testWidgets('renders basic markdown headings, bold, italic and list items', (tester) async {
      const markdown = '''
# Heading 1
## Heading 2
**Bold Text** and *Italic Text* and ~~Strikethrough~~

- Item 1
- Item 2
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSRichMarkdown(markdown),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Heading 1'), findsOneWidget);
      expect(find.textContaining('Heading 2'), findsOneWidget);
      expect(find.textContaining('Bold Text'), findsOneWidget);
      expect(find.textContaining('Item 1'), findsOneWidget);
    });

    testWidgets('renders GitHub callout alert box', (tester) async {
      const markdown = '''
> [!NOTE]
> This is a crucial note for testing.
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSRichMarkdown(markdown),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('NOTE'), findsOneWidget);
      expect(find.textContaining('This is a crucial note for testing.'), findsOneWidget);
    });

    testWidgets('renders code block with clean minimalist formatting', (tester) async {
      const markdown = '''
```dart
void main() {
  print("Hello Markdown");
}
```
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSRichMarkdown(markdown),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Hello Markdown'), findsOneWidget);
    });

    testWidgets('renders GFM table structure', (tester) async {
      const markdown = '''
| Band Score | CEFR Level |
| :--- | :--- |
| **8.5** | C1 Advanced |
| **9.0** | C2 Native |
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSRichMarkdown(markdown),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Band Score'), findsOneWidget);
      expect(find.textContaining('CEFR Level'), findsOneWidget);
      expect(find.textContaining('8.5'), findsOneWidget);
      expect(find.textContaining('C1 Advanced'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('renders custom badge syntax [badge:success:Passed]', (tester) async {
      const markdown = 'Assessment result: [badge:success:Passed]';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSRichMarkdown(markdown),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Passed'), findsOneWidget);
    });

    testWidgets('themeData dark and light factory constructors work properly', (tester) async {
      final lightTheme = DSRichMarkdownThemeData.light();
      final darkTheme = DSRichMarkdownThemeData.dark();

      expect(lightTheme.p.fontSize, 15.0);
      expect(darkTheme.p.fontSize, 15.0);
      expect(lightTheme.codeBlockBackground, isNotNull);
      expect(darkTheme.codeBlockBackground, isNotNull);
    });

    testWidgets('enableInteractiveWordLookup wraps paragraphs with clickable word tokens', (tester) async {
      String? tappedWord;
      const markdown = 'Articles are fundamental to mastering English fluency.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSRichMarkdown(
              markdown,
              enableInteractiveWordLookup: true,
              onWordTap: (w) => tappedWord = w,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Articles'), findsOneWidget);
      expect(find.text('fundamental'), findsOneWidget);

      await tester.tap(find.text('fundamental'));
      await tester.pump();

      expect(tappedWord, 'fundamental');
    });
  });
}

