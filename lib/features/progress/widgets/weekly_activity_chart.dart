import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';

/// Weekly Activity Bar Chart displaying activity completions from Mon to Sun
class WeeklyActivityChart extends StatelessWidget {
  final Map<String, int> weeklyCounts;
  final Map<String, int> weeklyPoints;

  const WeeklyActivityChart({
    super.key,
    required this.weeklyCounts,
    required this.weeklyPoints,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    final totalActivitiesThisWeek =
        weeklyCounts.values.fold(0, (sum, c) => sum + c);
    final totalPointsThisWeek =
        weeklyPoints.values.fold(0, (sum, p) => sum + p);

    final maxCount =
        weeklyCounts.values.isEmpty ? 1 : weeklyCounts.values.reduce(max);
    final effectiveMax = maxCount > 0 ? maxCount : 1;

    return CustomCard(
      padding: EdgeInsets.all(
        isSmall ? AppConstants.paddingM - 2 : AppConstants.paddingL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Activity',
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: isSmall ? 15 : 17,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalActivitiesThisWeek activities this week',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: isSmall ? 10.5 : 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.energy.withAlpha(isDark ? 40 : 25),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusCircular),
                ),
                child: Text(
                  '+$totalPointsThisWeek pts',
                  style: TextStyle(
                    fontSize: isSmall ? 10.5 : 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.energy,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isSmall ? 14 : 20),

          // Bar Chart Display
          SizedBox(
            height: isSmall ? 110 : 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyCounts.entries.map((entry) {
                final day = entry.key;
                final count = entry.value;
                final barFraction = (count / effectiveMax).clamp(0.0, 1.0);
                final hasValue = count > 0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Count text if > 0
                        if (hasValue)
                          Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        else
                          const SizedBox(height: 12),

                        const SizedBox(height: 3),

                        // Vertical Bar
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: hasValue
                                  ? max(barFraction, 0.12)
                                  : 0.06,
                              child: Container(
                                width: isSmall ? 12 : 18,
                                decoration: BoxDecoration(
                                  gradient: hasValue
                                      ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            AppColors.primaryLight,
                                            AppColors.primary,
                                          ],
                                        )
                                      : null,
                                  color: hasValue
                                      ? null
                                      : (isDark
                                          ? AppColors.surfaceLight.withAlpha(30)
                                          : AppColors.borderLight),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Day label
                        Text(
                          day,
                          style: TextStyle(
                            fontSize: isSmall ? 9.5 : 11,
                            fontWeight:
                                hasValue ? FontWeight.bold : FontWeight.w500,
                            color: hasValue
                                ? (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight)
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
