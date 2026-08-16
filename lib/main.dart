import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/debug/api_debugger_overlay.dart';
import 'core/network/api_client.dart';
import 'core/notifications/push_notification_service.dart';
import 'design_system/design_system.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final initialMode = await ThemeController.loadThemeMode();
  final themeController = ThemeController(initialMode);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize push notifications asynchronously so UI mounts immediately
    PushNotificationService().initialize().catchError((e) {
      debugPrint('PushNotificationService init error: $e');
    });
  } catch (e) {
    debugPrint('Firebase.initializeApp warning: $e');
  }
  runApp(EasyIeltsApp(themeController: themeController));
}

class EasyIeltsApp extends StatefulWidget {
  final ThemeController? themeController;

  const EasyIeltsApp({super.key, this.themeController});

  @override
  State<EasyIeltsApp> createState() => _EasyIeltsAppState();
}

class _EasyIeltsAppState extends State<EasyIeltsApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = widget.themeController ?? ThemeController(ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      themeController: _themeController,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeController,
        builder: (context, mode, child) {
          return MaterialApp(
            navigatorKey: ApiDebuggerOverlay.navigatorKey,
            title: 'Easy IELTS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            builder: (context, child) {
              return ApiDebuggerOverlay(child: child ?? const SizedBox());
            },
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

/// Automatically checks whether user session is active on app launch.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final currentUser = AuthRepositoryImpl().getCurrentUser();
      final token = await ApiClient().getAccessToken();

      if (mounted) {
        setState(() {
          _isLoggedIn =
              currentUser != null || (token != null && token.isNotEmpty);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return _isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
