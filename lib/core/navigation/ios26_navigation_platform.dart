import 'dart:async';
import 'package:flutter/services.dart';
import 'ios26_navigation_item.dart';

/// Platform channel bridge to the native iOS 26 Liquid Glass tab bar.
///
/// This is a singleton — only one native tab bar controller exists at the
/// iOS window level.
///
/// ## Flutter → Swift
/// - [configureItems] / [setSelectedIndex] / [updateScrollOffset]
/// - [setMinimizeBehavior] / [setBottomAccessory] / [setTabBarVisible]
/// - [getTabBarFrame]
///
/// ## Swift → Flutter
/// - `onTabSelected`       → [onTabSelected] callback
/// - `onTabBarFrameChanged` → [onTabBarFrameChanged] callback
class IOS26NavigationPlatform {
  IOS26NavigationPlatform._();

  static final IOS26NavigationPlatform instance = IOS26NavigationPlatform._();

  static const _channelName = 'uz.cordialsoft.easyenglish/liquid_glass_nav';
  final MethodChannel _channel = const MethodChannel(_channelName);

  /// Callback invoked when the user taps a tab natively.
  ValueChanged<int>? onTabSelected;

  /// Callback invoked when the native tab bar geometry changes
  /// (e.g. during minimisation/restore).
  ValueChanged<TabBarGeometry>? onTabBarFrameChanged;

  /// Whether the platform bridge has been initialised.
  bool _initialised = false;

  /// Throttle timer for scroll offset updates (limits to ~30 Hz).
  Timer? _scrollThrottle;
  _ScrollState? _pendingScroll;

  // ---------------------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------------------

  /// Initialises the method-call handler. Must be called once, typically from
  /// `initState` of the root navigation widget.
  void initialise() {
    if (_initialised) return;
    _initialised = true;

    _channel.setMethodCallHandler(_handleNativeCall);
  }

  /// Disposes the bridge (removes the method-call handler).
  void dispose() {
    _channel.setMethodCallHandler(null);
    _scrollThrottle?.cancel();
    _initialised = false;
  }

  // ---------------------------------------------------------------------------
  // Flutter → Swift
  // ---------------------------------------------------------------------------

  /// Sends the full list of navigation items to the native tab bar.
  Future<void> configureItems(List<IOS26NavigationItem> items) {
    return _channel.invokeMethod('configureItems', {
      'items': items.map((e) => e.toMap()).toList(),
    });
  }

  /// Programmatically selects the tab at [index].
  Future<void> setSelectedIndex(int index) {
    return _channel.invokeMethod('setSelectedIndex', {'index': index});
  }

  /// Reports the current Flutter scroll offset to the native tab bar so it
  /// can perform its minimise-on-scroll behaviour.
  ///
  /// Calls are coalesced to ~30 Hz to avoid excessive platform-channel traffic.
  void updateScrollOffset({
    String? tabId,
    required double offset,
    required double contentHeight,
    required double viewportHeight,
  }) {
    _pendingScroll = _ScrollState(tabId, offset, contentHeight, viewportHeight);

    _scrollThrottle ??=
        Timer(const Duration(milliseconds: 33), _flushScroll);
  }

  void _flushScroll() {
    _scrollThrottle = null;
    final s = _pendingScroll;
    if (s == null) return;
    _pendingScroll = null;

    _channel.invokeMethod('updateScrollOffset', {
      'tabId': s.tabId,
      'offset': s.offset,
      'contentHeight': s.contentHeight,
      'viewportHeight': s.viewportHeight,
    });
  }

  /// Sets the tab-bar minimise behaviour (`automatic`, `onScrollDown`,
  /// `onScrollUp`, `never`).
  Future<void> setMinimizeBehavior(String behavior) {
    return _channel.invokeMethod('setMinimizeBehavior', {
      'behavior': behavior,
    });
  }

  /// Sets or clears the native bottom accessory (e.g. a mini-player).
  /// Pass `null` to remove.
  Future<void> setBottomAccessory({String? label}) {
    if (label == null) {
      return _channel.invokeMethod('setBottomAccessory', null);
    }
    return _channel.invokeMethod('setBottomAccessory', {'label': label});
  }

  /// Shows or hides the native tab bar.
  Future<void> setTabBarVisible(bool visible, {bool animated = true}) {
    return _channel.invokeMethod('setTabBarVisible', {
      'visible': visible,
      'animated': animated,
    });
  }

  /// Returns the current tab bar frame and bottom safe area.
  Future<TabBarGeometry?> getTabBarFrame() async {
    final result = await _channel.invokeMethod<Map>('getTabBarFrame');
    if (result == null) return null;
    return TabBarGeometry.fromMap(result.cast<String, dynamic>());
  }

  // ---------------------------------------------------------------------------
  // Swift → Flutter
  // ---------------------------------------------------------------------------

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onTabSelected':
        final args = call.arguments as Map?;
        final index = args?['index'] as int? ?? 0;
        onTabSelected?.call(index);

      case 'onTabBarFrameChanged':
        final args = call.arguments as Map?;
        if (args != null) {
          final geo = TabBarGeometry.fromMap(args.cast<String, dynamic>());
          onTabBarFrameChanged?.call(geo);
        }
    }
  }
}

// ---------------------------------------------------------------------------
// Supporting Models
// ---------------------------------------------------------------------------

/// Geometry of the native tab bar reported to Flutter.
class TabBarGeometry {
  final double x;
  final double y;
  final double width;
  final double height;
  final double bottomSafeArea;

  const TabBarGeometry({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.bottomSafeArea,
  });

  /// Total bottom inset Flutter should apply to scrollable content
  /// so the last item can be scrolled above the tab bar.
  double get totalBottomInset => height + bottomSafeArea;

  factory TabBarGeometry.fromMap(Map<String, dynamic> map) {
    return TabBarGeometry(
      x: (map['x'] as num?)?.toDouble() ?? 0,
      y: (map['y'] as num?)?.toDouble() ?? 0,
      width: (map['width'] as num?)?.toDouble() ?? 0,
      height: (map['height'] as num?)?.toDouble() ?? 0,
      bottomSafeArea: (map['bottomSafeArea'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  String toString() =>
      'TabBarGeometry(x: $x, y: $y, w: $width, h: $height, safe: $bottomSafeArea)';
}

class _ScrollState {
  final String? tabId;
  final double offset;
  final double contentHeight;
  final double viewportHeight;
  const _ScrollState(this.tabId, this.offset, this.contentHeight, this.viewportHeight);
}
