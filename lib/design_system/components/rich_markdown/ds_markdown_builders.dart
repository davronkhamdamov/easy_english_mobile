import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../badge/ds_badge.dart';
import '../interactive_text/ds_interactive_text.dart';
import '../interactive_text/word_lookup_info.dart';
import 'ds_rich_markdown_theme.dart';

/// Builder for highlighted text (`<mark>` and `==text==`).
class DSHighlightBuilder extends MarkdownElementBuilder {
  final DSRichMarkdownThemeData themeData;

  DSHighlightBuilder({required this.themeData});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: themeData.highlightBackground,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: (preferredStyle ?? const TextStyle()).copyWith(
          color: themeData.highlightText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return visitElementAfter(element, preferredStyle ?? parentStyle);
  }
}

/// Builder for Superscript (`<sup>` and `^text^`).
class DSSuperscriptBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;
    final baseStyle = preferredStyle ?? const TextStyle();
    return Transform.translate(
      offset: Offset(0, -(baseStyle.fontSize ?? 14) * 0.35),
      child: Text(
        text,
        style: baseStyle.copyWith(
          fontSize: (baseStyle.fontSize ?? 14) * 0.75,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return visitElementAfter(element, preferredStyle ?? parentStyle);
  }
}

/// Builder for Subscript (`<sub>` and `~text~`).
class DSSubscriptBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;
    final baseStyle = preferredStyle ?? const TextStyle();
    return Transform.translate(
      offset: Offset(0, (baseStyle.fontSize ?? 14) * 0.25),
      child: Text(
        text,
        style: baseStyle.copyWith(
          fontSize: (baseStyle.fontSize ?? 14) * 0.75,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return visitElementAfter(element, preferredStyle ?? parentStyle);
  }
}

/// Builder for custom badge elements `<ds-badge variant="variant">Label</ds-badge>`.
class DSBadgeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final variantStr = element.attributes['variant']?.toLowerCase() ?? 'primary';
    final label = element.textContent.trim();

    DSBadgeVariant variant = DSBadgeVariant.primary;
    if (variantStr == 'success' || variantStr == 'green') {
      variant = DSBadgeVariant.success;
    } else if (variantStr == 'warning' || variantStr == 'yellow' || variantStr == 'amber') {
      variant = DSBadgeVariant.warning;
    } else if (variantStr == 'danger' || variantStr == 'error' || variantStr == 'red') {
      variant = DSBadgeVariant.danger;
    } else if (variantStr == 'neutral' || variantStr == 'gray' || variantStr == 'grey') {
      variant = DSBadgeVariant.neutral;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: DSBadge(
        label: label,
        variant: variant,
      ),
    );
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return visitElementAfter(element, preferredStyle ?? parentStyle);
  }
}

/// Builder for blockquotes, including GitHub Alert Callouts (`> [!NOTE]`, `> [!TIP]`, etc.).
class DSBlockquoteBuilder extends MarkdownElementBuilder {
  final DSRichMarkdownThemeData themeData;
  final bool isDark;
  final ValueChanged<String>? onWordTap;
  final void Function(WordLookupInfo, bool)? onWordSaved;
  final bool enableInteractiveWordLookup;

  DSBlockquoteBuilder({
    required this.themeData,
    required this.isDark,
    this.onWordTap,
    this.onWordSaved,
    this.enableInteractiveWordLookup = false,
  });

