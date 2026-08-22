import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/eco_logo.dart';

/// Clean, modern, responsive Splash Screen with smooth entrance and loading animations
class SplashScreen extends StatefulWidget {
  /// Configurable duration before triggering the next navigation step
  final Duration splashDuration;

  /// Optional custom navigation callback; if null, defaults to navigation preparation
  final VoidCallback? onSplashComplete;

  /// Whether navigation should automatically execute after duration
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    this.splashDuration = const Duration(seconds: 3),
    this.onSplashComplete,
    this.autoNavigate = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _loadingController;

  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _taglineFadeAnimation;
  late final Animation<Offset> _taglineSlideAnimation;
  late final Animation<double> _loadingFadeAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation Setup (1400ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.95, curve: Curves.easeOut),
      ),
    );

    _taglineSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _loadingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // 2. Continuous Loading Animation Setup (1800ms repeating loop)
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Start entrance animation
    _entranceController.forward();

    // Setup navigation timer (prepared for Onboarding screen)
    _setupNavigation();
  }

  void _setupNavigation() {
    _navigationTimer = Timer(widget.splashDuration, () {
      if (!mounted) return;

      if (widget.onSplashComplete != null) {
        widget.onSplashComplete!();
      } else if (widget.autoNavigate) {
        // Prepared navigation target for the Onboarding screen
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmallScreen = ResponsiveHelper.isSmallMobile(context);
    final logoSize = isSmallScreen ? 95.0 : 125.0;

    return Scaffold(
      body: Stack(
        children: [
          // Background ambient gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          AppColors.backgroundDark,
                          const Color(0xFF0F1E12),
                          AppColors.backgroundDark,
                        ]
                      : [
                          const Color(0xFFF1F8F2),
                          AppColors.backgroundLight,
                          const Color(0xFFE8F5E9),
                        ],
                ),
              ),
            ),
          ),

          // Ambient decorative soft nature glow rings (non-overflowing)
          Positioned(
            top: -60,
            right: -60,
            child: _buildAmbientCircle(
              size: 220,
              color: (isDark ? AppColors.primaryLight : AppColors.primary)
                  .withAlpha(isDark ? 15 : 22),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _buildAmbientCircle(
              size: 260,
              color: AppColors.secondary.withAlpha(isDark ? 15 : 20),
            ),
          ),

          // Main Foreground Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingL,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: EcoLogo(size: logoSize),
                      ),
                    ),
                    SizedBox(
                      height: isSmallScreen
                          ? AppConstants.paddingL
                          : AppConstants.paddingXL,
                    ),

                    // Animated App Name
                    FadeTransition(
                      opacity: _titleFadeAnimation,
                      child: SlideTransition(
                        position: _titleSlideAnimation,
                        child: Text(
                          AppStrings.appName,
                          style: AppTypography.displayLarge.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingS),

                    // Animated Tagline
                    FadeTransition(
                      opacity: _taglineFadeAnimation,
                      child: SlideTransition(
                        position: _taglineSlideAnimation,
                        child: Text(
                          AppStrings.appTagline,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: isSmallScreen
                          ? AppConstants.paddingXL
                          : AppConstants.paddingXL * 1.5,
                    ),

                    // Subtle, Smooth Loading Indicator
                    FadeTransition(
                      opacity: _loadingFadeAnimation,
                      child: _buildSubtleLoadingIndicator(context, isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Subtle Ambient Circle Decoration
  Widget _buildAmbientCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  /// Modern, subtle animated progress pill indicator
  Widget _buildSubtleLoadingIndicator(BuildContext context, bool isDark) {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Container(
          width: 140,
          height: 4,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withAlpha(18),
            borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
          ),
          clipBehavior: Clip.antiAlias,
          child: Align(
            alignment: Alignment(
              -1.5 + (3.0 * _loadingController.value),
              0.0,
            ),
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusCircular),
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withAlpha(180),
                    isDark ? AppColors.primaryLight : AppColors.primary,
                    AppColors.secondary.withAlpha(200),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
