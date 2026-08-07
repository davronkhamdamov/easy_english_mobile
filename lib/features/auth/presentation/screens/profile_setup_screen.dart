import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../design_system/design_system.dart';
import '../../../dashboard/presentation/dashboard_screen.dart';
import '../../../profile/services/profile_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserModel? user;

  const ProfileSetupScreen({
    super.key,
    this.user,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _avatarController;
  String _selectedRole = 'student';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user?.fullName ?? '',
    );
    _bioController = TextEditingController(
      text: widget.user?.bio ?? 'Preparing for IELTS Academic 2026',
    );
    _avatarController = TextEditingController(
      text: widget.user?.avatarUrl ?? '',
    );
    _selectedRole = widget.user?.role ?? 'student';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;

    setState(() => _isLoading = true);

    try {
      await _profileService.createProfile(
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        avatarUrl: _avatarController.text.trim().isNotEmpty
            ? _avatarController.text.trim()
            : null,
        role: _selectedRole,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        DSSnackbar.show(
          context,
          message: 'Profile saved successfully!',
          variant: DSSnackbarVariant.success,
        );

        // Navigate to Dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        DSSnackbar.show(
          context,
          message: 'Failed to save profile: ${e.toString()}',
          variant: DSSnackbarVariant.danger,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Setup Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DSAuthHeader(
                  iconData: Icons.person_outline_rounded,
                  title: 'Complete Your Profile',
                  subtitle: 'Personalize your IELTS learning journey',
                ),
                AppSpacing.gapVerticalLg,

                // Avatar Preview
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                AppSpacing.gapVerticalLg,

                // Full Name Input
                DSInput(
                  label: 'Full Name',
                  placeholder: 'e.g. Alex Smith',
                  controller: _nameController,
                  leftIcon: const Icon(Icons.person),
                ),
                AppSpacing.gapVerticalMd,

                // Bio Input
                DSInput(
                  label: 'Bio / Goal',
                  placeholder: 'e.g. Aiming for IELTS Band 7.5',
                  controller: _bioController,
                  leftIcon: const Icon(Icons.edit_note_rounded),
                ),
                AppSpacing.gapVerticalMd,

                // Avatar URL Input
                DSInput(
                  label: 'Avatar URL (Optional)',
                  placeholder: 'https://example.com/avatar.jpg',
                  controller: _avatarController,
                  leftIcon: const Icon(Icons.link_rounded),
                ),
                AppSpacing.gapVerticalLg,

                // Save Profile Button
                DSButton(
                  text: 'Save & Continue',
                  variant: DSButtonVariant.primary,
                  size: DSButtonSize.lg,
                  fullWidth: true,
                  isLoading: _isLoading,
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
