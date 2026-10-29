import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/core/theme/app_colors.dart';
import 'package:easy_english/core/theme/app_theme.dart';
import 'package:easy_english/features/profile/presentation/widgets/color_palette_selector_sheet.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/quick_actions_grid_widget.dart';

void main() {
  group('AppColorPalette Unit Tests', () {
    test('Obsidian OLED is the dedicated minimal & monochromatic palette', () {
      expect(AppColorPalette.allPalettes.length, 1);
      expect(AppColorPalette.allPalettes.first.id, 'obsidian');
      expect(AppColorPalette.defaultPalette.id, 'obsidian');
    });

    test('AppColorPalette.fromId resolves correctly and falls back to obsidian', () {
      expect(AppColorPalette.fromId('obsidian').id, 'obsidian');
      expect(AppColorPalette.fromId('unknown_id').id, 'obsidian');
      expect(AppColorPalette.fromId(null).id, 'obsidian');
      expect(AppColorPalette.fromId('').id, 'obsidian');
    });

    test('Obsidian OLED has valid pitch black tokens and 4 preview colors', () {
      final palette = AppColorPalette.obsidian;
      expect(palette.name, 'Obsidian OLED');
      expect(palette.badge, 'OLED Black');
      expect(palette.description.isNotEmpty, true);
      expect(palette.previewColors.length, 4);

      // Verify pitch OLED black backgrounds and crisp studio white
      expect(palette.darkBackground, const Color(0xFF000000));
      expect(palette.darkPrimary, const Color(0xFFFFFFFF));
      expect(palette.lightBackground, const Color(0xFFFFFFFF));
      expect(palette.primary, const Color(0xFF000000));
    });

    test('AppColorPalette equality is based on id', () {
      expect(AppColorPalette.obsidian == AppColorPalette.obsidian, true);
      expect(AppColorPalette.obsidian.hashCode == AppColorPalette.obsidian.hashCode, true);
    });
  });

  group('ThemeController & AppTheme Palette Tests', () {
    test('ThemeController initializes with Obsidian OLED and notifies on change', () {
      final controller = ThemeController(ThemeMode.dark, AppColorPalette.obsidian);
      expect(controller.palette.id, 'obsidian');
      expect(AppColors.currentPalette.id, 'obsidian');

      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.setPalette(AppColorPalette.obsidian);
      expect(controller.palette.id, 'obsidian');
      expect(notified, false); // same instance, no unnecessary notify
    });

    test('AppTheme generates ThemeData respecting Obsidian OLED palette', () {
      final obsidianLight = AppTheme.lightThemeFor(AppColorPalette.obsidian);
      expect(obsidianLight.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      expect(obsidianLight.colorScheme.primary, const Color(0xFF000000));

      final obsidianDark = AppTheme.darkThemeFor(AppColorPalette.obsidian);
      expect(obsidianDark.scaffoldBackgroundColor, const Color(0xFF000000));
      expect(obsidianDark.colorScheme.primary, const Color(0xFFFFFFFF));
    });
  });

  group('ColorPaletteSelectorSheet Widget Tests', () {
    testWidgets('Renders Obsidian OLED palette option and header', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = ThemeController(ThemeMode.dark, AppColorPalette.obsidian);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightThemeFor(controller.palette),
          darkTheme: AppTheme.darkThemeFor(controller.palette),
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: ThemeScope(
              themeController: controller,
              child: ColorPaletteSelectorSheet(themeController: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Color Palette'), findsOneWidget);
      expect(find.text('Apply & Done'), findsOneWidget);

      // Check Obsidian OLED palette tile
      expect(find.text('Obsidian OLED'), findsOneWidget);
      expect(find.text('OLED Black'), findsOneWidget);
    });

    testWidgets('Tapping Obsidian OLED palette keeps it selected', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = ThemeController(ThemeMode.light, AppColorPalette.obsidian);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeScope(
              themeController: controller,
              child: ColorPaletteSelectorSheet(themeController: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Obsidian OLED
      await tester.tap(find.text('Obsidian OLED'));
      await tester.pumpAndSettle();

      expect(controller.palette.id, 'obsidian');
    });
  });

  group('Dashboard Quick Actions Palette Theming Tests', () {
    testWidgets('QuickActionsGridWidget displays Obsidian OLED badge and styles tiles', (WidgetTester tester) async {
      final controller = ThemeController(ThemeMode.dark, AppColorPalette.obsidian);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkThemeFor(controller.palette),
          home: Scaffold(
            body: ThemeScope(
              themeController: controller,
              child: const QuickActionsGridWidget(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title displays cleanly without palette badge text
      expect(find.text('Quick actions'), findsOneWidget);
      expect(find.text('Obsidian OLED'), findsNothing);

      // Verify all 8 modules are rendered
      expect(find.text('AI Coach'), findsOneWidget);
      expect(find.text('Writing'), findsOneWidget);
      expect(find.text('Speaking'), findsOneWidget);
      expect(find.text('Placement'), findsOneWidget);
      expect(find.text('Grammar'), findsOneWidget);
      expect(find.text('Sentence'), findsOneWidget);
      expect(find.text('Word Bank'), findsOneWidget);
      expect(find.text('Mock Exam'), findsOneWidget);
    });
  });
}
