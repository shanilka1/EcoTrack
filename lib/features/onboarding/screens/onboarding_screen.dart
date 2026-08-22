import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/onboarding_item.dart';
import '../widgets/onboarding_page_content.dart';
import '../widgets/onboarding_page_indicator.dart';

/// Complete 3-page Onboarding Flow Screen for EcoTrack
class OnboardingScreen extends StatefulWidget {
  /// Optional callback when onboarding is completed / skipped
  final VoidCallback? onCompleted;

  const OnboardingScreen({
    super.key,
    this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingItem> _items = OnboardingItem.items;

  bool get _isLastPage => _currentPage == _items.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNext() {
    if (!_isLastPage) {
      _pageController.nextPage(
        duration: AppConstants.animDurationMedium,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onSkip() {
    _pageController.animateToPage(
      _items.length - 1,
      duration: AppConstants.animDurationMedium,
      curve: Curves.easeInOutCubic,
    );
  }

  void _onGetStarted() {
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else {
      // Prepared navigation target toward Login screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Action
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall
                    ? AppConstants.paddingM
                    : AppConstants.paddingL,
                vertical: AppConstants.paddingS,
              ),
              child: SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Indicator (Subtle leaf icon)
                    Row(
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'EcoTrack',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),

                    // Skip Button
                    AnimatedOpacity(
                      opacity: _isLastPage ? 0.0 : 1.0,
                      duration: AppConstants.animDurationShort,
                      child: TextButton(
                        onPressed: _isLastPage ? null : _onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingS,
                            vertical: AppConstants.paddingXS,
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Swipeable Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingPageContent(item: _items[index]);
                },
              ),
            ),

            // Bottom Navigation & Controls Area
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                AppConstants.paddingM,
                isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                isSmall ? AppConstants.paddingM : AppConstants.paddingL,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicators
                  OnboardingPageIndicator(
                    count: _items.length,
                    currentIndex: _currentPage,
                  ),

                  SizedBox(height: isSmall ? 20 : 28),

                  // Action Buttons: Next vs Get Started
                  AnimatedSwitcher(
                    duration: AppConstants.animDurationMedium,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.95, end: 1.0)
                              .animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _isLastPage
                        ? CustomButton(
                            key: const ValueKey('get_started_btn'),
                            text: 'Get Started',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _onGetStarted,
                          )
                        : CustomButton(
                            key: const ValueKey('next_btn'),
                            text: 'Next',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _onNext,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
