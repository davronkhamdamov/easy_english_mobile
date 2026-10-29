import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/core/navigation/ios26_liquid_glass_navigation_bar.dart';
import 'package:easy_english/core/navigation/ios26_navigation_item.dart';
import 'package:easy_english/core/navigation/ios26_navigation_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IOS26NavigationItem Model Tests', () {
    test('serializes properties correctly to Map', () {
      const item = IOS26NavigationItem(
        id: 'home',
        sfSymbolName: 'house',
        selectedSfSymbolName: 'house.fill',
        label: 'Home',
        isSearch: false,
      );

      final map = item.toMap();
      expect(map['id'], 'home');
      expect(map['sfSymbolName'], 'house');
      expect(map['selectedSfSymbolName'], 'house.fill');
      expect(map['label'], 'Home');
      expect(map['isSearch'], false);
    });

    test('defaults selectedSfSymbolName to sfSymbolName when omitted', () {
      const item = IOS26NavigationItem(
        id: 'search',
        sfSymbolName: 'magnifyingglass',
        label: 'Search',
        isSearch: true,
      );

      final map = item.toMap();
      expect(map['id'], 'search');
      expect(map['sfSymbolName'], 'magnifyingglass');
      expect(map['selectedSfSymbolName'], 'magnifyingglass');
      expect(map['label'], 'Search');
      expect(map['isSearch'], true);
    });
  });

  group('TabBarGeometry Model Tests', () {
    test('parses from Map and calculates totalBottomInset', () {
      final geo = TabBarGeometry.fromMap({
        'x': 20.0,
        'y': 700.0,
        'width': 350.0,
        'height': 64.0,
        'bottomSafeArea': 34.0,
      });

      expect(geo.x, 20.0);
      expect(geo.y, 700.0);
      expect(geo.width, 350.0);
      expect(geo.height, 64.0);
      expect(geo.bottomSafeArea, 34.0);
      expect(geo.totalBottomInset, 98.0);
    });
  });

  group('IOS26NavigationPlatform Channel Tests', () {
    const channelName = 'uz.cordialsoft.easyenglish/liquid_glass_nav';
    final List<MethodCall> channelCalls = [];
    final platform = IOS26NavigationPlatform.instance;

    setUp(() {
      channelCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName),
              (MethodCall call) async {
        channelCalls.add(call);
        if (call.method == 'getTabBarFrame') {
          return {
            'x': 16.0,
            'y': 720.0,
            'width': 360.0,
            'height': 66.0,
            'bottomSafeArea': 34.0,
          };
        }
        return null;
      });
      platform.initialise();
    });

    tearDown(() {
      platform.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), null);
    });

    test('configureItems invokes channel with serialized items', () async {
      await platform.configureItems([
        const IOS26NavigationItem(
          id: 'tab1',
          sfSymbolName: 'star',
          label: 'Favorites',
        ),
      ]);

      expect(channelCalls.length, 1);
      expect(channelCalls.first.method, 'configureItems');
      final items = (channelCalls.first.arguments as Map)['items'] as List;
      expect(items.length, 1);
      expect((items.first as Map)['id'], 'tab1');
    });

    test('setSelectedIndex invokes channel with index', () async {
      await platform.setSelectedIndex(2);

      expect(channelCalls.any((c) =>
          c.method == 'setSelectedIndex' &&
          (c.arguments as Map)['index'] == 2), isTrue);
    });

    test('setMinimizeBehavior, setBottomAccessory, and setTabBarVisible', () async {
      await platform.setMinimizeBehavior('onScrollDown');
      expect(channelCalls.any((c) =>
          c.method == 'setMinimizeBehavior' &&
          (c.arguments as Map)['behavior'] == 'onScrollDown'), isTrue);

      await platform.setBottomAccessory(label: 'Now Playing');
      expect(channelCalls.any((c) =>
          c.method == 'setBottomAccessory' &&
          (c.arguments as Map)['label'] == 'Now Playing'), isTrue);

      await platform.setBottomAccessory(label: null);
      expect(channelCalls.any((c) =>
          c.method == 'setBottomAccessory' &&
          c.arguments == null), isTrue);

      await platform.setTabBarVisible(false, animated: true);
      expect(channelCalls.any((c) =>
          c.method == 'setTabBarVisible' &&
          (c.arguments as Map)['visible'] == false), isTrue);
    });

    test('getTabBarFrame returns parsed geometry', () async {
      final geo = await platform.getTabBarFrame();
      expect(geo, isNotNull);
      expect(geo!.height, 66.0);
      expect(geo.bottomSafeArea, 34.0);
    });

    test('receives onTabSelected and onTabBarFrameChanged from native', () async {
      int receivedIndex = -1;
      TabBarGeometry? receivedGeo;

      platform.onTabSelected = (idx) => receivedIndex = idx;
      platform.onTabBarFrameChanged = (geo) => receivedGeo = geo;

      // Simulate native calling onTabSelected
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final codec = const StandardMethodCodec();

      await messenger.handlePlatformMessage(
        channelName,
        codec.encodeMethodCall(const MethodCall('onTabSelected', {'index': 3})),
        (_) {},
      );
      expect(receivedIndex, 3);

      // Simulate native calling onTabBarFrameChanged
      await messenger.handlePlatformMessage(
        channelName,
        codec.encodeMethodCall(const MethodCall('onTabBarFrameChanged', {
          'x': 0.0,
          'y': 800.0,
          'width': 390.0,
          'height': 60.0,
          'bottomSafeArea': 34.0,
        })),
        (_) {},
      );
      expect(receivedGeo, isNotNull);
      expect(receivedGeo!.height, 60.0);
    });
  });

  group('IOS26LiquidGlassNavigationBar Widget Tests', () {
    const channelName = 'uz.cordialsoft.easyenglish/liquid_glass_nav';
    final List<MethodCall> channelCalls = [];

    setUp(() {
      channelCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName),
              (MethodCall call) async {
        channelCalls.add(call);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), null);
    });

    testWidgets('syncs configuration on mount when TargetPlatform.iOS',
        (WidgetTester tester) async {
      int selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            bottomNavigationBar: IOS26LiquidGlassNavigationBar(
              items: const [
                IOS26NavigationItem(id: 'home', sfSymbolName: 'house', label: 'Home'),
                IOS26NavigationItem(id: 'profile', sfSymbolName: 'person', label: 'Profile'),
              ],
              selectedIndex: selected,
              onSelected: (idx) => selected = idx,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(channelCalls.any((c) => c.method == 'configureItems'), isTrue);
      expect(channelCalls.any((c) => c.method == 'setSelectedIndex'), isTrue);
    });

    testWidgets('forwards scroll position to native platform when scrolled',
        (WidgetTester tester) async {
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: ListView.builder(
              controller: scrollController,
              itemCount: 50,
              itemBuilder: (_, i) => SizedBox(height: 50, child: Text('Item $i')),
            ),
            bottomNavigationBar: IOS26LiquidGlassNavigationBar(
              items: const [
                IOS26NavigationItem(id: 'feed', sfSymbolName: 'list.bullet', label: 'Feed'),
              ],
              selectedIndex: 0,
              onSelected: (_) {},
              scrollController: scrollController,
              activeTabId: 'feed',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll the list view
      scrollController.jumpTo(200);
      await tester.pump(const Duration(milliseconds: 100));

      expect(channelCalls.any((c) => c.method == 'updateScrollOffset'), isTrue);
    });
  });

  group('IOS26ScrollableContent Widget Tests', () {
    testWidgets('provides inset on iOS and 0 on Android', (WidgetTester tester) async {
      double receivedInset = -1;

      // Test on Android
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: IOS26ScrollableContent(
              fallbackInset: 88,
              builder: (context, inset) {
                receivedInset = inset;
                return Text('Inset: $inset');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(receivedInset, 0.0);

      // Test on iOS
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: IOS26ScrollableContent(
              fallbackInset: 88,
              builder: (context, inset) {
                receivedInset = inset;
                return Text('Inset: $inset');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(receivedInset, 88.0);
    });
  });
}
