import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../models/eco_activity_model.dart';
import '../services/activity_service.dart';

/// Activity Details Screen displaying full Firestore information and atomic completion action
class ActivityDetailsScreen extends StatefulWidget {
  final EcoActivityModel? initialActivity;
  final String? activityId;
  final ActivityService? activityService;
  final AuthService? authService;

  const ActivityDetailsScreen({
    super.key,
    this.initialActivity,
    this.activityId,
    this.activityService,
    this.authService,
  });

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  late final ActivityService _activityService;
  late final AuthService _authService;

  EcoActivityModel? _activity;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCompleting = false;
  bool _isCompletedToday = false;

  @override
  void initState() {
    super.initState();
    _activityService = widget.activityService ?? ActivityService();
    _authService = widget.authService ?? AuthService();
    _activity = widget.initialActivity;

    if (_activity == null && widget.activityId != null) {
      _loadActivityDetails();
    } else if (_activity != null) {
      _checkCompletionStatus();
    }
  }

  Future<void> _checkCompletionStatus() async {
    final user = _authService.currentFirebaseUser;
    if (user == null || _activity == null) return;

    try {
      final isDone = await _activityService.isActivityCompletedToday(
        userId: user.uid,
        activityId: _activity!.id,
      );
      if (mounted) {
        setState(() {
          _isCompletedToday = isDone;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadActivityDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _activityService.fetchActivityById(widget.activityId!);
      if (mounted) {
        setState(() {
          _activity = result;
          _isLoading = false;
          if (_activity == null) {
            _errorMessage =
                'This activity was not found or is no longer active.';
          }
        });
        if (_activity != null) {
          _checkCompletionStatus();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load activity details. Please retry.';
        });
      }
    }
  }

  Future<void> _handleCompleteActivity() async {
    if (_activity == null || _isCompletedToday) return;

    final user = _authService.currentFirebaseUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to complete activities and earn points.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      final result = await _activityService.completeActivity(
        userId: user.uid,
        activityId: _activity!.id,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        setState(() {
          _isCompletedToday = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 Activity completed! +${result.pointsAwarded} Eco Points earned. (Total: ${result.newTotalPoints} pts)',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result.isAlreadyCompletedToday) {
        setState(() {
          _isCompletedToday = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errorMessage ??
                  'You have already completed this activity today.',
            ),
            backgroundColor: AppColors.energy,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errorMessage ??
                  'Failed to complete activity. Please try again.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Activity Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _buildBody(isDark, isSmall),
      ),
    );
  }

  Widget _buildBody(bool isDark, bool isSmall) {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Loading activity details...'),
      );
    }

    if (_errorMessage != null || _activity == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: AppConstants.paddingM),
              Text(
                'Activity Not Found',
                style: AppTypography.headingMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                _errorMessage ?? 'Unable to find this eco activity.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              CustomButton(
                text: 'Go Back',
                width: 140,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }

    final activity = _activity!;

    return Column(
      children: [
        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isSmall ? AppConstants.paddingM : AppConstants.paddingL,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner Card with Category & Points
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusL),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  AppColors.surfaceDark,
                                  const Color(0xFF1E2F22),
                                ]
                              : [
                                  const Color(0xFFE8F5E9),
                                  const Color(0xFFC8E6C9),
                                ],
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Category Badge
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.primaryLight.withAlpha(40)
                                        : AppColors.primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusCircular,
                                    ),
                                  ),
                                  child: Text(
                                    activity.category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Points Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.energy.withAlpha(isDark ? 40 : 30),
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusCircular,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      size: 14,
                                      color: AppColors.energy,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${activity.points} pts',
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

                          SizedBox(height: isSmall ? 14 : 20),

                          // Activity Title
                          Text(
                            activity.title,
                            style: AppTypography.headingLarge.copyWith(
                              fontSize: isSmall ? 22 : 26,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmall ? 18 : 24),

                    // Description Section
                    Text(
                      'About This Activity',
                      style: AppTypography.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Text(
                      activity.description,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),

                    SizedBox(height: isSmall ? 18 : 24),

                    // Environmental Benefit Card
                    if (activity.environmentalBenefit.isNotEmpty) ...[
                      Text(
                        'Environmental Impact',
                        style: AppTypography.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      CustomCard(
                        color: isDark
                            ? AppColors.surfaceDark
                            : const Color(0xFFF1F8F2),
                        border: Border.all(
                          color: (isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)
                              .withAlpha(40),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary
                                    .withAlpha(isDark ? 50 : 25),
                              ),
                              child: Icon(
                                Icons.eco_rounded,
                                size: 20,
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingM),
                            Expanded(
                              child: Text(
                                activity.environmentalBenefit,
                                style: AppTypography.bodyMedium.copyWith(
                                  height: 1.4,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom Completion Button Bar
        Container(
          padding: EdgeInsets.all(
            isSmall ? AppConstants.paddingM : AppConstants.paddingL,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _isCompletedToday
                  ? Container(
                      width: double.infinity,
                      height: AppConstants.buttonHeight,
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(isDark ? 40 : 25),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: AppColors.success.withAlpha(100),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Completed Today',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CustomButton(
                      text: 'Complete Activity',
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: _isCompleting,
                      onPressed: _isCompleting ? null : _handleCompleteActivity,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
