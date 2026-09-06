import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Callout / Alert types supported in rich markdown (GitHub style).
enum DSAlertCalloutType {
  note,
  tip,
  important,
  warning,
  caution,
  info,
  success,
  question,
}

extension DSAlertCalloutTypeMeta on DSAlertCalloutType {
  String get title {
    switch (this) {
      case DSAlertCalloutType.note:
        return 'Note';
      case DSAlertCalloutType.tip:
        return 'Tip';
      case DSAlertCalloutType.important:
        return 'Important';
      case DSAlertCalloutType.warning:
        return 'Warning';
      case DSAlertCalloutType.caution:
        return 'Caution';
      case DSAlertCalloutType.info:
        return 'Info';
      case DSAlertCalloutType.success:
        return 'Success';
      case DSAlertCalloutType.question:
        return 'Question';
    }
  }

  IconData get icon {
    switch (this) {
      case DSAlertCalloutType.note:
        return Icons.info_outline_rounded;
      case DSAlertCalloutType.tip:
        return Icons.lightbulb_outline_rounded;
      case DSAlertCalloutType.important:
        return Icons.announcement_outlined;
      case DSAlertCalloutType.warning:
        return Icons.warning_amber_rounded;
      case DSAlertCalloutType.caution:
        return Icons.report_problem_outlined;
      case DSAlertCalloutType.info:
        return Icons.help_outline_rounded;
      case DSAlertCalloutType.success:
        return Icons.check_circle_outline_rounded;
      case DSAlertCalloutType.question:
        return Icons.quiz_outlined;
    }
  }

  Color getPrimaryColor(bool isDark) {
    switch (this) {
      case DSAlertCalloutType.note:
      case DSAlertCalloutType.info:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
      case DSAlertCalloutType.tip:
      case DSAlertCalloutType.success:
        return isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      case DSAlertCalloutType.important:
        return isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED);
      case DSAlertCalloutType.warning:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
      case DSAlertCalloutType.caution:
        return isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      case DSAlertCalloutType.question:
        return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    }
  }

  Color getBackgroundColor(bool isDark) {
    final primary = getPrimaryColor(isDark);
    return primary.withValues(alpha: isDark ? 0.12 : 0.08);
  }

  Color getBorderColor(bool isDark) {
    final primary = getPrimaryColor(isDark);
    return primary.withValues(alpha: isDark ? 0.35 : 0.28);
  }
}

/// Comprehensive theme configuration for [DSRichMarkdown].
class DSRichMarkdownThemeData {
  final TextStyle p;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle h6;
  final TextStyle strong;
  final TextStyle em;
  final TextStyle del;
  final TextStyle a;
  final TextStyle inlineCode;
  final TextStyle codeBlock;
  final TextStyle blockquote;
  final TextStyle tableHeader;
  final TextStyle tableBody;

  // Colors
  final Color codeBlockBackground;
  final Color codeBlockBorder;
  final Color codeBlockHeaderBackground;
  final Color inlineCodeBackground;
  final Color inlineCodeBorder;
  final Color highlightBackground;
  final Color highlightText;
  final Color blockquoteBorder;
  final Color blockquoteBackground;
  final Color tableBorder;
  final Color tableHeaderBackground;
  final Color tableAltRowBackground;
  final Color hrColor;
  final Color checkboxActiveColor;

  // Dimensions
  final double blockSpacing;
  final double listIndent;
  final double codeBlockBorderRadius;
  final double tableBorderRadius;

  const DSRichMarkdownThemeData({
    required this.p,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.h5,
    required this.h6,
    required this.strong,
    required this.em,
    required this.del,
    required this.a,
    required this.inlineCode,
    required this.codeBlock,
    required this.blockquote,
    required this.tableHeader,
    required this.tableBody,
    required this.codeBlockBackground,
    required this.codeBlockBorder,
    required this.codeBlockHeaderBackground,
    required this.inlineCodeBackground,
    required this.inlineCodeBorder,
    required this.highlightBackground,
    required this.highlightText,
    required this.blockquoteBorder,
    required this.blockquoteBackground,
    required this.tableBorder,
    required this.tableHeaderBackground,
    required this.tableAltRowBackground,
    required this.hrColor,
    required this.checkboxActiveColor,
    this.blockSpacing = 14.0,
    this.listIndent = 14.0,
    this.codeBlockBorderRadius = 12.0,
    this.tableBorderRadius = 10.0,
  });

