import 'package:flutter/material.dart';
import '../design_system.dart';

class DSLoginPage extends StatelessWidget {
  final ThemeController themeController;
  final VoidCallback onBackToOverview;

  const DSLoginPage({
    super.key,
    required this.themeController,
    required this.onBackToOverview,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LoginScreen(
            onGooglePressed: () {
              DSSnackbar.show(context, message: 'Continue with Google tapped!', variant: DSSnackbarVariant.success);
            },
            onApplePressed: () {
              DSSnackbar.show(context, message: 'Continue with Apple tapped!', variant: DSSnackbarVariant.success);
            },
          ),
          Positioned(
            top: 48,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: 'login_back_btn',
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              elevation: 4,
              onPressed: onBackToOverview,
              child: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
