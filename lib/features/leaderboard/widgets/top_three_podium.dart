import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../models/leaderboard_user_model.dart';

/// Podium display for the top 3 ranked Eco Warriors (🥇 1st, 🥈 2nd, 🥉 3rd)
class TopThreePodium extends StatelessWidget {
  final List<LeaderboardUserModel> topUsers;
  final String? currentUserId;

  const TopThreePodium({
    super.key,
    required this.topUsers,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (topUsers.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    final first = topUsers.isNotEmpty ? topUsers[0] : null;
    final second = topUsers.length > 1 ? topUsers[1] : null;
    final third = topUsers.length > 2 ? topUsers[2] : null;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        vertical: AppConstants.paddingS,
      ),
      padding: EdgeInsets.fromLTRB(
        isSmall ? 8 : AppConstants.paddingM,
        isSmall ? 12 : AppConstants.paddingL,
        isSmall ? 8 : AppConstants.paddingM,
        isSmall ? 12 : AppConstants.paddingM,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 🥈 2nd Place (Left)
          if (second != null)
            Expanded(
              child: _buildPodiumColumn(
                context: context,
                user: second,
                rank: 2,
                pedestalHeight: isSmall ? 65 : 85,
                avatarRadius: isSmall ? 22 : 26,
                medalColor: const Color(0xFFC0C0C0), // Silver
                medalIcon: Icons.military_tech_rounded,
                isDark: isDark,
                isSmall: isSmall,
                isCurrentUser: second.uid == currentUserId,
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),

          // 🥇 1st Place (Center - Highest)
          if (first != null)
            Expanded(
              child: _buildPodiumColumn(
                context: context,
                user: first,
                rank: 1,
                pedestalHeight: isSmall ? 90 : 115,
                avatarRadius: isSmall ? 28 : 34,
                medalColor: const Color(0xFFFFD700), // Gold
                medalIcon: Icons.emoji_events_rounded,
                isDark: isDark,
                isSmall: isSmall,
                isCurrentUser: first.uid == currentUserId,
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),

          // 🥉 3rd Place (Right)
          if (third != null)
            Expanded(
              child: _buildPodiumColumn(
                context: context,
                user: third,
                rank: 3,
                pedestalHeight: isSmall ? 50 : 65,
                avatarRadius: isSmall ? 20 : 24,
                medalColor: const Color(0xFFCD7F32), // Bronze
                medalIcon: Icons.military_tech_outlined,
                isDark: isDark,
                isSmall: isSmall,
                isCurrentUser: third.uid == currentUserId,
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required BuildContext context,
    required LeaderboardUserModel user,
    required int rank,
    required double pedestalHeight,
    required double avatarRadius,
    required Color medalColor,
    required IconData medalIcon,
    required bool isDark,
    required bool isSmall,
    required bool isCurrentUser,
  }) {
    final initials = user.fullName.isNotEmpty
        ? user.fullName
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join()
        : 'U';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Medal / Crown Icon
        Icon(
          medalIcon,
          size: rank == 1 ? (isSmall ? 22 : 26) : (isSmall ? 18 : 22),
          color: medalColor,
        ),

        const SizedBox(height: 4),

        // Avatar with border
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrentUser
                      ? AppColors.primary
                      : medalColor.withAlpha(200),
                  width: rank == 1 ? 2.5 : 2,
                ),
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: isDark
                    ? AppColors.surfaceLight.withAlpha(40)
                    : AppColors.borderLight,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        initials,
                        style: TextStyle(
                          fontSize: avatarRadius * 0.75,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      )
                    : null,
              ),
            ),
            // Rank Badge
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: medalColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  width: 1.5,
                ),
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // User Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            user.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12.5,
              fontWeight:
                  isCurrentUser ? FontWeight.bold : FontWeight.w600,
              color: isCurrentUser
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            ),
          ),
        ),

        const SizedBox(height: 2),

        // Points
        Text(
          '${user.ecoPoints} pts',
          style: TextStyle(
            fontSize: isSmall ? 10.5 : 11.5,
            fontWeight: FontWeight.bold,
            color: AppColors.energy,
          ),
        ),

        const SizedBox(height: 8),

        // Pedestal Bar
        Container(
          width: double.infinity,
          height: pedestalHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusM),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                medalColor.withAlpha(isDark ? 80 : 60),
                medalColor.withAlpha(isDark ? 30 : 20),
              ],
            ),
            border: Border.all(
              color: medalColor.withAlpha(isDark ? 100 : 80),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: AppTypography.headingSmall.copyWith(
                fontSize: rank == 1 ? (isSmall ? 18 : 22) : (isSmall ? 14 : 17),
                fontWeight: FontWeight.bold,
                color: medalColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
