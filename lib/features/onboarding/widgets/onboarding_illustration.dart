import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../models/onboarding_item.dart';

/// Modern nature & gamification themed illustration component for onboarding
class OnboardingIllustration extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingIllustration({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);
    final size = isSmall ? 180.0 : 230.0;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ambient glow ring
            Container(
              width: size * 0.95,
              height: size * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.secondaryColor.withAlpha(isDark ? 30 : 40),
              ),
            ),

            // Mid layered gradient ring
            Container(
              width: size * 0.82,
              height: size * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.primaryColor.withAlpha(isDark ? 160 : 130),
                    item.secondaryColor.withAlpha(isDark ? 120 : 90),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.primaryColor.withAlpha(isDark ? 60 : 40),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),

            // Inner surface card
            Container(
              width: size * 0.68,
              height: size * 0.68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border.all(
                  color: (isDark ? Colors.white : item.primaryColor)
                      .withAlpha(35),
                  width: 2.0,
                ),
              ),
              child: Center(
                child: Icon(
                  item.mainIcon,
                  size: size * 0.35,
                  color: isDark ? item.secondaryColor : item.primaryColor,
                ),
              ),
            ),

            // Floating Top-Right Badge
            Positioned(
              top: size * 0.08,
              right: size * 0.08,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.paddingS + 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.secondaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: item.secondaryColor.withAlpha(120),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  item.badgeIcon,
                  size: isSmall ? 18 : 22,
                  color: Colors.white,
                ),
              ),
            ),

            // Floating Bottom-Left Subtle Sparkle / Leaf
            Positioned(
              bottom: size * 0.12,
              left: size * 0.08,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.paddingXS + 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? AppColors.surfaceDark : Colors.white),
                  border: Border.all(
                    color: item.primaryColor.withAlpha(80),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: isSmall ? 14 : 16,
                  color: item.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
