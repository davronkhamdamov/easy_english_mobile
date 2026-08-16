import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigation item model for [FloatingPillNavBar].
class FloatingNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// A floating, pill-shaped bottom navigation bar with vertical iOS-style layout
/// (icon on top, text label at the bottom).
class FloatingPillNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem> items;
  final Color? backgroundColor;
  final Color? activeBackgroundColor;
  final Color? activeForegroundColor;
  final Color? inactiveForegroundColor;
  final double height;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const FloatingPillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeBackgroundColor,
    this.activeForegroundColor,
    this.inactiveForegroundColor,
    this.height = 70.0,
    this.margin = const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
    this.padding = const EdgeInsets.symmetric(horizontal: 9.0, vertical: 2.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navBgColor =
        backgroundColor ??
        (isDark ? const Color(0xFF1E293B) : const Color(0xFFEDEDF0));

    final activeBg =
        activeBackgroundColor ??
        (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A));

    final activeFg =
        activeForegroundColor ??
        (isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF));

    final inactiveFg =
        inactiveForegroundColor ??
        (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569));

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 360),
          child: Container(
            height: height,
            margin: margin,
            padding: padding,
            decoration: BoxDecoration(
              color: navBgColor,
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(items.length, (index) {
                final isSelected = index == currentIndex;
                final item = items[index];

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(index);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? activeBg : Colors.transparent,
                        borderRadius: BorderRadius.circular((height - 8) / 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? (item.activeIcon ?? item.icon)
                                : item.icon,
                            color: isSelected ? activeFg : inactiveFg,
                            size: 25,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? activeFg : inactiveFg,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 12.5,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
