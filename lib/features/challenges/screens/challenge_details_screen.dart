import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';
import '../services/challenge_service.dart';

/// Challenge Details Screen displaying full Firestore challenge details, progress, and reward status
class ChallengeDetailsScreen extends StatefulWidget {
  final ChallengeModel? initialChallenge;
  final String? challengeId;
  final UserChallengeProgressModel? initialProgress;
  final ChallengeService? challengeService;
  final AuthService? authService;

  const ChallengeDetailsScreen({
    super.key,
    this.initialChallenge,
    this.challengeId,
    this.initialProgress,
    this.challengeService,
    this.authService,
  });

  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  late final ChallengeService _challengeService;
  late final AuthService _authService;

  ChallengeModel? _challenge;
  UserChallengeProgressModel? _progress;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _challengeService = widget.challengeService ?? ChallengeService();
    _authService = widget.authService ?? AuthService();

    _challenge = widget.initialChallenge;
    _progress = widget.initialProgress;

    if (_challenge == null && widget.challengeId != null) {
      _loadChallenge();
    } else if (_challenge != null && _progress == null) {
      _loadUserProgress();
    }
  }

  Future<void> _loadChallenge() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final challenge =
          await _challengeService.fetchChallengeById(widget.challengeId!);
      if (mounted) {
        setState(() {
          _challenge = challenge;
          _isLoading = false;
          if (_challenge == null) {
            _errorMessage = 'Challenge not found or has been removed.';
          }
        });
        if (_challenge != null) {
          _loadUserProgress();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load challenge details: $e';
        });
      }
    }
  }

  Future<void> _loadUserProgress() async {
    final user = _authService.currentFirebaseUser;
    if (user == null || _challenge == null) return;

    try {
      final progress = await _challengeService.getUserChallengeProgress(
        userId: user.uid,
        challengeId: _challenge!.id,
      );
      if (mounted) {
        setState(() {
          _progress = progress;
        });
      }
    } catch (_) {}
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
        title: const Text('Challenge Details'),
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
        child: LoadingIndicator(message: 'Loading challenge details...'),
      );
    }

    if (_errorMessage != null || _challenge == null) {
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
                'Challenge Not Found',
                style: AppTypography.headingMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                _errorMessage ?? 'Unable to find this environmental challenge.',
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

    final challenge = _challenge!;
    final currentProgress = _progress?.progress ?? 0;
    final target = challenge.target > 0 ? challenge.target : 1;
    final progressFraction = (currentProgress / target).clamp(0.0, 1.0);
    final isCompleted = _progress?.isCompleted ?? false;
    final isExpired = challenge.isExpired && !isCompleted;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isSmall ? AppConstants.paddingM : AppConstants.paddingL,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner Card
              Container(
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
                            AppColors.surfaceDark,
                            const Color(0xFF2C2411),
                          ]
                        : [
                            const Color(0xFFFFF8E1),
                            const Color(0xFFFFECB3),
                          ],
                  ),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Type Badge
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.energy.withAlpha(40)
                                  : AppColors.energy.withAlpha(30),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusCircular,
                              ),
                            ),
                            child: Text(
                              challenge.targetCategory != null
                                  ? '${challenge.targetCategory} Challenge'
                                  : 'Eco Challenge',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.energy,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Reward Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.energy.withAlpha(isDark ? 50 : 35),
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

                    SizedBox(height: isSmall ? 12 : 18),

                    // Title
                    Text(
                      challenge.title,
                      style: AppTypography.headingLarge.copyWith(
                        fontSize: isSmall ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmall ? 16 : 22),

              // Progress Section Card
              CustomCard(
                padding: EdgeInsets.all(
                  isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Your Progress',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.headingSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
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
                            color: isCompleted
                                ? AppColors.success.withAlpha(25)
                                : (isExpired
                                    ? AppColors.error.withAlpha(25)
                                    : AppColors.primary.withAlpha(25)),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusCircular,
                            ),
                          ),
                          child: Text(
                            isCompleted
                                ? 'Completed'
                                : (isExpired ? 'Expired' : 'In Progress'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? AppColors.success
                                  : (isExpired
                                      ? AppColors.error
                                      : AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '$currentProgress / $target completed',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isSmall ? 12 : 14,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progressFraction * 100).toInt()}%',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 12 : 14,
                            color: isCompleted
                                ? AppColors.success
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusCircular),
                      child: LinearProgressIndicator(
                        value: progressFraction,
                        minHeight: 8,
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
                    if (isCompleted) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(20),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(
                            color: AppColors.success.withAlpha(60),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: AppColors.success,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Challenge Complete! Reward points have been credited to your profile.',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
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

              SizedBox(height: isSmall ? 16 : 22),

              // Description Section
              Text(
                'About This Challenge',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                challenge.description,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),

              SizedBox(height: isSmall ? 16 : 22),

              // Timeline & Dates Card
              CustomCard(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppConstants.paddingM - 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Challenge Duration',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatDate(challenge.startDate)}  to  ${_formatDate(challenge.endDate)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: isSmall ? 12 : 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
