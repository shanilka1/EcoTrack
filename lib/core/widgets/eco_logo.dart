import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable EcoTrack Brand Logo Widget
class EcoLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const EcoLogo({
    super.key,
    this.size = 110.0,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primaryLight.withAlpha(200),
                  AppColors.primaryDark,
                ]
              : [
                  AppColors.primaryLight,
                  AppColors.primary,
                ],
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: (isDark ? AppColors.primaryLight : AppColors.primary)
                      .withAlpha(80),
                  blurRadius: size * 0.35,
                  spreadRadius: size * 0.05,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Container(
          width: size * 0.82,
          height: size * 0.82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: Border.all(
              color: (isDark ? AppColors.primaryLight : AppColors.primary)
                  .withAlpha(50),
              width: 2.0,
            ),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Secondary subtle accent leaf
                Positioned(
                  right: size * 0.18,
                  top: size * 0.18,
                  child: Icon(
                    Icons.energy_savings_leaf_rounded,
                    size: size * 0.28,
                    color: AppColors.accent.withAlpha(220),
                  ),
                ),
                // Main eco leaf
                Icon(
                  Icons.eco_rounded,
                  size: size * 0.46,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
