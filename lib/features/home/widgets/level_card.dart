import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';

/// Level Card showing user's current level and tier status
class LevelCard extends StatelessWidget {
  final int level;
  final int currentPoints;

  const LevelCard({
    super.key,
    required this.level,
    required this.currentPoints,
  });

  /// Computes tier title based on level
  String _getLevelTier(int lvl) {
    if (lvl >= 10) return 'Eco Master';
    if (lvl >= 5) return 'Green Guardian';
    if (lvl >= 3) return 'Eco Enthusiast';
    return 'Eco Explorer';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);
    final tier = _getLevelTier(level);

    return CustomCard(
      padding: EdgeInsets.all(
        isSmall ? AppConstants.paddingM : AppConstants.paddingL,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withAlpha(isDark ? 50 : 25),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: isSmall ? 18 : 20,
              color: isDark ? AppColors.accent : AppColors.secondary,
            ),
          ),
          const SizedBox(width: AppConstants.paddingM - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rank & Level',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  tier,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 8 : AppConstants.paddingM,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryLight.withAlpha(30)
                  : AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
            ),
            child: Text(
              'Level $level',
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
