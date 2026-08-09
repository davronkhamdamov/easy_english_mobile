import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

enum DSCardVariant { elevated, outlined, glass }

class DSCard extends StatefulWidget {
  final Widget? child;
  final Widget? header;
  final Widget? body;
  final Widget? footer;
  final DSCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool interactive;

  const DSCard({
    super.key,
    this.child,
    this.header,
    this.body,
    this.footer,
    this.variant = DSCardVariant.elevated,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.interactive = true,
  });

  @override
  State<DSCard> createState() => _DSCardState();
}

class _DSCardState extends State<DSCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isClickable => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Border? border;
    List<BoxShadow> shadows = [];

    final activeHover = _isClickable && widget.interactive && _isHovered;
    final activePress = _isClickable && widget.interactive && _isPressed;

    switch (widget.variant) {
      case DSCardVariant.elevated:
        backgroundColor = isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface;
        shadows = activeHover ? AppShadows.lg(isDark) : AppShadows.sm(isDark);
        if (activeHover) {
          shadows = [
            ...shadows,
            ...AppShadows.glow(AppColors.primary, blurRadius: 16, spread: -4),
          ];
        }
        break;

      case DSCardVariant.outlined:
        backgroundColor = isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface;
        border = Border.all(
          color: activeHover
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: activeHover ? 1.5 : 1.0,
        );
        if (activeHover) {
          shadows = AppShadows.sm(isDark);
        }
        break;

      case DSCardVariant.glass:
        backgroundColor = isDark
            ? AppColors.darkGlassBackground
            : AppColors.lightGlassBackground;
        border = Border.all(
          color: activeHover
              ? AppColors.primary.withValues(alpha: 0.6)
              : (isDark
                    ? AppColors.darkGlassBorder
                    : AppColors.lightGlassBorder),
          width: 1.2,
        );
        shadows = activeHover ? AppShadows.md(isDark) : AppShadows.sm(isDark);
        break;
    }

    final double scale = activePress ? 0.98 : (activeHover ? 1.015 : 1.0);

    Widget content;
    if (widget.child != null) {
      content = widget.child!;
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.header != null) widget.header!,
          if (widget.header != null &&
              (widget.body != null || widget.footer != null))
            const SizedBox(height: AppSpacing.md),
          if (widget.body != null) widget.body!,
          if (widget.body != null && widget.footer != null)
            const SizedBox(height: AppSpacing.md),
          if (widget.footer != null) widget.footer!,
        ],
      );
    }

    Widget cardBody = AnimatedContainer(
      duration: AppAnimations.normal,
      curve: AppAnimations.curveFast,
      width: widget.width,
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: border,
        boxShadow: shadows,
      ),
      child: content,
    );

    // If glassmorphism variant, apply BackdropFilter blur
    if (widget.variant == DSCardVariant.glass) {
      cardBody = ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: cardBody,
        ),
      );
    }

    if (!_isClickable) {
      return Container(margin: widget.margin, child: cardBody);
    }

    return Container(
      margin: widget.margin,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: scale,
            duration: AppAnimations.fast,
            curve: AppAnimations.curveFast,
            child: cardBody,
          ),
        ),
      ),
    );
  }
}
