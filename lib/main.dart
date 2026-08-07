import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/auth/api_client.dart';
import 'core/auth/firebase_auth_service.dart';
import 'core/debug/api_debugger_overlay.dart';
import 'design_system/design_system.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase.initializeApp warning: $e');
  }
  runApp(const EasyIeltsApp());
}

class EasyIeltsApp extends StatefulWidget {
  const EasyIeltsApp({super.key});

  @override
  State<EasyIeltsApp> createState() => _EasyIeltsAppState();
}

class _EasyIeltsAppState extends State<EasyIeltsApp> {
  final ThemeController _themeController = ThemeController(ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
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
            return ApiDebuggerOverlay(
              child: child ?? const SizedBox(),
            );
          },
          home: const AuthWrapper(),
        );
      },
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
      final firebaseUser = FirebaseAuthService().currentUser;
      final token = await ApiClient().getAccessToken();

      if (mounted) {
        setState(() {
          _isLoggedIn = firebaseUser != null || (token != null && token.isNotEmpty);
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
