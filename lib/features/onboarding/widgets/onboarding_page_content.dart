import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../models/onboarding_item.dart';
import 'onboarding_illustration.dart';

/// Single page layout for the Onboarding carousel
class OnboardingPageContent extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPageContent({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppConstants.paddingM : AppConstants.paddingL,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: isSmall ? 10 : 20),

          // Nature/Gamification Visual Illustration
          OnboardingIllustration(item: item),

          SizedBox(height: isSmall ? 24 : 36),

          // Slide Title
          Text(
            item.title,
            style: AppTypography.displayMedium.copyWith(
              fontSize: isSmall ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.paddingM),

          // Slide Description
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              item.description,
              style: AppTypography.bodyLarge.copyWith(
                fontSize: isSmall ? 14 : 15,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: isSmall ? 10 : 20),
        ],
      ),
    );
  }
}
