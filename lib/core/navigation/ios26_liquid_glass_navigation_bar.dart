import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ios26_navigation_item.dart';
import 'ios26_navigation_platform.dart';

/// Flutter controller and widget replicating Apple's official iOS 26 Liquid Glass
/// tab bar design (documented in Apple's "Adopting Liquid Glass" & HIG Tab Bars).
///
/// Features:
/// 1. Floating main Liquid Glass pill
/// 2. Detached circular trailing search orb when an item has [IOS26NavigationItem.isSearch]
/// 3. Animated glossy elevated capsule indicator around the active tab
/// 4. Native iOS 26 `UIGlassEffect(style: .regular)` on real iOS devices
/// 5. Native SF Symbols & Dynamic Type typography
/// 6. Minimize-on-scroll integration with Flutter [ScrollController]
class IOS26LiquidGlassNavigationBar extends StatefulWidget {
  /// Tab items displayed in the bar.
  final List<IOS26NavigationItem> items;

  /// Currently selected tab index.
  final int selectedIndex;

  /// Called when the user taps a tab.
  final ValueChanged<int> onSelected;

  /// Optional scroll controller for the active screen (for minimize-on-scroll).
  final ScrollController? scrollController;

  /// Optional identifier of the currently active tab.
  final String? activeTabId;

  /// Optional callback invoked when the native tab bar geometry changes.
  final ValueChanged<TabBarGeometry>? onGeometryChanged;

  /// Height of the floating navigation bar. Defaults to 62.0 pt.
  final double height;

  /// External margin around the floating pill.
  final EdgeInsetsGeometry margin;

  /// Accent tint color for the active tab (defaults to Apple Podcasts purple/indigo).
  final Color activeColor;

  const IOS26LiquidGlassNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.scrollController,
    this.activeTabId,
    this.onGeometryChanged,
    this.height = 70.0,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 12),
    this.activeColor = const Color(0xFFA855F7), // Apple Liquid Glass purple accent
  });

  @override
  State<IOS26LiquidGlassNavigationBar> createState() =>
      _IOS26LiquidGlassNavigationBarState();
}

