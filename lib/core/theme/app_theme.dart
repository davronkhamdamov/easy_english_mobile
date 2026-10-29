import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_colors.dart';
import 'app_palette.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

export 'app_palette.dart';

/// ThemeData generator for Light and Dark modes with dynamic palette support.
class AppTheme {
  AppTheme._();

  /// Builds a [ThemeData] instance for Light mode with the specified or active palette.
  static ThemeData lightThemeFor([AppColorPalette? palette]) {
    final p = palette ?? AppColors.currentPalette;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: p.lightBackground,
      colorScheme: ColorScheme.light(
        primary: p.primary,
        secondary: p.secondary,
        surface: p.lightSurface,
        surfaceContainerHighest: p.lightSurfaceVariant,
        onSurfaceVariant: p.lightTextSecondary,
        outline: p.lightBorder,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: p.lightTextPrimary,
        onError: Colors.white,
      ),
      dividerColor: p.lightBorder,
      dividerTheme: DividerThemeData(
        color: p.lightBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: p.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: p.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        titleTextStyle: AppTypography.h2.copyWith(color: p.lightTextPrimary),
        contentTextStyle: AppTypography.bodyMd.copyWith(color: p.lightTextSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.lightSurface,
        modalBackgroundColor: p.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return p.lightTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primary;
          return p.lightSurfaceVariant;
        }),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: p.lightTextPrimary),
        displayMedium: TextStyle(color: p.lightTextPrimary),
        displaySmall: TextStyle(color: p.lightTextPrimary),
        headlineLarge: TextStyle(color: p.lightTextPrimary),
        headlineMedium: TextStyle(color: p.lightTextPrimary),
        headlineSmall: TextStyle(color: p.lightTextPrimary),
        titleLarge: TextStyle(color: p.lightTextPrimary),
        titleMedium: TextStyle(color: p.lightTextPrimary),
        titleSmall: TextStyle(color: p.lightTextPrimary),
        bodyLarge: TextStyle(color: p.lightTextPrimary),
        bodyMedium: TextStyle(color: p.lightTextPrimary),
        bodySmall: TextStyle(color: p.lightTextSecondary),
        labelLarge: TextStyle(color: p.lightTextPrimary),
        labelMedium: TextStyle(color: p.lightTextSecondary),
        labelSmall: TextStyle(color: p.lightTextMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: p.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: p.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: p.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        focusElevation: 5,
        hoverElevation: 5,
        highlightElevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          side: BorderSide(color: p.lightBorder.withValues(alpha: 0.6)),
        ),
      ),
    );
  }

  /// Builds a [ThemeData] instance for Dark mode with the specified or active palette.
  static ThemeData darkThemeFor([AppColorPalette? palette]) {
    final p = palette ?? AppColors.currentPalette;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: p.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: p.darkPrimary,
        secondary: p.secondary,
        surface: p.darkSurface,
        surfaceContainerHighest: p.darkSurfaceVariant,
        onSurfaceVariant: p.darkTextSecondary,
        outline: p.darkBorder,
        error: AppColors.danger,
        onPrimary: p.darkBackground,
        onSecondary: Colors.white,
        onSurface: p.darkTextPrimary,
        onError: Colors.white,
      ),
      dividerColor: p.darkBorder,
      dividerTheme: DividerThemeData(
        color: p.darkBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: p.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: p.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        titleTextStyle: AppTypography.h2.copyWith(color: p.darkTextPrimary),
        contentTextStyle: AppTypography.bodyMd.copyWith(color: p.darkTextSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.darkSurface,
        modalBackgroundColor: p.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.darkBackground;
          return p.darkTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.darkPrimary;
          return p.darkSurfaceVariant;
        }),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: p.darkTextPrimary),
        displayMedium: TextStyle(color: p.darkTextPrimary),
        displaySmall: TextStyle(color: p.darkTextPrimary),
        headlineLarge: TextStyle(color: p.darkTextPrimary),
        headlineMedium: TextStyle(color: p.darkTextPrimary),
        headlineSmall: TextStyle(color: p.darkTextPrimary),
        titleLarge: TextStyle(color: p.darkTextPrimary),
        titleMedium: TextStyle(color: p.darkTextPrimary),
        titleSmall: TextStyle(color: p.darkTextPrimary),
        bodyLarge: TextStyle(color: p.darkTextPrimary),
        bodyMedium: TextStyle(color: p.darkTextPrimary),
        bodySmall: TextStyle(color: p.darkTextSecondary),
        labelLarge: TextStyle(color: p.darkTextPrimary),
        labelMedium: TextStyle(color: p.darkTextSecondary),
        labelSmall: TextStyle(color: p.darkTextMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: p.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: p.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: p.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.darkSurfaceVariant,
        foregroundColor: p.darkTextPrimary,
        elevation: 3,
        focusElevation: 5,
        hoverElevation: 5,
        highlightElevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          side: BorderSide(color: p.darkBorder),
        ),
      ),
    );
  }

  /// Default light theme using current active palette
  static ThemeData get lightTheme => lightThemeFor(AppColors.currentPalette);

  /// Default dark theme using current active palette
  static ThemeData get darkTheme => darkThemeFor(AppColors.currentPalette);
}