  static final RegExp _alertHeaderRegex = RegExp(
    r'\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION|INFO|SUCCESS|QUESTION)\]\s*(.*)',
    caseSensitive: false,
  );

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final rawText = element.textContent.trim();
    final match = _alertHeaderRegex.firstMatch(rawText);
    if (match != null) {
      final typeStr = (match.group(1) ?? 'NOTE').toLowerCase();
      final headerTail = (match.group(2) ?? '').trim();
      final fullMatchStr = match.group(0) ?? '';

      var bodyText = rawText.replaceFirst(fullMatchStr, '').trim();
      String title;
      if (bodyText.isEmpty) {
        bodyText = headerTail;
        title = _getTypeTitle(typeStr);
      } else {
        title = headerTail.isNotEmpty ? headerTail : _getTypeTitle(typeStr);
      }

      final calloutType = _parseCalloutType(typeStr);
      final primaryColor = calloutType.getPrimaryColor(isDark);
      final bgColor = calloutType.getBackgroundColor(isDark);
      final borderColor = calloutType.getBorderColor(isDark);

      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: themeData.blockSpacing * 0.7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.1),
                border: Border(
                  bottom: BorderSide(color: borderColor.withValues(alpha: 0.5)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    calloutType.icon,
                    size: 17,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: enableInteractiveWordLookup
                  ? DSInteractiveText(
                      bodyText,
                      style: themeData.p.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      isInteractive: true,
                      onWordTap: onWordTap,
                      onWordSaved: onWordSaved,
                    )
                  : Text(
                      bodyText,
                      style: themeData.p.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
            ),
          ],
        ),
      );
    }

    // Standard Blockquote
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: themeData.blockSpacing * 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: themeData.blockquoteBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: themeData.blockquoteBorder,
            width: 4,
          ),
        ),
      ),
      child: enableInteractiveWordLookup
          ? DSInteractiveText(
              rawText,
              style: themeData.blockquote,
              isInteractive: true,
              onWordTap: onWordTap,
              onWordSaved: onWordSaved,
            )
          : Text(
              rawText,
              style: themeData.blockquote,
            ),
    );
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return visitElementAfter(element, preferredStyle ?? parentStyle);
  }

  String _getTypeTitle(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'tip':
        return 'Tip';
      case 'important':
        return 'Important';
      case 'warning':
        return 'Warning';
      case 'caution':
        return 'Caution';
      case 'info':
        return 'Info';
      case 'success':
        return 'Success';
      case 'question':
        return 'Question';
      default:
        return 'Note';
    }
  }

  DSAlertCalloutType _parseCalloutType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'tip':
        return DSAlertCalloutType.tip;
      case 'important':
        return DSAlertCalloutType.important;
      case 'warning':
        return DSAlertCalloutType.warning;
      case 'caution':
        return DSAlertCalloutType.caution;
      case 'info':
        return DSAlertCalloutType.info;
      case 'success':
        return DSAlertCalloutType.success;
      case 'question':
        return DSAlertCalloutType.question;
      default:
        return DSAlertCalloutType.note;
    }
  }
}

/// Builder for Code elements: handles both Fenced Code Blocks (`<pre>` / `<code>`) and Inline Code.
class DSCodeBuilder extends MarkdownElementBuilder {
  final DSRichMarkdownThemeData themeData;
  final bool isDark;
  final bool showLineNumbers;

  DSCodeBuilder({
    required this.themeData,
    required this.isDark,
    this.showLineNumbers = false,
  });

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return null;
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final rawCode = element.textContent;

    // Determine language from attributes
    String language = 'code';
    final classAttr = element.attributes['class'];
    if (classAttr != null && classAttr.startsWith('language-')) {
      language = classAttr.replaceFirst('language-', '');
    } else if (element.children != null) {
      for (final child in element.children!) {
        if (child is md.Element && child.attributes.containsKey('class')) {
          final cAttr = child.attributes['class']!;
          if (cAttr.startsWith('language-')) {
            language = cAttr.replaceFirst('language-', '');
            break;
          }
        }
      }
    }

    final isCodeBlock = element.tag == 'pre' || rawCode.contains('\n') || classAttr != null;

    if (!isCodeBlock) {
      // Inline code capsule
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(
          color: themeData.inlineCodeBackground,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: themeData.inlineCodeBorder, width: 0.8),
        ),
        child: Text(
          rawCode,
          style: themeData.inlineCode,
        ),
      );
    }

    return _CodeBlockCard(
      code: rawCode,
      language: language,
      themeData: themeData,
      isDark: isDark,
      showLineNumbers: showLineNumbers,
    );
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return visitElementAfter(element, preferredStyle ?? parentStyle);
  }
}