  factory DSRichMarkdownThemeData.light({
    Color? primaryColor,
    double baseFontSize = 15.0,
  }) {
    final primary = primaryColor ?? AppColors.primary;
    final textPrimary = AppColors.lightTextPrimary;
    final textSecondary = AppColors.lightTextSecondary;

    return DSRichMarkdownThemeData(
      p: AppTypography.bodyMd.copyWith(
        fontSize: baseFontSize,
        height: 1.65,
        color: textPrimary,
      ),
      h1: AppTypography.h1.copyWith(
        fontSize: baseFontSize * 1.6,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.3,
      ),
      h2: AppTypography.h2.copyWith(
        fontSize: baseFontSize * 1.35,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.35,
      ),
      h3: AppTypography.h3.copyWith(
        fontSize: baseFontSize * 1.15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      h4: TextStyle(
        fontSize: baseFontSize * 1.05,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      h5: TextStyle(
        fontSize: baseFontSize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      h6: TextStyle(
        fontSize: baseFontSize * 0.9,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        height: 1.4,
      ),
      strong: TextStyle(
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      em: TextStyle(
        fontStyle: FontStyle.italic,
        color: textPrimary,
      ),
      del: TextStyle(
        decoration: TextDecoration.lineThrough,
        color: textSecondary,
      ),
      a: TextStyle(
        color: primary,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      ),
      inlineCode: TextStyle(
        fontFamily: 'Courier',
        fontSize: baseFontSize * 0.88,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFC026D3),
      ),
      codeBlock: TextStyle(
        fontFamily: 'Courier',
        fontSize: baseFontSize * 0.88,
        height: 1.5,
        color: const Color(0xFF1E293B),
      ),
      blockquote: TextStyle(
        fontSize: baseFontSize,
        height: 1.6,
        fontStyle: FontStyle.italic,
        color: textSecondary,
      ),
      tableHeader: TextStyle(
        fontSize: baseFontSize * 0.9,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      tableBody: TextStyle(
        fontSize: baseFontSize * 0.88,
        color: textPrimary,
      ),
      codeBlockBackground: const Color(0xFFF1F5F9),
      codeBlockBorder: const Color(0xFFCBD5E1),
      codeBlockHeaderBackground: const Color(0xFFE2E8F0),
      inlineCodeBackground: const Color(0xFFFDF4FF),
      inlineCodeBorder: const Color(0xFFF0ABFC),
      highlightBackground: const Color(0xFFFEF08A),
      highlightText: const Color(0xFF854D0E),
      blockquoteBorder: primary,
      blockquoteBackground: primary.withValues(alpha: 0.05),
      tableBorder: const Color(0xFFE2E8F0),
      tableHeaderBackground: const Color(0xFFF8FAFC),
      tableAltRowBackground: const Color(0xFFF8FAFC),
      hrColor: const Color(0xFFE2E8F0),
      checkboxActiveColor: primary,
    );
  }

  factory DSRichMarkdownThemeData.dark({
    Color? primaryColor,
    double baseFontSize = 15.0,
  }) {
    final primary = primaryColor ?? AppColors.primary;
    final textPrimary = AppColors.darkTextPrimary;
    final textSecondary = AppColors.darkTextSecondary;

    return DSRichMarkdownThemeData(
      p: AppTypography.bodyMd.copyWith(
        fontSize: baseFontSize,
        height: 1.65,
        color: textPrimary,
      ),
      h1: AppTypography.h1.copyWith(
        fontSize: baseFontSize * 1.6,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.3,
      ),
      h2: AppTypography.h2.copyWith(
        fontSize: baseFontSize * 1.35,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.35,
      ),
      h3: AppTypography.h3.copyWith(
        fontSize: baseFontSize * 1.15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      h4: TextStyle(
        fontSize: baseFontSize * 1.05,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      h5: TextStyle(
        fontSize: baseFontSize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      h6: TextStyle(
        fontSize: baseFontSize * 0.9,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        height: 1.4,
      ),
      strong: TextStyle(
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      em: TextStyle(
        fontStyle: FontStyle.italic,
        color: textPrimary,
      ),
      del: TextStyle(
        decoration: TextDecoration.lineThrough,
        color: textSecondary,
      ),
      a: TextStyle(
        color: const Color(0xFF60A5FA),
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      ),
      inlineCode: TextStyle(
        fontFamily: 'Courier',
        fontSize: baseFontSize * 0.88,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF472B6),
      ),
      codeBlock: TextStyle(
        fontFamily: 'Courier',
        fontSize: baseFontSize * 0.88,
        height: 1.5,
        color: const Color(0xFFE2E8F0),
      ),
      blockquote: TextStyle(
        fontSize: baseFontSize,
        height: 1.6,
        fontStyle: FontStyle.italic,
        color: textSecondary,
      ),
      tableHeader: TextStyle(
        fontSize: baseFontSize * 0.9,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      tableBody: TextStyle(
        fontSize: baseFontSize * 0.88,
        color: textPrimary,
      ),
      codeBlockBackground: const Color(0xFF1E2638),
      codeBlockBorder: const Color(0xFF334155),
      codeBlockHeaderBackground: const Color(0xFF161A26),
      inlineCodeBackground: const Color(0xFF3B1D36),
      inlineCodeBorder: const Color(0xFF831843),
      highlightBackground: AppColors.warning.withValues(alpha: 0.35),
      highlightText: const Color(0xFFFDE68A),
      blockquoteBorder: primary,
      blockquoteBackground: primary.withValues(alpha: 0.1),
      tableBorder: const Color(0xFF334155),
      tableHeaderBackground: const Color(0xFF1E293B),
      tableAltRowBackground: const Color(0xFF131A29),
      hrColor: const Color(0xFF334155),
      checkboxActiveColor: primary,
    );
  }
}