class _IOS26LiquidGlassNavigationBarState
    extends State<IOS26LiquidGlassNavigationBar> {
  MethodChannel? _channel;

  bool _isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isIOS(context)) {
      IOS26NavigationPlatform.instance.initialise();
      IOS26NavigationPlatform.instance.onTabSelected = widget.onSelected;
      IOS26NavigationPlatform.instance.onTabBarFrameChanged = widget.onGeometryChanged;
      IOS26NavigationPlatform.instance.configureItems(widget.items);
      IOS26NavigationPlatform.instance.setSelectedIndex(widget.selectedIndex);
    }
  }

  @override
  void didUpdateWidget(covariant IOS26LiquidGlassNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isIOS(context)) return;

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _channel?.invokeMethod('setSelectedIndex', {'index': widget.selectedIndex});
      IOS26NavigationPlatform.instance.setSelectedIndex(widget.selectedIndex);
    }

    if (!_itemsEqual(oldWidget.items, widget.items)) {
      final payload = widget.items.map((e) => e.toMap()).toList();
      _channel?.invokeMethod('configureItems', {'items': payload});
      IOS26NavigationPlatform.instance.configureItems(widget.items);
    }

    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    final channelName = 'uz.cordialsoft.easyenglish/ios26_liquid_glass_nav_$id';
    final channel = MethodChannel(channelName);
    _channel = channel;

    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onTabSelected':
          final args = call.arguments as Map?;
          final index = args?['index'] as int? ?? 0;
          widget.onSelected(index);
          break;
        case 'onTabBarFrameChanged':
          final args = call.arguments as Map?;
          if (args != null) {
            final geo = TabBarGeometry.fromMap(args.cast<String, dynamic>());
            widget.onGeometryChanged?.call(geo);
            IOS26NavigationPlatform.instance.onTabBarFrameChanged?.call(geo);
          }
          break;
      }
    });

    IOS26NavigationPlatform.instance.onTabSelected = widget.onSelected;
    IOS26NavigationPlatform.instance.onTabBarFrameChanged = widget.onGeometryChanged;
  }

  void _onScroll() {
    final sc = widget.scrollController;
    if (sc == null || !sc.hasClients) return;

    final position = sc.position;
    final payload = {
      'tabId': widget.activeTabId,
      'offset': position.pixels,
      'contentHeight': position.maxScrollExtent + position.viewportDimension,
      'viewportHeight': position.viewportDimension,
    };

    _channel?.invokeMethod('updateScrollOffset', payload);
    IOS26NavigationPlatform.instance.updateScrollOffset(
      tabId: widget.activeTabId,
      offset: position.pixels,
      contentHeight: position.maxScrollExtent + position.viewportDimension,
      viewportHeight: position.viewportDimension,
    );
  }

  bool _itemsEqual(List<IOS26NavigationItem> a, List<IOS26NavigationItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].sfSymbolName != b[i].sfSymbolName ||
          a[i].selectedSfSymbolName != b[i].selectedSfSymbolName ||
          a[i].label != b[i].label ||
          a[i].isSearch != b[i].isSearch) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = _isIOS(context);
    final isRunningInTest =
        !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

    // ── Native iOS: Render UiKitView ──
    if (isIOS && !isRunningInTest && !kIsWeb) {
      final itemsPayload = widget.items.map((e) => e.toMap()).toList();

      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Padding(
            padding: widget.margin,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SizedBox(
                height: widget.height,
                child: UiKitView(
                  viewType: 'uz.cordialsoft.easyenglish/ios26_liquid_glass_nav',
                  creationParams: {
                    'currentIndex': widget.selectedIndex,
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

    // ── High-Fidelity Apple Reference Reproduction (Tests / Web / Fallback) ──
    final searchIdx = widget.items.indexWhere(
        (e) => e.isSearch || e.label.toLowerCase() == 'search');
    final hasDetachedSearch = searchIdx != -1;
    final mainItems = hasDetachedSearch
        ? widget.items.where((e) => !e.isSearch && e.label.toLowerCase() != 'search').toList()
        : widget.items;

    final pillRadius = widget.height / 2;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: widget.margin,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SizedBox(
              height: widget.height,
              child: Row(
                children: [
                  // Main Liquid Glass Pill
                  Expanded(
                    child: _buildMainGlassPill(context, mainItems, pillRadius),
                  ),

                  // Detached Circular Search Orb (if search tab exists)
                  if (hasDetachedSearch) ...[
                    const SizedBox(width: 10),
                    _buildDetachedSearchCircle(
                        context, searchIdx, pillRadius),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainGlassPill(
      BuildContext context, List<IOS26NavigationItem> displayItems, double radius) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x732C2C2E), // Apple Dark Liquid Glass material
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 0.5,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabCount = displayItems.length;
                if (tabCount == 0) return const SizedBox.shrink();

                const horizontalPadding = 16.0;
                final tabWidth =
                    (constraints.maxWidth - (horizontalPadding * 2)) / tabCount;
                final selectedIndexInMain = widget.selectedIndex < tabCount
                    ? widget.selectedIndex
                    : 0;

                return Stack(
                  children: [
                    // Elevated Glossy Active Capsule (Squircle Pod)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      left: horizontalPadding +
                          (selectedIndexInMain * tabWidth) +
                          2.0,
                      top: 6.0,
                      width: tabWidth - 4.0,
                      height: constraints.maxHeight - 12.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0x3DFFFFFF),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.activeColor.withValues(alpha: 0.18),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tab Buttons Row
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: horizontalPadding),
                        child: Row(
                          children: List.generate(displayItems.length, (index) {
                            final item = displayItems[index];
                            final isSelected = index == widget.selectedIndex;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  widget.onSelected(index);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _mapSfSymbolToIcon(
                                        isSelected
                                            ? (item.selectedSfSymbolName ?? item.sfSymbolName)
                                            : item.sfSymbolName,
                                        isSelected,
                                      ),
                                      color: isSelected
                                          ? widget.activeColor
                                          : const Color(0xEEFFFFFF),
                                      size: 21,
                                    ),
                                    const SizedBox(height: 3.5),
                                    Text(
                                      item.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected
                                            ? widget.activeColor
                                            : const Color(0xEEFFFFFF),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        fontSize: 11,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetachedSearchCircle(
      BuildContext context, int searchIdx, double radius) {
    final isSelected = widget.selectedIndex == searchIdx;

    return Container(
      width: widget.height,
      height: widget.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? widget.activeColor.withValues(alpha: 0.25)
                  : const Color(0x732C2C2E),
              border: Border.all(
                color: isSelected
                    ? widget.activeColor.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.28),
                width: 0.75,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onSelected(searchIdx);
                },
                customBorder: const CircleBorder(),
                child: Center(
                  child: Icon(
                    Icons.search_rounded,
                    color: isSelected ? widget.activeColor : Colors.white,
                    size: 23,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _mapSfSymbolToIcon(String sfSymbol, bool isSelected) {
    switch (sfSymbol) {
      case 'house':
      case 'house.fill':
        return isSelected ? Icons.home_rounded : Icons.home_outlined;
      case 'doc.text':
      case 'doc.text.fill':
        return isSelected ? Icons.assignment_rounded : Icons.assignment_outlined;
      case 'quote.bubble':
      case 'quote.bubble.fill':
        return isSelected ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded;
      case 'person':
      case 'person.fill':
        return isSelected ? Icons.person_rounded : Icons.person_outline_rounded;
      case 'square.grid.2x2':
      case 'square.grid.2x2.fill':
        return Icons.grid_view_rounded;
      case 'books.vertical':
      case 'books.vertical.fill':
        return Icons.library_books_rounded;
      default:
        return Icons.circle;
    }
  }
}

/// Provides the current native tab-bar bottom inset so that scrollable
/// content can add appropriate padding.
class IOS26ScrollableContent extends StatefulWidget {
  final Widget Function(BuildContext context, double bottomInset) builder;
  final double fallbackInset;

  const IOS26ScrollableContent({
    super.key,
    required this.builder,
    this.fallbackInset = 90,
  });

  @override
  State<IOS26ScrollableContent> createState() => _IOS26ScrollableContentState();
}

class _IOS26ScrollableContentState extends State<IOS26ScrollableContent> {
  TabBarGeometry? _geometry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (isIOS) {
      IOS26NavigationPlatform.instance.onTabBarFrameChanged = (geo) {
        if (mounted) setState(() => _geometry = geo);
      };
      IOS26NavigationPlatform.instance.getTabBarFrame().then((geo) {
        if (mounted && geo != null) setState(() => _geometry = geo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final inset = isIOS
        ? (_geometry?.height ?? widget.fallbackInset)
        : 0.0;
    return widget.builder(context, inset);
  }
}
