import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/eco_logo.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Temporary Authenticated Root Screen used for Step 5 development
/// Displays real Firestore user profile data and supports Logout
class AuthPlaceholderScreen extends StatelessWidget {
  final UserModel? user;
  final AuthService? authService;

  const AuthPlaceholderScreen({
    super.key,
    this.user,
    this.authService,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final service = authService ?? AuthService();
    await service.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('EcoTrack Authenticated Area'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isSmall ? AppConstants.paddingM : AppConstants.paddingL,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: EcoLogo(size: 72, showGlow: true),
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  Text(
                    'Authentication Successful!',
                    style: AppTypography.headingLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingS),

                  Text(
                    'Real Firebase session established with Cloud Firestore profile.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingL),

                  // User Profile Details Card
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.paddingS),
                            Text(
                              'Firestore User Profile',
                              style: AppTypography.headingSmall.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('Full Name', user?.fullName ?? 'Eco User'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Email', user?.email ?? 'user@ecotrack.org'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Role', user?.role ?? 'user'),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Eco Points',
                          '${user?.ecoPoints ?? 0} pts',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Level', 'Level ${user?.level ?? 1}'),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'UID',
                          user?.uid.isNotEmpty == true
                              ? '${user!.uid.substring(0, 10)}...'
                              : 'Connected',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXL),

                  // Sign Out Button
                  CustomButton(
                    text: 'Sign Out',
                    icon: Icons.logout_rounded,
                    type: ButtonType.outlined,
                    onPressed: () => _handleLogout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
