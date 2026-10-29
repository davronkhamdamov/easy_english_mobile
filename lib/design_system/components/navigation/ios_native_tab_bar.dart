import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart';

/// Navigation item model for [IosNativeTabBar].
class IosNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const IosNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// Native iOS Bottom Navigation Bar adhering strictly to Apple's Human Interface Guidelines (HIG).
class IosNativeTabBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IosNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double iconSize;

  const IosNativeTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.iconSize = 28.0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    final isDark = (CupertinoTheme.maybeBrightnessOf(context) ??
            Theme.of(context).brightness) ==
        Brightness.dark;

    final barBg = backgroundColor ??
        (isDark ? const Color(0xCC1D1D1F) : const Color(0xCCF9F9F9));

    final activeCl = activeColor ?? CupertinoColors.activeBlue;
    final inactiveCl = inactiveColor ?? const Color(0xFF8E8E93);

    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: (index) {
        HapticFeedback.selectionClick();
        onTap(index);
      },
      activeColor: activeCl,
      inactiveColor: inactiveCl,
      backgroundColor: barBg,
      iconSize: iconSize,
      border: Border(
        top: BorderSide(
          color: isDark
              ? const Color(0x33FFFFFF)
              : const Color(0x33000000),
          width: 0.0,
        ),
      ),
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          activeIcon: Icon(item.activeIcon ?? item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }
}
