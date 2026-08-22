import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum OnboardingType {
  trackHabits,
  earnPoints,
  makeImpact,
}

/// Static model holding content for an onboarding slide
class OnboardingItem {
  final String title;
  final String description;
  final OnboardingType type;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData mainIcon;
  final IconData badgeIcon;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
    required this.mainIcon,
    required this.badgeIcon,
  });

  /// The standard 3-slide static onboarding list for EcoTrack
  static const List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Track Your Habits',
      description:
          'Build better environmental habits by tracking your everyday eco-friendly actions.',
      type: OnboardingType.trackHabits,
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.accent,
      mainIcon: Icons.eco_rounded,
      badgeIcon: Icons.checklist_rtl_rounded,
    ),
    OnboardingItem(
      title: 'Earn Eco Points',
      description:
          'Complete eco-friendly activities and earn points as you build positive habits.',
      type: OnboardingType.earnPoints,
      primaryColor: AppColors.secondary,
      secondaryColor: AppColors.energy,
      mainIcon: Icons.stars_rounded,
      badgeIcon: Icons.bolt_rounded,
    ),
    OnboardingItem(
      title: 'Make an Impact',
      description:
          'Complete challenges, unlock achievements and see your environmental progress.',
      type: OnboardingType.makeImpact,
      primaryColor: AppColors.primaryLight,
      secondaryColor: AppColors.energy,
      mainIcon: Icons.public_rounded,
      badgeIcon: Icons.emoji_events_rounded,
    ),
  ];
}
