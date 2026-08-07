import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum DSButtonVariant { primary, secondary, outline, ghost, danger, socialGoogle, socialApple, socialGuest }

enum DSButtonSize { sm, md, lg }

class DSButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final bool isLoading;
  final bool disabled;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final bool fullWidth;
  final bool isPill;
  final Color? customBackgroundColor;
  final Color? customTextColor;
  final Color? customBorderColor;
  final double? borderRadius;

  const DSButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.size = DSButtonSize.md,
    this.isLoading = false,
    this.disabled = false,
    this.leftIcon,
    this.rightIcon,
    this.fullWidth = false,
    this.isPill = false,
    this.customBackgroundColor,
    this.customTextColor,
    this.customBorderColor,
    this.borderRadius,
  });

  @override
  State<DSButton> createState() => _DSButtonState();
}

class _DSButtonState extends State<DSButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _effectiveDisabled => widget.disabled || widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Size dimensions
    final double height;
    final EdgeInsets padding;
    final TextStyle textStyle;
    final double iconSize;

    switch (widget.size) {
      case DSButtonSize.sm:
        height = 36.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md);
        textStyle = AppTypography.button.copyWith(fontSize: AppTypography.fontSm);
        iconSize = 16.0;
        break;
      case DSButtonSize.md:
        height = 44.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
        textStyle = AppTypography.button.copyWith(fontSize: AppTypography.fontSm);
        iconSize = 18.0;
        break;
      case DSButtonSize.lg:
        height = 52.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
        textStyle = AppTypography.button.copyWith(fontSize: AppTypography.fontMd);
        iconSize = 20.0;
        break;
    }

    // Colors according to variant & state
    Color backgroundColor;
    Color textColor;
    Color borderColor = Colors.transparent;
    List<BoxShadow> shadows = [];

    if (_effectiveDisabled) {
      backgroundColor = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
      textColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    } else {
      switch (widget.variant) {
        case DSButtonVariant.primary:
          backgroundColor = _isHovered ? AppColors.primaryHover : AppColors.primary;
          textColor = Colors.white;
          if (_isHovered) {
            shadows = AppShadows.glow(AppColors.primary, blurRadius: 16);
          }
          break;

        case DSButtonVariant.secondary:
          backgroundColor = _isHovered ? AppColors.secondary : AppColors.secondaryLight;
          textColor = _isHovered ? Colors.white : AppColors.secondary;
          break;

        case DSButtonVariant.outline:
          backgroundColor = _isHovered
              ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
              : Colors.transparent;
          borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
          textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
          break;

        case DSButtonVariant.ghost:
          backgroundColor = _isHovered
              ? (isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5) : AppColors.lightSurfaceVariant)
              : Colors.transparent;
          textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
          break;

        case DSButtonVariant.danger:
          backgroundColor = _isHovered ? AppColors.dangerHover : AppColors.danger;
          textColor = Colors.white;
          if (_isHovered) {
            shadows = AppShadows.glow(AppColors.danger, blurRadius: 14);
          }
          break;

        case DSButtonVariant.socialGoogle:
          backgroundColor = _isHovered
              ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.socialGoogleBg);
          textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
          break;

        case DSButtonVariant.socialApple:
          backgroundColor = isDark ? Colors.white : AppColors.socialAppleBg;
          textColor = isDark ? Colors.black : Colors.white;
          break;

        case DSButtonVariant.socialGuest:
          backgroundColor = _isHovered
              ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.socialGuestBg);
          textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
          break;
      }

      if (widget.customBackgroundColor != null) {
        backgroundColor = widget.customBackgroundColor!;
      }
      if (widget.customTextColor != null) {
        textColor = widget.customTextColor!;
      }
      if (widget.customBorderColor != null) {
        borderColor = widget.customBorderColor!;
      }
    }

    final double effectiveRadius = widget.borderRadius ??
        (widget.isPill ? height / 2 : AppSpacing.radiusMd);

    final scale = _isPressed ? 0.96 : (_isHovered && !_effectiveDisabled ? 1.02 : 1.0);

    Widget child = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          AppSpacing.gapHorizontalSm,
        ] else ...[
          if (widget.leftIcon != null) ...[
            IconTheme(
              data: IconThemeData(size: iconSize, color: textColor),
              child: widget.leftIcon!,
            ),
            AppSpacing.gapHorizontalSm,
          ],
        ],
        AnimatedDefaultTextStyle(
          duration: AppAnimations.fast,
          style: textStyle.copyWith(color: textColor),
          child: Text(widget.text),
        ),
        if (widget.rightIcon != null && !widget.isLoading) ...[
          AppSpacing.gapHorizontalSm,
          IconTheme(
            data: IconThemeData(size: iconSize, color: textColor),
            child: widget.rightIcon!,
          ),
        ],
      ],
    );

    return MouseRegion(
      cursor: _effectiveDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) {
        if (!_effectiveDisabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!_effectiveDisabled) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (!_effectiveDisabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (!_effectiveDisabled) setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (!_effectiveDisabled) setState(() => _isPressed = false);
        },
        onTap: _effectiveDisabled ? null : widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: AppAnimations.fast,
          curve: AppAnimations.curveFast,
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            curve: AppAnimations.curveFast,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(effectiveRadius),
              border: borderColor != Colors.transparent ? Border.all(color: borderColor, width: 1.5) : null,
              boxShadow: shadows,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