class _CodeBlockCard extends StatefulWidget {
  final String code;
  final String language;
  final DSRichMarkdownThemeData themeData;
  final bool isDark;
  final bool showLineNumbers;

  const _CodeBlockCard({
    required this.code,
    required this.language,
    required this.themeData,
    required this.isDark,
    this.showLineNumbers = false,
  });

  @override
  State<_CodeBlockCard> createState() => _CodeBlockCardState();
}

class _CodeBlockCardState extends State<_CodeBlockCard> {
  bool _copied = false;

  void _copyToClipboard() async {
    setState(() => _copied = true);
    try {
      await Clipboard.setData(ClipboardData(text: widget.code));
      HapticFeedback.lightImpact();
    } catch (_) {}

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cleanCode = widget.code.trimRight();
    final isDark = widget.isDark;

    final accentColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1);
    final bgColor = isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: widget.themeData.blockSpacing * 0.6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left subtle accent bar
            Container(
              width: 3.5,
              color: accentColor,
            ),
            // Body text container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SelectableText(
                  cleanCode,
                  style: (widget.themeData.p).copyWith(
                    fontSize: (widget.themeData.p.fontSize ?? 15.0) * 0.93,
                    height: 1.55,
                    letterSpacing: 0.1,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ),
            // Copy button
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 6),
              child: IconButton(
                icon: Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  size: 16,
                  color: _copied
                      ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                tooltip: 'Copy code',
                onPressed: _copyToClipboard,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/// Builder for image elements with thumbnail preview, loading spinner, and tap-to-zoom modal.
class DSImageElementBuilder extends MarkdownElementBuilder {
  final DSRichMarkdownThemeData themeData;
  final bool isDark;

  DSImageElementBuilder({required this.themeData, required this.isDark});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final src = element.attributes['src'] ?? '';
    final alt = element.attributes['alt'] ?? '';

    if (src.isEmpty) return const SizedBox.shrink();

    return _MarkdownImageCard(
      src: src,
      alt: alt,
      themeData: themeData,
      isDark: isDark,
    );
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return visitElementAfter(element, preferredStyle ?? parentStyle);
  }
}

class _MarkdownImageCard extends StatelessWidget {
  final String src;
  final String alt;
  final DSRichMarkdownThemeData themeData;
  final bool isDark;

  const _MarkdownImageCard({
    required this.src,
    required this.alt,
    required this.themeData,
    required this.isDark,
  });

  void _openImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(
                  src,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(32),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: const Text('Failed to load image preview'),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: themeData.blockSpacing * 0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _openImageDialog(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  src,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 36,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            alt.isNotEmpty ? alt : 'Image failed to load',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (alt.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              alt,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Builder for paragraph elements (`<p>`) that wraps text into [DSInteractiveText]
/// when interactive word lookup is enabled.
class DSInteractiveParagraphBuilder extends MarkdownElementBuilder {
  final DSRichMarkdownThemeData themeData;
  final bool isDark;
  final bool enableInteractiveWordLookup;
  final ValueChanged<String>? onWordTap;
  final void Function(WordLookupInfo, bool)? onWordSaved;

  DSInteractiveParagraphBuilder({
    required this.themeData,
    required this.isDark,
    required this.enableInteractiveWordLookup,
    this.onWordTap,
    this.onWordSaved,
  });

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    if (!enableInteractiveWordLookup) return null;
    return const SizedBox.shrink();
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (!enableInteractiveWordLookup) return null;

    final text = element.textContent.trim();
    if (text.isEmpty) return null;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: themeData.blockSpacing * 0.35),
      child: DSInteractiveText(
        text,
        style: (preferredStyle ?? themeData.p).copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        isInteractive: true,
        onWordTap: onWordTap,
        onWordSaved: onWordSaved,
      ),
    );
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return visitElementAfter(element, preferredStyle ?? parentStyle);
  }
}

