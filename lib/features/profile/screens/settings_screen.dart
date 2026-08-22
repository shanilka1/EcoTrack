import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../../auth/services/auth_service.dart';

/// Settings Screen providing account, preferences, legal information, and logout
class SettingsScreen extends StatefulWidget {
  final AuthService? authService;

  const SettingsScreen({
    super.key,
    this.authService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AuthService _authService;
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'English'),
            _buildLanguageOption('Sinhala (සිංහල)', 'Sinhala (සිංහල)'),
            _buildLanguageOption('Tamil (தமிழ்)', 'Tamil (தமிழ்)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String label, String value) {
    final isSelected = _selectedLanguage == value;
    return ListTile(
      title: Text(label),
      leading: Icon(
        isSelected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
        color: isSelected ? AppColors.primary : null,
      ),
      onTap: () {
        setState(() => _selectedLanguage = value);
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to sign out of your EcoTrack account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isSmall ? AppConstants.paddingM : AppConstants.paddingL,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Account Section
                  _buildSectionHeader('Account', isDark),
                  const SizedBox(height: 8),
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profile',
                          subtitle: 'Change name and avatar URL',
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.editProfile),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSettingTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change Password',
                          subtitle: 'Update account credentials',
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.changePassword),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // 2. Preferences Section
                  _buildSectionHeader('Preferences', isDark),
                  const SizedBox(height: 8),
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          trailingText: _selectedLanguage,
                          onTap: _showLanguageDialog,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        SwitchListTile.adaptive(
                          secondary: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          title: const Text(
                            'Push Notifications',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Activity reminders and challenges',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          value: _notificationsEnabled,
                          activeTrackColor: AppColors.primaryLight,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() => _notificationsEnabled = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // 3. Legal & About Section
                  _buildSectionHeader('About & Legal', isDark),
                  const SizedBox(height: 8),
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.info_outline_rounded,
                          title: 'About EcoTrack',
                          subtitle: 'Version 1.0.0 (Build 100)',
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.about),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSettingTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.privacyPolicy),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSettingTile(
                          icon: Icons.gavel_rounded,
                          title: 'Terms of Service',
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.termsConditions),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // 4. Logout Action
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      onTap: _handleLogout,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.headingSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 52,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}
