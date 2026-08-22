import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/eco_activity_model.dart';

/// Reusable Card displaying an individual Eco Activity with points, title, and category
class EcoActivityCard extends StatelessWidget {
  final EcoActivityModel activity;
  final VoidCallback onTap;

  const EcoActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  /// Maps category name to an icon
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'energy':
        return Icons.bolt_rounded;
      case 'waste':
      case 'recycling':
        return Icons.recycling_rounded;
      case 'transport':
      case 'mobility':
        return Icons.directions_bike_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'nature':
      case 'trees':
        return Icons.forest_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  /// Maps category name to a primary accent color
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'energy':
        return AppColors.energy;
      case 'waste':
      case 'recycling':
        return AppColors.secondary;
      case 'transport':
      case 'mobility':
        return AppColors.info;
      case 'water':
        return const Color(0xFF0288D1);
      case 'nature':
      case 'trees':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);
    final categoryColor = _getCategoryColor(activity.category);
    final categoryIcon = _getCategoryIcon(activity.category);

    return CustomCard(
      onTap: onTap,
      padding: EdgeInsets.all(
        isSmall ? AppConstants.paddingM : AppConstants.paddingL,
      ),
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Category Icon Container
          Container(
            width: isSmall ? 40 : 48,
            height: isSmall ? 40 : 48,
            decoration: BoxDecoration(
              color: categoryColor.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: categoryColor.withAlpha(isDark ? 60 : 40),
              ),
            ),
            child: Icon(
              categoryIcon,
              size: isSmall ? 20 : 24,
              color: isDark ? AppColors.accent : categoryColor,
            ),
          ),

          SizedBox(width: isSmall ? 10 : AppConstants.paddingM),

          // Main Information (Title, Description, Category)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Pill + Points Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isDark
                              ? AppColors.surfaceDark
                              : AppColors.backgroundLight),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusCircular,
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          activity.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Points Reward Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.energy.withAlpha(isDark ? 40 : 25),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusCircular,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            size: 12,
                            color: AppColors.energy,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '+${activity.points} pts',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.energy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Title
                Text(
                  activity.title,
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                // Short Description
                Text(
                  activity.description,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: isSmall ? 11 : 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
