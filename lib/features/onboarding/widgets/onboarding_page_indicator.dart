import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Animated page indicator dots for the onboarding carousel
class OnboardingPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color? activeColor;
  final Color? inactiveColor;

  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveActiveColor =
        activeColor ?? (isDark ? AppColors.primaryLight : AppColors.primary);
    final effectiveInactiveColor = inactiveColor ??
        (isDark
            ? AppColors.surfaceLight.withAlpha(50)
            : AppColors.borderLight);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;

        return AnimatedContainer(
          duration: AppConstants.animDurationMedium,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: isActive ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: isActive ? effectiveActiveColor : effectiveInactiveColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          ),
        );
      }),
    );
  }
}
