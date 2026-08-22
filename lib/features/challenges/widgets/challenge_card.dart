import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';

/// Reusable Challenge Card displaying real challenge data, progress bar, and reward
class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final UserChallengeProgressModel? progress;
  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.progress,
    required this.onTap,
  });

  /// Maps challenge type to icon
  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'activity_count':
        return Icons.checklist_rtl_rounded;
      case 'category_activity':
        return Icons.category_rounded;
      case 'eco_points':
        return Icons.stars_rounded;
      case 'streak':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    final currentProgress = progress?.progress ?? 0;
    final target = challenge.target > 0 ? challenge.target : 1;
    final progressFraction = (currentProgress / target).clamp(0.0, 1.0);
    final isCompleted = progress?.isCompleted ?? false;
    final isExpired = challenge.isExpired && !isCompleted;

    return CustomCard(
      onTap: onTap,
      padding: EdgeInsets.all(
        isSmall ? AppConstants.paddingM : AppConstants.paddingL,
      ),
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Type Badge + Reward Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Challenge Type Icon & Pill
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.energy.withAlpha(isDark ? 40 : 25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getTypeIcon(challenge.type),
                        size: 14,
                        color: AppColors.energy,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        challenge.targetCategory != null
                            ? '${challenge.targetCategory} Challenge'
                            : 'Eco Challenge',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Reward Points Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.energy.withAlpha(isDark ? 40 : 25),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusCircular),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 13,
                      color: AppColors.energy,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${challenge.rewardPoints} pts',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.energy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            challenge.title,
            style: AppTypography.headingSmall.copyWith(
              fontSize: isSmall ? 15 : 17,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Description
          Text(
            challenge.description,
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

          const SizedBox(height: 12),

          // Progress Bar & Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCompleted
                        ? 'Completed 🎉'
                        : '$currentProgress / $target Completed',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? AppColors.success
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                  ),
                  Text(
                    isCompleted
                        ? '100%'
                        : '${(progressFraction * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? AppColors.success
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
                child: LinearProgressIndicator(
                  value: progressFraction,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted
                        ? AppColors.success
                        : (isExpired ? AppColors.error : AppColors.primary),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Bottom Status / Expiry Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Days remaining / Status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : (isExpired
                            ? Icons.timer_off_outlined
                            : Icons.schedule_rounded),
                    size: 13,
                    color: isCompleted
                        ? AppColors.success
                        : (isExpired
                            ? AppColors.error
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight)),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isCompleted
                        ? 'Reward Claimed'
                        : (isExpired
                            ? 'Expired'
                            : '${challenge.daysRemaining} days left'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isCompleted
                          ? AppColors.success
                          : (isExpired
                              ? AppColors.error
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight)),
                    ),
                  ),
                ],
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
