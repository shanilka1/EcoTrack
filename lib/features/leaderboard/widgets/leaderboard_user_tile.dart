import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../models/leaderboard_user_model.dart';

/// Reusable tile representing a single ranked user in the Leaderboard list
class LeaderboardUserTile extends StatelessWidget {
  final LeaderboardUserModel user;
  final bool isCurrentUser;

  const LeaderboardUserTile({
    super.key,
    required this.user,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    final initials = user.fullName.isNotEmpty
        ? user.fullName
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join()
        : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        vertical: isSmall ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withAlpha(isDark ? 35 : 20)
            : (isDark ? AppColors.surfaceDark : AppColors.cardLight),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.primary
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank Position
          SizedBox(
            width: isSmall ? 30 : 36,
            child: Text(
              '#${user.rank}',
              style: TextStyle(
                fontSize: isSmall ? 13 : 15,
                fontWeight: FontWeight.bold,
                color: isCurrentUser
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
          ),

          // Avatar
          CircleAvatar(
            radius: isSmall ? 16 : 19,
            backgroundColor: isDark
                ? AppColors.surfaceLight.withAlpha(50)
                : AppColors.borderLight,
            backgroundImage: user.photoUrl != null
                ? NetworkImage(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? Text(
                    initials,
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 13,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  )
                : null,
          ),

          SizedBox(width: isSmall ? 10 : AppConstants.paddingM),

          // User Name & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: isSmall ? 13 : 14.5,
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isCurrentUser
                              ? (isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Level ${user.level}',
                  style: TextStyle(
                    fontSize: isSmall ? 10.5 : 11.5,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Eco Points Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.energy.withAlpha(isDark ? 35 : 20),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusCircular),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.eco_rounded,
                  size: 13,
                  color: AppColors.energy,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user.ecoPoints} pts',
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.energy,
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
