import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';

/// Screen displaying application information, version, and mission statement
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('About EcoTrack'),
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
                children: [
                  const SizedBox(height: 20),

                  // Brand Icon Container
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(isDark ? 50 : 30),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingM),

                  Text(
                    'EcoTrack',
                    style: AppTypography.headingLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 (Build 100)',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // Mission Statement Card
                  CustomCard(
                    padding: EdgeInsets.all(
                      isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Mission',
                          style: AppTypography.headingSmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'EcoTrack is dedicated to empowering individuals and communities to adopt sustainable daily habits, reduce carbon footprints, and actively participate in environmental conservation through gamified activities and challenges.',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 13.5,
                            height: 1.5,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingM),

                  // Features Overview Card
                  CustomCard(
                    padding: EdgeInsets.all(
                      isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Core Capabilities',
                          style: AppTypography.headingSmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem(
                          Icons.checklist_rtl_rounded,
                          'Daily Eco Actions',
                          'Log activities across Waste, Energy, Transport and Nature.',
                          isDark,
                        ),
                        _buildFeatureItem(
                          Icons.flag_rounded,
                          'Community Challenges',
                          'Participate in time-bound environmental challenges.',
                          isDark,
                        ),
                        _buildFeatureItem(
                          Icons.emoji_events_rounded,
                          'Badges & Rewards',
                          'Unlock verifiable milestone achievements as you level up.',
                          isDark,
                        ),
                        _buildFeatureItem(
                          Icons.leaderboard_rounded,
                          'Global Leaderboard',
                          'Track community standings and climb rankings.',
                          isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  Text(
                    '© 2026 EcoTrack Initiative. All rights reserved.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
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

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
