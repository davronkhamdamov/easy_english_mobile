import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Interactive multiple-choice option tile styled consistently with the IELTS test modules.
class VocabOptionTile extends StatelessWidget {
  final String optionText;
  final int index;
  final bool isSelected;
  final bool isSubmitted;
  final bool isCorrect;
  final VoidCallback? onTap;

  const VocabOptionTile({
    super.key,
    required this.optionText,
    required this.index,
    required this.isSelected,
    required this.isSubmitted,
    required this.isCorrect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final optionLetter = String.fromCharCode(65 + index);

    // Strip existing prefix if optionText already starts with "A) " etc.
    String cleanText = optionText;
    final prefixMatch = RegExp(r'^[A-D]\)\s*').firstMatch(optionText);
    if (prefixMatch != null) {
      cleanText = optionText.substring(prefixMatch.end);
    }

    Color borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;
    Color backgroundColor =
        isDark ? const Color(0xFF16181F) : const Color(0xFFF9FAFD);
    Color circleBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    Color circleFg =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    if (isSubmitted) {
      if (isCorrect) {
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.12);
        circleBg = AppColors.success;
        circleFg = Colors.white;
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.danger;
        backgroundColor = AppColors.danger.withValues(alpha: 0.12);
        circleBg = AppColors.danger;
        circleFg = Colors.white;
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      backgroundColor = AppColors.primary.withValues(alpha: 0.08);
      circleBg = AppColors.primary;
      circleFg = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSubmitted ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: isSelected || (isSubmitted && isCorrect) ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Option letter circle (A, B, C, D)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleBg,
                  ),
                  child: isSubmitted && isCorrect
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : isSubmitted && isSelected && !isCorrect
                          ? const Icon(Icons.close_rounded, color: Colors.white, size: 18)
                          : Text(
                              optionLetter,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: circleFg,
                              ),
                            ),
                ),
                const SizedBox(width: 14),

                // Option text definition
                Expanded(
                  child: Text(
                    cleanText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
