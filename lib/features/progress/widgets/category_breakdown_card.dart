import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';

/// Card displaying Category Impact Distribution with percentage bars
class CategoryBreakdownCard extends StatelessWidget {
  final Map<String, int> categoryCounts;
  final Map<String, double> categoryPercentages;

  const CategoryBreakdownCard({
    super.key,
    required this.categoryCounts,
    required this.categoryPercentages,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'waste':
        return AppColors.waste;
      case 'energy':
        return AppColors.energy;
      case 'transport':
        return AppColors.transport;
      case 'water':
        return AppColors.water;
      case 'nature':
      case 'biodiversity':
        return AppColors.primary;
      default:
        return AppColors.primaryLight;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'waste':
        return Icons.delete_outline_rounded;
      case 'energy':
        return Icons.bolt_rounded;
      case 'transport':
        return Icons.directions_bike_rounded;
      case 'water':
        return Icons.water_drop_outlined;
      case 'nature':
      case 'biodiversity':
        return Icons.forest_outlined;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    if (categoryCounts.isEmpty) {
      return CustomCard(
        padding: EdgeInsets.all(
          isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        ),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 40,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              'No Category Data',
              style: AppTypography.headingSmall.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete activities across different categories to see your impact breakdown.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return CustomCard(
      padding: EdgeInsets.all(
        isSmall ? AppConstants.paddingM - 2 : AppConstants.paddingL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impact by Category',
            style: AppTypography.headingSmall.copyWith(
              fontSize: isSmall ? 15 : 17,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Distribution of your completed eco actions',
            style: AppTypography.bodySmall.copyWith(
              fontSize: isSmall ? 10.5 : 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),

          SizedBox(height: isSmall ? 12 : 16),

          // Categories List
          for (final entry in categoryCounts.entries) ...[
            _buildCategoryRow(
              category: entry.key,
              count: entry.value,
              percentage: categoryPercentages[entry.key] ?? 0.0,
              isDark: isDark,
              isSmall: isSmall,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryRow({
    required String category,
    required int count,
    required double percentage,
    required bool isDark,
    required bool isSmall,
  }) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmall ? 11.5 : 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count ${count == 1 ? 'activity' : 'activities'} (${(percentage * 100).toInt()}%)',
              style: TextStyle(
                fontSize: isSmall ? 10.5 : 12,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 5,
            backgroundColor: isDark
                ? AppColors.surfaceLight.withAlpha(30)
                : AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
