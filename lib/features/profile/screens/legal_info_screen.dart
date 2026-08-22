import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';

/// Screen displaying placeholder legal policies (Privacy Policy, Terms of Service)
class LegalInfoScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalInfoScreen({
    super.key,
    required this.title,
    required this.content,
  });

  factory LegalInfoScreen.privacyPolicy() {
    return const LegalInfoScreen(
      title: 'Privacy Policy',
      content:
          'EcoTrack respects your personal privacy. We only collect the minimal account information (such as your full name and email address) required for authentication and displaying your environmental progress.\n\nYour activity completion history and eco points are used solely for gamified features and leaderboard rankings within the platform.\n\nOfficial legal compliance documentation and data processing terms will be published prior to public deployment.',
    );
  }

  factory LegalInfoScreen.termsOfService() {
    return const LegalInfoScreen(
      title: 'Terms of Service',
      content:
          'By using the EcoTrack platform, you agree to record environmental actions truthfully and participate constructively within the community.\n\nEcoTrack points and milestone achievements are for motivational and gamification purposes. Any misuse, automation, or unauthorized manipulation of points may result in account review.\n\nOfficial terms and conditions governing service usage and intellectual property will be finalized for production release.',
    );
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
        title: Text(title),
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
              child: CustomCard(
                padding: EdgeInsets.all(
                  isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: AppTypography.headingSmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    Text(
                      content,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 14,
                        height: 1.6,
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
      ),
    );
  }
}
