import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigation item model for [FloatingPillNavBar] / [LiquidNavBar].
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

/// Convenience aliases for [FloatingNavItem] and [FloatingPillNavBar].
typedef LiquidNavItem = FloatingNavItem;
typedef LiquidNavBar = FloatingPillNavBar;

/// An iOS Liquid Glass floating navigation bar with organic glassmorphism
/// and sliding liquid cyan/blue droplet highlight for the active tab, styled
/// identically to the Apple iOS App Store Liquid Navigation concept.
class FloatingPillNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem> items;
  final Widget? trailingAction;
  final Color? backgroundColor;
  final Color? activeGlowColor;
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
    this.trailingAction,
    this.backgroundColor,
    this.activeGlowColor,
    this.activeForegroundColor,
    this.inactiveForegroundColor,
    this.height = 66.0,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 8),
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isRunningInTest =
        !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

    if (isIOS && !isRunningInTest && !kIsWeb) {
      return _NativeIosLiquidNavBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        height: height,
        margin: margin,
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Liquid Glass Background: Warm translucent frosted glass (light) or obsidian glass (dark)
    final navBgColor = backgroundColor ??
        (isDark
            ? const Color(0xD91E1E24)
            : const Color(0xDCFBF9F5));

    // Specular Highlight Border
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.72);

    // Cyan / Sky-Blue Liquid Droplet Glow
    final cyanGlow = activeGlowColor ?? const Color(0xFF00A3FF);

    // Active & Inactive text / icon colors
    final activeFg = activeForegroundColor ?? Colors.white;
    final inactiveFg = inactiveForegroundColor ??
        (isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E));

    // Ambient floating drop shadows
    final pillShadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.14),
        blurRadius: 26,
        spreadRadius: 0,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
        blurRadius: 6,
        spreadRadius: -1,
        offset: const Offset(0, 2),
      ),
    ];

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: margin,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Main Liquid Glass Pill containing navigation tabs
                Expanded(
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: pillShadows,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(height / 2),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                        child: Container(
                          padding: padding,
                          decoration: BoxDecoration(
                            color: navBgColor,
                            borderRadius: BorderRadius.circular(height / 2),
                            border: Border.all(
                              color: borderColor,
                              width: 1.0,
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final totalWidth = constraints.maxWidth;
                              final tabCount = items.isEmpty ? 1 : items.length;
                              final tabWidth = totalWidth / tabCount;
                              final indicatorHeight = height - 12.0;
                              final indicatorWidth = tabWidth - 6.0;
                              final rawLeft = (currentIndex * tabWidth) + 3.0;
                              final maxLeft = (totalWidth - indicatorWidth).clamp(0.0, double.infinity);
                              final leftOffset = rawLeft.clamp(0.0, maxLeft);

                              return Stack(
                                children: [
                                  // Animated Liquid Droplet Glow Highlight (slides smoothly under active tab)
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeOutCubic,
                                    left: leftOffset,
                                    top: (constraints.maxHeight - indicatorHeight) / 2,
                                    width: indicatorWidth,
                                    height: indicatorHeight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(indicatorHeight / 2),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            const Color(0xB838BDF8),
                                            cyanGlow.withValues(alpha: 0.60),
                                            activeFg.withValues(alpha: 0.40),
                                          ],
                                          stops: const [0.0, 0.55, 1.0],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.55),
                                          width: 0.9,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: cyanGlow.withValues(alpha: 0.60),
                                            blurRadius: 18,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
                                            blurRadius: 8,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(indicatorHeight / 2),
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Container(
                                            height: indicatorHeight * 0.46,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withValues(alpha: 0.45),
                                                  Colors.white.withValues(alpha: 0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Tab Items Row
                                  Row(
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
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isSelected
                                                    ? (item.activeIcon ?? item.icon)
                                                    : item.icon,
                                                color: isSelected ? activeFg : inactiveFg,
                                                size: 24,
                                              ),
                                              const SizedBox(height: 2.5),
                                              Text(
                                                item.label,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isSelected ? activeFg : inactiveFg,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w700
                                                      : FontWeight.w600,
                                                  fontSize: 11.5,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Optional generic trailing action
                if (trailingAction != null) ...[
                  const SizedBox(width: 10),
                  trailingAction!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Native iOS UIKit Liquid Navigation Bar view wrapper via UiKitView.
class _NativeIosLiquidNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem> items;
  final double height;
  final EdgeInsetsGeometry margin;

  const _NativeIosLiquidNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.height,
    required this.margin,
  });

  @override
  State<_NativeIosLiquidNavBar> createState() => _NativeIosLiquidNavBarState();
}

class _NativeIosLiquidNavBarState extends State<_NativeIosLiquidNavBar> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(covariant _NativeIosLiquidNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _channel?.invokeMethod('setCurrentIndex', {'index': widget.currentIndex});
    }
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('uz.cordialsoft.easyenglish/liquid_nav_bar_$id');
    _channel = channel;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'onTabSelected') {
        final args = call.arguments as Map?;
        final index = args?['index'] as int? ?? 0;
        widget.onTap(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsPayload = widget.items.map((item) {
      String sfIcon = 'circle';
      String activeSfIcon = 'circle.fill';
      if (item.label == 'Home') {
        sfIcon = 'house';
        activeSfIcon = 'house.fill';
      } else if (item.label == 'Practice') {
        sfIcon = 'doc.text';
        activeSfIcon = 'doc.text.fill';
      } else if (item.label == 'Text Lab') {
        sfIcon = 'quote.bubble';
        activeSfIcon = 'quote.bubble.fill';
      } else if (item.label == 'Profile') {
        sfIcon = 'person';
        activeSfIcon = 'person.fill';
      }
      return {
        'title': item.label,
        'iconName': sfIcon,
        'activeIconName': activeSfIcon,
      };
    }).toList();

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: widget.margin,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SizedBox(
              height: widget.height,
              child: UiKitView(
                viewType: 'uz.cordialsoft.easyenglish/liquid_nav_bar',
                creationParams: {
                  'currentIndex': widget.currentIndex,
                  'items': itemsPayload,
                },
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: _onPlatformViewCreated,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

