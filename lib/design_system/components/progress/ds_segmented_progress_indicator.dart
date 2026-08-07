import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';

/// A reusable segmented progress indicator component with optional auto-stepping timer.
class DSSegmentedProgressIndicator extends StatefulWidget {
  final int totalSegments;
  final int? activeSegments;
  final int initialActiveSegments;
  final bool autoStep;
  final Duration autoStepInterval;
  final ValueChanged<int>? onStepChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final double gap;
  final EdgeInsetsGeometry padding;

  const DSSegmentedProgressIndicator({
    super.key,
    this.totalSegments = 3,
    this.activeSegments,
    this.initialActiveSegments = 2,
    this.autoStep = true,
    this.autoStepInterval = const Duration(seconds: 3),
    this.onStepChanged,
    this.activeColor,
    this.inactiveColor,
    this.height = 4.5,
    this.gap = 10.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
  });

  @override
  State<DSSegmentedProgressIndicator> createState() => _DSSegmentedProgressIndicatorState();
}

class _DSSegmentedProgressIndicatorState extends State<DSSegmentedProgressIndicator> {
  Timer? _timer;
  late int _currentActiveCount;

  @override
  void initState() {
    super.initState();
    _currentActiveCount = widget.activeSegments ?? widget.initialActiveSegments;
    if (widget.autoStep && widget.activeSegments == null) {
      _startAutoStepTimer();
    }
  }

  @override
  void didUpdateWidget(covariant DSSegmentedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSegments != null && widget.activeSegments != oldWidget.activeSegments) {
      _currentActiveCount = widget.activeSegments!;
    }
    if (widget.autoStep != oldWidget.autoStep || widget.autoStepInterval != oldWidget.autoStepInterval) {
      _timer?.cancel();
      if (widget.autoStep && widget.activeSegments == null) {
        _startAutoStepTimer();
      }
    }
  }

  void _startAutoStepTimer() {
    _timer = Timer.periodic(widget.autoStepInterval, (_) {
      if (!mounted) return;
      setState(() {
        _currentActiveCount = (_currentActiveCount % widget.totalSegments) + 1;
      });
      widget.onStepChanged?.call(_currentActiveCount);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveActiveColor = widget.activeColor ?? AppColors.accentGreen;
    final effectiveInactiveColor =
        widget.inactiveColor ?? (isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB));

    final effectiveCount = widget.activeSegments ?? _currentActiveCount;

    return Padding(
      padding: widget.padding,
      child: Row(
        children: List.generate(widget.totalSegments, (index) {
          final isActive = index < effectiveCount;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentActiveCount = index + 1;
                });
                widget.onStepChanged?.call(_currentActiveCount);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: AppAnimations.normal,
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(right: index == widget.totalSegments - 1 ? 0 : widget.gap),
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: isActive ? effectiveActiveColor : effectiveInactiveColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: effectiveActiveColor.withValues(alpha: 0.4),
                              blurRadius: 6.0,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