/// Controller to toggle between Light, Dark, and System themes dynamically with persistence,
/// along with selecting and persisting minimal & monochromatic color palettes.
class ThemeController extends ValueNotifier<ThemeMode> {
  static const String _storageKey = 'easy_english_theme_mode';
  static const String _paletteStorageKey = 'easy_english_color_palette';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  AppColorPalette _palette;

  ThemeController([
    super.mode = ThemeMode.system,
    AppColorPalette? initialPalette,
  ]) : _palette = initialPalette ?? AppColors.currentPalette {
    AppColors.currentPalette = _palette;
  }

  /// The active color palette.
  AppColorPalette get palette => _palette;

  /// The active theme mode.
  ThemeMode get themeMode => value;

  /// Helper to get controller from BuildContext via ThemeScope
  static ThemeController of(BuildContext context) {
    return ThemeScope.of(context);
  }

  /// Helper to optionally get controller from BuildContext
  static ThemeController? maybeOf(BuildContext context) {
    return ThemeScope.maybeOf(context);
  }

  /// Determines whether dark mode is active (handles ThemeMode.system via platformDispatcher).
  bool get isDarkMode {
    if (value == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return value == ThemeMode.dark;
  }

  bool get isDark => isDarkMode;

  /// Loads stored theme mode asynchronously.
  static Future<ThemeMode> loadThemeMode() async {
    try {
      final savedMode = await _storage.read(key: _storageKey);
      if (savedMode == 'light') return ThemeMode.light;
      if (savedMode == 'dark') return ThemeMode.dark;
      if (savedMode == 'system') return ThemeMode.system;
    } catch (e) {
      debugPrint('Error loading saved theme mode: $e');
    }
    return ThemeMode.system;
  }

  /// Loads stored palette asynchronously.
  static Future<AppColorPalette> loadPalette() async {
    try {
      final savedId = await _storage.read(key: _paletteStorageKey);
      if (savedId != null && savedId.isNotEmpty) {
        return AppColorPalette.fromId(savedId);
      }
    } catch (e) {
      debugPrint('Error loading saved color palette: $e');
    }
    return AppColorPalette.obsidian;
  }

  /// Toggles between Light and Dark mode.
  void toggleTheme() {
    final nextMode = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(nextMode);
  }

  /// Sets specific ThemeMode and persists choice.
  void setThemeMode(ThemeMode mode) {
    if (value != mode) {
      value = mode;
      _storage.write(key: _storageKey, value: mode.name).catchError((e) {
        debugPrint('Error saving theme mode: $e');
      });
    }
  }

  /// Sets specific [AppColorPalette] and persists choice.
  void setPalette(AppColorPalette newPalette) {
    if (_palette != newPalette) {
      _palette = newPalette;
      AppColors.currentPalette = newPalette;
      _storage.write(key: _paletteStorageKey, value: newPalette.id).catchError((e) {
        debugPrint('Error saving color palette: $e');
      });
      notifyListeners();
    }
  }
}

/// InheritedNotifier for ThemeController to expose theme updates across widget tree.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController themeController,
    required super.child,
  }) : super(notifier: themeController);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.notifier!;
  }

  static ThemeController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    return scope?.notifier;
  }
}
