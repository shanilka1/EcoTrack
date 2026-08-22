import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/achievement_model.dart';
import '../models/user_achievement_model.dart';

/// Reusable Card displaying an Achievement / Badge in locked or unlocked state
class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final UserAchievementModel? userAchievement;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.userAchievement,
  });

  bool get isUnlocked => userAchievement != null;

  IconData _getAchievementIcon(String? iconName, String reqType) {
    if (iconName != null && iconName.isNotEmpty) {
      switch (iconName.toLowerCase()) {
        case 'seed':
        case 'leaf':
          return Icons.eco_rounded;
        case 'star':
        case 'trophy':
          return Icons.emoji_events_rounded;
        case 'fire':
        case 'flame':
          return Icons.local_fire_department_rounded;
        case 'tree':
        case 'forest':
          return Icons.forest_rounded;
        case 'water':
          return Icons.water_drop_rounded;
        case 'bolt':
        case 'energy':
          return Icons.bolt_rounded;
        case 'bike':
          return Icons.directions_bike_rounded;
      }
    }

    switch (reqType) {
      case 'first_activity':
        return Icons.spa_rounded;
      case 'points_reached':
        return Icons.stars_rounded;
      case 'challenges_completed':
        return Icons.military_tech_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);
    final icon =
        _getAchievementIcon(achievement.iconName, achievement.requirementType);

    return CustomCard(
      padding: EdgeInsets.all(
        isSmall ? AppConstants.paddingM : AppConstants.paddingL,
      ),
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Icon Container
          Container(
            width: isSmall ? 48 : 54,
            height: isSmall ? 48 : 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUnlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.energy,
                        const Color(0xFFFFA000),
                      ],
                    )
                  : null,
              color: isUnlocked
                  ? null
                  : (isDark ? AppColors.surfaceDark : AppColors.borderLight),
              border: Border.all(
                color: isUnlocked
                    ? AppColors.energy
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: 1.5,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: AppColors.energy.withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isUnlocked ? icon : Icons.lock_outline_rounded,
              size: isSmall ? 24 : 28,
              color: isUnlocked
                  ? Colors.white
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),

          SizedBox(width: isSmall ? 10 : AppConstants.paddingM),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        achievement.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headingSmall.copyWith(
                          fontSize: isSmall ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight)
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.success.withAlpha(25)
                            : (isDark
                                ? AppColors.surfaceDark
                                : AppColors.backgroundLight),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusCircular),
                        border: Border.all(
                          color: isUnlocked
                              ? AppColors.success.withAlpha(80)
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUnlocked
                                ? Icons.check_circle_rounded
                                : Icons.lock_rounded,
                            size: 11,
                            color: isUnlocked
                                ? AppColors.success
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isUnlocked ? 'Unlocked' : 'Locked',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? AppColors.success
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Description
                Text(
                  achievement.description,
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

                const SizedBox(height: 6),

                // Unlock Date or Requirement Label
                if (isUnlocked)
                  Text(
                    'Unlocked on ${_formatDate(userAchievement!.unlockedAt)}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  )
                else
                  Text(
                    'Requirement: ${achievement.requirementValue} ${achievement.requirementType.replaceAll('_', ' ')}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
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
