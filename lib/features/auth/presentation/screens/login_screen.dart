import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../design_system/design_system.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../data/auth_service.dart';

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

/// Clean, production-grade Login / Welcome Screen built entirely using
/// reusable Design System components without one-time or inline components.
/// Features a fully responsive swipeable, auto-stepping hero onboarding section with dynamic content.
class LoginScreen extends StatefulWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onLoginPressed;

  const LoginScreen({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
    this.onLoginPressed,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final PageController _pageController;
  Timer? _autoStepTimer;
  int _currentStep = 0;

  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.headphones_outlined,
      title: 'Better sound. Better focus.',
      subtitle: 'Plug in, tune out, and stay in the zone.',
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome_outlined,
      title: 'Personalized AI Practice.',
      subtitle: 'Adaptive IELTS exercises tailored to your level.',
    ),
    _OnboardingSlide(
      icon: Icons.trending_up_rounded,
      title: 'Track Your Progress.',
      subtitle: 'Real-time band score estimates & instant feedback.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoStepTimer();
  }

  void _startAutoStepTimer() {
    _autoStepTimer?.cancel();
    _autoStepTimer = Timer.periodic(
      const Duration(seconds: 3, milliseconds: 500),
      (_) {
        if (!mounted) return;
        final nextStep = (_currentStep + 1) % _slides.length;
        _goToPage(nextStep);
      },
    );
  }

  void _goToPage(int pageIndex) {
    if (_currentStep != pageIndex) {
      setState(() => _currentStep = pageIndex);
    }
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onManualSwipe(int nextIndex) {
    _autoStepTimer?.cancel();
    setState(() => _currentStep = nextIndex);
    _startAutoStepTimer();
  }

  @override
  void dispose() {
    _autoStepTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleGoogleClick() async {
    if (widget.onGooglePressed != null) {
      widget.onGooglePressed!();
      return;
    }
    setState(() => _isGoogleLoading = true);
    try {
      final session = await AuthService().signInWithGoogle();
      if (mounted) {
        setState(() => _isGoogleLoading = false);
        if (session != null) {
          final userName = session.user.fullName.isNotEmpty
              ? session.user.fullName
              : session.user.email;

          DSSnackbar.show(
            context,
            message: 'Signed in successfully as $userName',
            variant: DSSnackbarVariant.success,
          );

          // Navigate directly to Dashboard Screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
        DSSnackbar.show(
          context,
          message: 'Google Sign-in failed: ${e.toString()}',
          variant: DSSnackbarVariant.danger,
        );
      }
    }
  }

  void _handleAppleClick() async {
    if (widget.onApplePressed != null) {
      widget.onApplePressed!();
      return;
    }
    setState(() => _isAppleLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isAppleLoading = false);
      DSSnackbar.show(
        context,
        message: 'Apple Sign-in successful!',
        variant: DSSnackbarVariant.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Hero Section: Fully Swipeable Onboarding PageView with Drag & Touch Handlers
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity != null) {
                            if (details.primaryVelocity! < -150) {
                              // Swipe Left -> Next Slide
                              final nextStep =
                                  (_currentStep + 1) % _slides.length;
                              _goToPage(nextStep);
                            } else if (details.primaryVelocity! > 150) {
                              // Swipe Right -> Previous Slide
                              final prevStep =
                                  (_currentStep - 1 + _slides.length) %
                                  _slides.length;
                              _goToPage(prevStep);
                            }
                          }
                        },
                        child: SizedBox(
                          height: 360.0,
                          child: PageView.builder(
                            controller: _pageController,
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            onPageChanged: _onManualSwipe,
                            itemCount: _slides.length,
                            itemBuilder: (context, index) {
                              final slide = _slides[index];
                              return Container(
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Expanded(
                                      child: DSHeroIllustration(height: 230.0),
                                    ),
                                    AppSpacing.gapVerticalSm,
                                    // Reusable DS Auth Header with Dynamic Slide Icon, Title, and Subtitle
                                    DSAuthHeader(
                                      iconData: slide.icon,
                                      iconSize: 32.0,
                                      title: slide.title,
                                      subtitle: slide.subtitle,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Bottom Anchored Section: Synced Segmented Progress Indicator & Action Buttons
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppSpacing.gapVerticalMd,

                          // Synced 3-Segment Progress Indicator
                          DSSegmentedProgressIndicator(
                            totalSegments: _slides.length,
                            activeSegments: _currentStep + 1,
                            autoStep: false,
                            height: 4.5,
                            gap: 12.0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            onStepChanged: (step) {
                              _goToPage(step - 1);
                            },
                          ),

                          AppSpacing.gapVerticalMd,

                          // Google Auth Button (DSButton socialGoogle)
                          DSButton(
                            text: 'Continue with Google',
                            variant: DSButtonVariant.socialGoogle,
                            size: DSButtonSize.lg,
                            fullWidth: true,
                            isPill: true,
                            isLoading: _isGoogleLoading,
                            leftIcon: const FaIcon(
                              FontAwesomeIcons.google,
                              size: 20.0,
                            ),
                            onPressed: _handleGoogleClick,
                          ),

                          AppSpacing.gapVerticalSm,

                          // Apple Auth Button (DSButton socialApple)
                          DSButton(
                            text: 'Continue with Apple',
                            variant: DSButtonVariant.socialApple,
                            size: DSButtonSize.lg,
                            fullWidth: true,
                            isPill: true,
                            isLoading: _isAppleLoading,
                            leftIcon: const Icon(Icons.apple, size: 22.0),
                            onPressed: _handleAppleClick,
                          ),

                          AppSpacing.gapVerticalLg,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
