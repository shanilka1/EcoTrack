import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../models/achievement_model.dart';
import '../models/user_achievement_model.dart';
import '../services/achievement_service.dart';
import '../widgets/achievement_card.dart';

/// Achievements Screen displaying real Firestore achievements, progress, and unlocked badges
class AchievementsScreen extends StatefulWidget {
  final AchievementService? achievementService;
  final AuthService? authService;
  final List<AchievementModel>? initialAchievements;
  final Map<String, UserAchievementModel>? initialUnlockedMap;

  const AchievementsScreen({
    super.key,
    this.achievementService,
    this.authService,
    this.initialAchievements,
    this.initialUnlockedMap,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late final AchievementService _achievementService;
  late final AuthService _authService;
  late final TabController _tabController;

  List<AchievementModel> _achievements = [];
  Map<String, UserAchievementModel> _unlockedMap = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _achievementService = widget.achievementService ?? AchievementService();
    _authService = widget.authService ?? AuthService();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.initialAchievements != null) {
      _achievements = widget.initialAchievements!;
      _unlockedMap = widget.initialUnlockedMap ?? {};
      _isLoading = false;
    } else {
      _loadAchievements();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final achievements =
          await _achievementService.fetchActiveAchievements();
      final user = _authService.currentFirebaseUser;
      Map<String, UserAchievementModel> unlocked = {};

      if (user != null) {
        unlocked = await _achievementService
            .getUserUnlockedAchievements(user.uid);
      }

      if (mounted) {
        setState(() {
          _achievements = achievements;
          _unlockedMap = unlocked;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load achievements. Please check your connection.';
        });
      }
    }
  }

  List<AchievementModel> get _unlockedList {
    return _achievements.where((a) => _unlockedMap.containsKey(a.id)).toList();
  }

  List<AchievementModel> get _lockedList {
    return _achievements.where((a) => !_unlockedMap.containsKey(a.id)).toList();
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
        title: const Text('Achievements & Badges'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          indicatorColor:
              isDark ? AppColors.primaryLight : AppColors.primary,
          labelColor:
              isDark ? AppColors.primaryLight : AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 11 : 13,
          ),
          tabs: [
            Tab(text: 'All (${_achievements.length})'),
            Tab(text: 'Unlocked (${_unlockedList.length})'),
            Tab(text: 'Locked (${_lockedList.length})'),
          ],
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
        child: LoadingIndicator(message: 'Fetching environmental badges...'),
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
                'Unable to load badges',
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
                onPressed: _loadAchievements,
              ),
            ],
          ),
        ),
      );
    }

    final totalCount = _achievements.length;
    final unlockedCount = _unlockedList.length;
    final progressFraction =
        totalCount > 0 ? (unlockedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        // Summary Header Card
        Padding(
          padding: EdgeInsets.fromLTRB(
            isSmall ? AppConstants.paddingM : AppConstants.paddingL,
            AppConstants.paddingM,
            isSmall ? AppConstants.paddingM : AppConstants.paddingL,
            AppConstants.paddingS,
          ),
          child: CustomCard(
            padding: EdgeInsets.all(
              isSmall ? AppConstants.paddingM : AppConstants.paddingL,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.energy.withAlpha(isDark ? 40 : 25),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 24,
                    color: AppColors.energy,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Badges Unlocked',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$unlockedCount / $totalCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusCircular,
                        ),
                        child: LinearProgressIndicator(
                          value: progressFraction,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? AppColors.surfaceDark
                              : AppColors.borderLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.energy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tabs Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAchievementList(_achievements, 'all', isDark, isSmall),
              _buildAchievementList(
                  _unlockedList, 'unlocked', isDark, isSmall),
              _buildAchievementList(_lockedList, 'locked', isDark, isSmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementList(
    List<AchievementModel> list,
    String filterTab,
    bool isDark,
    bool isSmall,
  ) {
    if (list.isEmpty) {
      return _buildEmptyState(filterTab, isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.all(
          isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final achievement = list[index];
          return AchievementCard(
            achievement: achievement,
            userAchievement: _unlockedMap[achievement.id],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String filterTab, bool isDark) {
    String title;
    String subtitle;
    IconData icon;

    switch (filterTab) {
      case 'unlocked':
        icon = Icons.lock_outline_rounded;
        title = 'No badges unlocked yet';
        subtitle =
            'Complete eco activities and challenges to unlock your first environmental badge!';
        break;
      case 'locked':
        icon = Icons.verified_rounded;
        title = 'All badges unlocked! 🎉';
        subtitle =
            'Outstanding achievement! You have unlocked every available eco badge.';
        break;
      default:
        icon = Icons.emoji_events_outlined;
        title = 'No achievements available';
        subtitle =
            'Environmental badges and milestones will appear here when published.';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              title,
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingS),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
