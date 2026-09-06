import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../core/theme/app_colors.dart';
import '../interactive_text/word_lookup_info.dart';
import 'ds_markdown_builders.dart';
import 'ds_markdown_syntaxes.dart';
import 'ds_rich_markdown_theme.dart';

/// A rich, modern, and highly-customizable Markdown renderer for the design system.
///
/// Features supported:
/// - All standard CommonMark & GitHub Flavored Markdown (GFM):
///   - Headings (H1 to H6)
///   - Bold (**text**), Italic (*text*), Strikethrough (~~text~~)
///   - Inline code (`code`) and Fenced Code Blocks (```lang ... ```) with syntax styling, line numbers & copy button
///   - GitHub Alert Callout Boxes (`> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`, `> [!INFO]`, `> [!SUCCESS]`, `> [!QUESTION]`)
///   - GFM Tables (`| col1 | col2 |`) with formatted headers, alternating rows & scroll containers
///   - Checklists & Task Lists (`- [x]`, `- [ ]`)
///   - Unordered and Ordered Lists with custom bullet spacing
///   - Custom highlights (`==text==` and `<mark>text</mark>`)
///   - Superscript (`^text^`) and Subscript (`~text~`)
///   - Custom Badges (`[badge:variant:label]`)
///   - Images (`![alt](url)`) with loading states, error fallbacks, and tap-to-zoom preview
///   - Links with custom link tap handling
///   - Optional Interactive Word Lookup mode (`enableInteractiveWordLookup: true`) for dictionary popovers on word tap
class DSRichMarkdown extends StatelessWidget {
  /// The raw markdown string to render.
  final String data;

  /// Custom theme configuration. If null, automatically adapts to the current Light or Dark theme.
  final DSRichMarkdownThemeData? themeData;

  /// Whether text within the markdown is selectable.
  final bool selectable;

  /// Whether the widget should shrink wrap its content.
  final bool shrinkWrap;

  /// Scroll physics if placed in a standalone scrollable context.
  final ScrollPhysics? physics;

  /// Padding around the rendered markdown.
  final EdgeInsets padding;

  /// Callback when a link is clicked.
  final void Function(String text, String? href, String title)? onTapLink;

  /// Whether words in text elements can be tapped to trigger vocabulary lookup.
  final bool enableInteractiveWordLookup;

  /// Callback when a word is clicked in interactive word mode.
  final ValueChanged<String>? onWordTap;

  /// Callback when a word is saved/bookmarked.
  final void Function(WordLookupInfo info, bool isSaved)? onWordSaved;

  /// Whether to display line numbers in code blocks.
  final bool showLineNumbers;

  /// Custom element builders to override or extend rendering.
  final Map<String, MarkdownElementBuilder>? customBuilders;

  /// Custom inline syntaxes to extend parsing.
  final List<md.InlineSyntax>? inlineSyntaxes;

  /// Custom block syntaxes to extend parsing.
  final List<md.BlockSyntax>? blockSyntaxes;

  /// Callback when a task list checkbox is toggled.
  final ValueChanged<bool>? onCheckboxChanged;

