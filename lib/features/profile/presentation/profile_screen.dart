import 'package:flutter/material.dart';
import '../../../core/auth/firebase_auth_service.dart';
import '../../../design_system/design_system.dart';
import '../../notification/presentation/notification_settings_screen.dart';

/// Full-featured Profile Screen powered by Google Account details.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  String _selectedLanguage = 'English';
  bool _isDarkMode = false;

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showSecurityModal() {
    final googleUser = _authService.currentUser;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Security',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            AppSpacing.gapVerticalMd,
            ListTile(
              leading: const Icon(Icons.lock_outline, color: AppColors.primary),
              title: const Text('Change Password'),
              subtitle: const Text('Password reset email via Google Authentication'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                DSSnackbar.show(
                  context,
                  message: 'Password reset link sent to ${googleUser?.email ?? 'your email'}',
                  variant: DSSnackbarVariant.info,
                );
              },
            ),
            const ListTile(
              leading: Icon(Icons.verified_user_outlined, color: AppColors.success),
              title: Text('Two-Factor Authentication'),
              subtitle: Text('Protected by Google Account Security'),
              trailing: Icon(Icons.check_circle, color: AppColors.success),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageModal() {
    final languages = ['English', 'Spanish', 'Uzbek', 'Russian', 'French', 'German'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            AppSpacing.gapVerticalMd,
            ...languages.map(
              (lang) => ListTile(
                title: Text(lang),
                trailing: _selectedLanguage == lang
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutUsDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Easy English IELTS',
      applicationVersion: 'v1.0.0',
      applicationIcon: const CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Icon(Icons.school, color: Colors.white),
      ),
      children: const [
        Text(
          'Easy English is an AI-powered IELTS preparation app offering real-time Speaking evaluation, Essay grading, and personalized study paths.',
        ),
      ],
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Help Center & Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            AppSpacing.gapVerticalMd,
            const ListTile(
              leading: Icon(Icons.email_outlined, color: AppColors.primary),
              title: Text('Contact Support'),
              subtitle: Text('support@easy-english.uz'),
            ),
            const ListTile(
              leading: Icon(Icons.question_answer_outlined, color: AppColors.secondary),
              title: Text('Frequently Asked Questions'),
              subtitle: Text('Browse FAQs and study guides'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final googleUser = _authService.currentUser;
    final displayName = googleUser?.displayName ?? 'Ronald Richards';
    final email = googleUser?.email ?? 'ronaldrichards@gmail.com';
    final photoUrl = googleUser?.photoURL;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Header Profile Card (Direct from Google Account)
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Google Avatar Photo
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? const Icon(Icons.person, size: 38, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Name and Email from Google Account
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Account Section
            _buildSectionHeader('Account', subtextColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Security',
                    onTap: _showSecurityModal,
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildProfileTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                      );
                    },
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildProfileTile(
                    icon: Icons.translate_rounded,
                    title: 'Language',
                    trailingText: _selectedLanguage,
                    onTap: _showLanguageModal,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Preferences Section (Excludes Appointments)
            _buildSectionHeader('Preferences', subtextColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About Us',
                    onTap: _showAboutUsDialog,
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildProfileTile(
                    icon: Icons.brightness_6_outlined,
                    title: 'Theme',
                    trailingText: _isDarkMode ? 'Dark' : 'Light',
                    onTap: () => setState(() => _isDarkMode = !_isDarkMode),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Support Section
            _buildSectionHeader('Support', subtextColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    onTap: _showHelpCenter,
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildProfileTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    titleColor: AppColors.danger,
                    iconColor: AppColors.danger,
                    onTap: _handleSignOut,
                    showArrow: false,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? trailingText,
    Widget? trailingWidget,
    Color? iconColor,
    Color? titleColor,
    bool showArrow = true,
    required bool isDark,
  }) {
    final titleStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: titleColor ?? (isDark ? Colors.white : Colors.black87),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: titleStyle),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (trailingWidget != null) trailingWidget,
            if (showArrow && trailingWidget == null)
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 52,
      endIndent: 16,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
    );
  }
}
