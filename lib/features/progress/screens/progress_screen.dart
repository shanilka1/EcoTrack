import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../models/user_statistics_model.dart';
import '../services/progress_service.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/stat_summary_card.dart';
import '../widgets/weekly_activity_chart.dart';

/// Progress and Statistics Screen displaying aggregated user impact metrics
class ProgressScreen extends StatefulWidget {
  final ProgressService? progressService;
  final AuthService? authService;
  final UserStatisticsModel? initialStats;

  const ProgressScreen({
    super.key,
    this.progressService,
    this.authService,
    this.initialStats,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final ProgressService _progressService;
  late final AuthService _authService;

  UserStatisticsModel? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _progressService = widget.progressService ?? ProgressService();
    _authService = widget.authService ?? AuthService();

    if (widget.initialStats != null) {
      _stats = widget.initialStats;
      _isLoading = false;
    } else {
      _loadStatistics();
    }
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = _authService.currentFirebaseUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please sign in to view your progress.';
      });
      return;
    }

    try {
      final stats = await _progressService.getUserStatistics(user.uid);
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load statistics. Please check your internet connection.';
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
        title: const Text('My Progress'),
        centerTitle: true,
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
        child: LoadingIndicator(message: 'Calculating your eco impact...'),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: AppConstants.paddingM),
              Text(
                'Unable to load progress',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              CustomButton(
                text: 'Retry',
                icon: Icons.refresh_rounded,
                width: 140,
                onPressed: _loadStatistics,
              ),
            ],
          ),
        ),
      );
    }

    final stats = _stats ?? UserStatisticsModel.empty();

    if (!stats.hasActivity) {
      return RefreshIndicator(
        onRefresh: _loadStatistics,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.all(
            isSmall ? AppConstants.paddingM : AppConstants.paddingL,
          ),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Icon(
              Icons.insights_rounded,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              'No Activity Recorded Yet',
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              'Start logging environmental activities to visualize your weekly progress, points trend, and category impact breakdown.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Center(
              child: CustomButton(
                text: 'Explore Activities',
                icon: Icons.eco_rounded,
                width: 200,
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.activities);
                },
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.all(
          isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        ),
        children: [
          // 4-Card Overview Grid
          Row(
            children: [
              Expanded(
                child: StatSummaryCard(
                  title: 'Eco Points',
                  value: '${stats.totalEcoPoints}',
                  icon: Icons.stars_rounded,
                  iconColor: AppColors.energy,
                  subtitle: 'Level ${stats.level}',
                ),
              ),
              SizedBox(width: isSmall ? 8 : AppConstants.paddingM),
              Expanded(
                child: StatSummaryCard(
                  title: 'Activities',
                  value: '${stats.totalActivitiesCompleted}',
                  icon: Icons.checklist_rtl_rounded,
                  iconColor: AppColors.primary,
                  subtitle: 'Completed',
                ),
              ),
            ],
          ),

          SizedBox(height: isSmall ? 8 : AppConstants.paddingM),

          Row(
            children: [
              Expanded(
                child: StatSummaryCard(
                  title: 'Challenges',
                  value: '${stats.completedChallengesCount}',
                  icon: Icons.flag_rounded,
                  iconColor: AppColors.transport,
                  subtitle: 'Achieved',
                ),
              ),
              SizedBox(width: isSmall ? 8 : AppConstants.paddingM),
              Expanded(
                child: StatSummaryCard(
                  title: 'Badges',
                  value: '${stats.unlockedAchievementsCount}',
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFFFA000),
                  subtitle: 'Unlocked',
                ),
              ),
            ],
          ),

          SizedBox(height: isSmall ? 16 : 22),

          // Weekly Activity Chart
          WeeklyActivityChart(
            weeklyCounts: stats.weeklyDailyCounts,
            weeklyPoints: stats.weeklyDailyPoints,
          ),

          SizedBox(height: isSmall ? 16 : 22),

          // Category Breakdown Card
          CategoryBreakdownCard(
            categoryCounts: stats.categoryCounts,
            categoryPercentages: stats.categoryPercentages,
          ),

          SizedBox(height: isSmall ? 16 : 22),

          // Monthly Impact Summary
          if (stats.monthlyCounts.isNotEmpty) ...[
            CustomCard(
              padding: EdgeInsets.all(
                isSmall ? AppConstants.paddingM : AppConstants.paddingL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Milestones',
                    style: AppTypography.headingSmall.copyWith(
                      fontSize: isSmall ? 15 : 17,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Summary of eco activities logged per month',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: isSmall ? 11 : 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final entry in stats.monthlyCounts.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: isSmall ? 12 : 13.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            '${entry.value} ${entry.value == 1 ? 'activity' : 'activities'}',
                            style: TextStyle(
                              fontSize: isSmall ? 12 : 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
