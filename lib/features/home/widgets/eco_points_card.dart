import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';

/// Prominent Eco Points Card displaying real backend points and level status
class EcoPointsCard extends StatelessWidget {
  final int points;
  final int level;

  const EcoPointsCard({
    super.key,
    required this.points,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isSmall ? AppConstants.paddingM : AppConstants.paddingL,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E3A24),
                  const Color(0xFF132818),
                ]
              : [
                  AppColors.primary,
                  const Color(0xFF1B5E20),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(isDark ? 60 : 80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative nature leaf watermark
          Positioned(
            right: -15,
            bottom: -25,
            child: Icon(
              Icons.eco_rounded,
              size: isSmall ? 100 : 130,
              color: Colors.white.withAlpha(isDark ? 12 : 18),
            ),
          ),

          // Foreground Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with Level Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(40),
                          ),
                          child: const Icon(
                            Icons.stars_rounded,
                            size: 16,
                            color: AppColors.energy,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingS),
                        const Flexible(
                          child: Text(
                            'Total Eco Points',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Level pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingM - 4,
                      vertical: AppConstants.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusCircular),
                      border: Border.all(
                        color: Colors.white.withAlpha(60),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.military_tech_rounded,
                          size: 14,
                          color: AppColors.energy,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Level $level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: isSmall ? 12 : 18),

              // Points Counter
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$points',
                    style: AppTypography.displayLarge.copyWith(
                      color: Colors.white,
                      fontSize: isSmall ? 32 : 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'pts',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.paddingS),

              // Motivational subtext
              Text(
                'Keep building green habits to earn more rewards!',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withAlpha(200),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
