import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum DSInputType { text, password, email, search }

class DSInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final DSInputType type;
  final bool disabled;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const DSInput({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.controller,
    this.type = DSInputType.text,
    this.disabled = false,
    this.leftIcon,
    this.rightIcon,
    this.onChanged,
    this.onClear,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<DSInput> createState() => _DSInputState();
}

class _DSInputState extends State<DSInput> {
  late TextEditingController _effectiveController;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _effectiveController.addListener(_onTextChange);
    _obscureText = widget.type == DSInputType.password;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _effectiveController.removeListener(_onTextChange);
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case DSInputType.email:
        return TextInputType.emailAddress;
      case DSInputType.search:
      case DSInputType.text:
        return TextInputType.text;
      case DSInputType.password:
        return TextInputType.visiblePassword;
    }
  }

  Widget? _buildLeftIcon(bool isDark) {
    if (widget.leftIcon != null) {
      return widget.leftIcon;
    }
    switch (widget.type) {
      case DSInputType.search:
        return Icon(
          Icons.search_rounded,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        );
      case DSInputType.email:
        return Icon(
          Icons.email_outlined,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        );
      case DSInputType.password:
        return Icon(
          Icons.lock_outline_rounded,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        );
      default:
        return null;
    }
  }

  Widget? _buildRightIcon(bool isDark) {
    if (widget.type == DSInputType.password) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        child: AnimatedSwitcher(
          duration: AppAnimations.fast,
          child: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            key: ValueKey<bool>(_obscureText),
            size: 20,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      );
    }

    if (widget.type == DSInputType.search || _showClearButton) {
      if (_showClearButton) {
        return GestureDetector(
          onTap: () {
            _effectiveController.clear();
            widget.onClear?.call();
            widget.onChanged?.call('');
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        );
      }
    }

    return widget.rightIcon;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    // Colors
    final Color fillColor = widget.disabled
        ? (isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5) : AppColors.lightSurfaceVariant.withValues(alpha: 0.5))
        : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant);

    Color borderColor;
    List<BoxShadow> shadows = [];

    if (hasError) {
      borderColor = AppColors.danger;
      if (_isFocused) {
        shadows = AppShadows.glow(AppColors.danger, blurRadius: 12);
      }
    } else if (_isFocused) {
      borderColor = AppColors.primary;
      shadows = AppShadows.glow(AppColors.primary, blurRadius: 12);
    } else {
      borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    }

    final leftIconWidget = _buildLeftIcon(isDark);
    final rightIconWidget = _buildRightIcon(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.label.copyWith(
              color: widget.disabled
                  ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
          AppSpacing.gapVerticalXs,
        ],
        AnimatedContainer(
          duration: AppAnimations.normal,
          curve: AppAnimations.curveFast,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: borderColor,
              width: _isFocused || hasError ? 2.0 : 1.0,
            ),
            boxShadow: shadows,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
            child: Row(
              children: [
                if (leftIconWidget != null) ...[
                  leftIconWidget,
                  AppSpacing.gapHorizontalSm,
                ],
                Expanded(
                  child: TextField(
                    controller: _effectiveController,
                    focusNode: _focusNode,
                    enabled: !widget.disabled,
                    obscureText: widget.type == DSInputType.password && _obscureText,
                    keyboardType: _getKeyboardType(),
                    textInputAction: widget.textInputAction,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: AppTypography.bodyMd.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: AppTypography.bodyMd.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                if (rightIconWidget != null) ...[
                  AppSpacing.gapHorizontalSm,
                  rightIconWidget,
                ],
              ],
            ),
          ),
        ),
        // Helper or Error text with animated crossfade
        AnimatedCrossFade(
          duration: AppAnimations.fast,
          crossFadeState: hasError
              ? CrossFadeState.showSecond
              : (widget.helperText != null ? CrossFadeState.showFirst : CrossFadeState.showFirst),
          firstChild: widget.helperText != null
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.xs),
                  child: Text(
                    widget.helperText!,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          secondChild: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.danger),
                      AppSpacing.gapHorizontalXs,
                      Expanded(
                        child: Text(
                          widget.errorText!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