  const DSRichMarkdown(
    this.data, {
    super.key,
    this.themeData,
    this.selectable = false,
    this.shrinkWrap = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.onTapLink,
    this.enableInteractiveWordLookup = false,
    this.onWordTap,
    this.onWordSaved,
    this.showLineNumbers = false,
    this.customBuilders,
    this.inlineSyntaxes,
    this.blockSyntaxes,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = themeData ??
        (isDark
            ? DSRichMarkdownThemeData.dark()
            : DSRichMarkdownThemeData.light());

    final styleSheet = _buildStyleSheet(context, theme, isDark);

    // Prepare custom syntaxes
    final allInlineSyntaxes = <md.InlineSyntax>[
      DSHighlightSyntax(),
      DSMarkTagSyntax(),
      DSSuperscriptSyntax(),
      DSSubscriptSyntax(),
      DSBadgeSyntax(),
      ...?inlineSyntaxes,
    ];

    final allBlockSyntaxes = <md.BlockSyntax>[
      ...?blockSyntaxes,
    ];

    // Prepare builders
    final builders = <String, MarkdownElementBuilder>{
      'mark': DSHighlightBuilder(themeData: theme),
      'sup': DSSuperscriptBuilder(),
      'sub': DSSubscriptBuilder(),
      'ds-badge': DSBadgeElementBuilder(),
      'blockquote': DSBlockquoteBuilder(
        themeData: theme,
        isDark: isDark,
        onWordTap: onWordTap,
        onWordSaved: onWordSaved,
        enableInteractiveWordLookup: enableInteractiveWordLookup,
      ),
      'code': DSCodeBuilder(
        themeData: theme,
        isDark: isDark,
        showLineNumbers: showLineNumbers,
      ),
      'img': DSImageElementBuilder(
        themeData: theme,
        isDark: isDark,
      ),
      if (enableInteractiveWordLookup)
        'p': DSInteractiveParagraphBuilder(
          themeData: theme,
          isDark: isDark,
          enableInteractiveWordLookup: enableInteractiveWordLookup,
          onWordTap: onWordTap,
          onWordSaved: onWordSaved,
        ),
      ...?customBuilders,
    };

    final extensionSet = md.ExtensionSet(
      [
        ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        ...allBlockSyntaxes,
      ],
      [
        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
        ...allInlineSyntaxes,
      ],
    );

    Widget buildBullet(MarkdownBulletParameters params) {
      if (params.style == BulletStyle.orderedList) {
        return Padding(
          padding: (styleSheet.listBulletPadding ?? EdgeInsets.zero).add(const EdgeInsets.only(top: 2)),
          child: Text(
            '${params.index + 1}.',
            textAlign: TextAlign.right,
            style: styleSheet.listBullet,
          ),
        );
      }
      return Padding(
        padding: (styleSheet.listBulletPadding ?? EdgeInsets.zero).add(const EdgeInsets.only(top: 9.5)),
        child: Container(
          width: 5.0,
          height: 5.0,
          decoration: BoxDecoration(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    Widget buildCheckbox(bool checked) {
      final activeColor = isDark ? AppColors.primaryLight : AppColors.primary;
      final inactiveColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

      Widget box = Padding(
        padding: (styleSheet.listBulletPadding ?? EdgeInsets.zero).add(const EdgeInsets.only(top: 3.0)),
        child: Icon(
          checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
          size: 18,
          color: checked ? activeColor : inactiveColor,
        ),
      );

      if (onCheckboxChanged != null) {
        return GestureDetector(
          onTap: () => onCheckboxChanged!(!checked),
          behavior: HitTestBehavior.opaque,
          child: box,
        );
      }
      return box;
    }

    if (selectable) {
      return Padding(
        padding: padding,
        child: MarkdownBody(
          data: data,
          selectable: true,
          styleSheet: styleSheet,
          extensionSet: extensionSet,
          builders: builders,
          bulletBuilder: buildBullet,
          checkboxBuilder: buildCheckbox,
          listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
          onTapLink: (text, href, title) => _handleLinkTap(context, text, href, title),
          onTapText: () {},
        ),
      );
    }

    if (shrinkWrap) {
      return Padding(
        padding: padding,
        child: MarkdownBody(
          data: data,
          selectable: false,
          styleSheet: styleSheet,
          extensionSet: extensionSet,
          builders: builders,
          bulletBuilder: buildBullet,
          checkboxBuilder: buildCheckbox,
          listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
          onTapLink: (text, href, title) => _handleLinkTap(context, text, href, title),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Markdown(
        data: data,
        shrinkWrap: false,
        physics: physics,
        selectable: false,
        styleSheet: styleSheet,
        extensionSet: extensionSet,
        builders: builders,
        bulletBuilder: buildBullet,
        checkboxBuilder: buildCheckbox,
        listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
        onTapLink: (text, href, title) => _handleLinkTap(context, text, href, title),
      ),
    );
  }

  void _handleLinkTap(BuildContext context, String text, String? href, String title) {
    if (onTapLink != null) {
      onTapLink!(text, href, title);
      return;
    }

    // Default feedback when link is pressed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link tapped: ${href ?? text}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  MarkdownStyleSheet _buildStyleSheet(
    BuildContext context,
    DSRichMarkdownThemeData theme,
    bool isDark,
  ) {
    return MarkdownStyleSheet(
      p: theme.p,
      h1: theme.h1,
      h2: theme.h2,
      h3: theme.h3,
      h4: theme.h4,
      h5: theme.h5,
      h6: theme.h6,
      strong: theme.strong,
      em: theme.em,
      del: theme.del,
      a: theme.a,
      code: theme.inlineCode,
      blockquote: theme.blockquote,
      blockquotePadding: EdgeInsets.zero,
      blockquoteDecoration: const BoxDecoration(),
      codeblockPadding: EdgeInsets.zero,
      codeblockDecoration: const BoxDecoration(),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.hrColor,
            width: 1.2,
          ),
        ),
      ),
      tableHead: theme.tableHeader,
      tableBody: theme.tableBody,
      tableHeadAlign: TextAlign.left,
      tableColumnWidth: const IntrinsicColumnWidth(),
      tablePadding: const EdgeInsets.only(bottom: 12),
      tableScrollbarThumbVisibility: false,
      tableBorder: TableBorder.all(
        color: theme.tableBorder,
        width: 1.0,
        borderRadius: BorderRadius.circular(theme.tableBorderRadius),
      ),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      tableCellsDecoration: const BoxDecoration(),
      listBullet: TextStyle(
        color: isDark ? AppColors.primaryLight : AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: (theme.p.fontSize ?? 15) * 0.9,
      ),
      listBulletPadding: const EdgeInsets.only(right: 4),
      listIndent: theme.listIndent,
      pPadding: EdgeInsets.only(bottom: theme.blockSpacing),
      h1Padding: EdgeInsets.only(top: theme.blockSpacing * 1.2, bottom: theme.blockSpacing * 0.8),
      h2Padding: EdgeInsets.only(top: theme.blockSpacing * 1.1, bottom: theme.blockSpacing * 0.7),
      h3Padding: EdgeInsets.only(top: theme.blockSpacing, bottom: theme.blockSpacing * 0.6),
      h4Padding: EdgeInsets.only(top: theme.blockSpacing * 0.8, bottom: theme.blockSpacing * 0.5),
      h5Padding: EdgeInsets.only(top: theme.blockSpacing * 0.8, bottom: theme.blockSpacing * 0.5),
      h6Padding: EdgeInsets.only(top: theme.blockSpacing * 0.8, bottom: theme.blockSpacing * 0.5),
    );
  }
}
