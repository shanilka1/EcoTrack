import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../models/leaderboard_user_model.dart';
import '../services/leaderboard_service.dart';
import '../widgets/leaderboard_user_tile.dart';
import '../widgets/top_three_podium.dart';

/// Leaderboard Screen displaying real Firestore rankings sorted by ecoPoints descending
class LeaderboardScreen extends StatefulWidget {
  final LeaderboardService? leaderboardService;
  final AuthService? authService;
  final List<LeaderboardUserModel>? initialUsers;

  const LeaderboardScreen({
    super.key,
    this.leaderboardService,
    this.authService,
    this.initialUsers,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final LeaderboardService _leaderboardService;
  late final AuthService _authService;
  late final TabController _tabController;

  List<LeaderboardUserModel> _users = [];
  int _currentUserRank = 0;
  LeaderboardUserModel? _currentUserModel;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _leaderboardService = widget.leaderboardService ?? LeaderboardService();
    _authService = widget.authService ?? AuthService();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.initialUsers != null) {
      _users = widget.initialUsers!;
      _isLoading = false;
      _computeCurrentUserRank();
    } else {
      _loadLeaderboard();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _computeCurrentUserRank() {
    final currentUid = _authService.currentFirebaseUser?.uid;
    if (currentUid == null) return;

    for (final user in _users) {
      if (user.uid == currentUid) {
        _currentUserRank = user.rank;
        _currentUserModel = user;
        break;
      }
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _leaderboardService.fetchOverallLeaderboard();
      final currentUid = _authService.currentFirebaseUser?.uid;
      int rank = 0;
      LeaderboardUserModel? currentModel;

      if (currentUid != null) {
        for (final u in users) {
          if (u.uid == currentUid) {
            rank = u.rank;
            currentModel = u;
            break;
          }
        }
        if (rank == 0) {
          rank = await _leaderboardService.fetchUserRank(currentUid);
        }
      }

      if (mounted) {
        setState(() {
          _users = users;
          _currentUserRank = rank;
          _currentUserModel = currentModel;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load leaderboard. Please check your internet connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);
    final currentUid = _authService.currentFirebaseUser?.uid;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Leaderboard'),
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
            fontSize: isSmall ? 11.5 : 13,
          ),
          tabs: const [
            Tab(text: 'Overall'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBody(isDark, isSmall, currentUid),
            ),

            // Current User Sticky Card (if logged in and rank found)
            if (_currentUserRank > 0 && !_isLoading && _errorMessage == null)
              _buildCurrentUserStickyBar(isDark, isSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark, bool isSmall, String? currentUid) {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Loading leaderboard rankings...'),
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
                'Unable to load rankings',
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
                onPressed: _loadLeaderboard,
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverallTab(isDark, isSmall, currentUid),
        _buildPeriodicTab(
          'Weekly Leaderboard',
          'Weekly rankings will be tabulated at the conclusion of the active cycle.',
          isDark,
        ),
        _buildPeriodicTab(
          'Monthly Leaderboard',
          'Monthly leader rankings will be refreshed at the end of the calendar month.',
          isDark,
        ),
      ],
    );
  }

  Widget _buildOverallTab(bool isDark, bool isSmall, String? currentUid) {
    if (_users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 56,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(height: AppConstants.paddingM),
              Text(
                'No Leaderboard Data',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                'Complete eco activities to earn points and claim your spot on the leaderboard!',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final topThree = _users.take(3).toList();
    final remainingUsers = _users.length > 3 ? _users.skip(3).toList() : [];

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? AppConstants.paddingS : AppConstants.paddingM,
        ),
        children: [
          // Top 3 Podium
          if (topThree.isNotEmpty)
            TopThreePodium(
              topUsers: topThree,
              currentUserId: currentUid,
            ),

          const SizedBox(height: AppConstants.paddingS),

          // Remaining ranked list
          if (remainingUsers.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isSmall ? AppConstants.paddingM : AppConstants.paddingL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4,
                      bottom: AppConstants.paddingS,
                    ),
                    child: Text(
                      'Rankings',
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  for (final user in remainingUsers)
                    LeaderboardUserTile(
                      user: user,
                      isCurrentUser: user.uid == currentUid,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodicTab(String title, String subtitle, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timelapse_rounded,
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
              constraints: const BoxConstraints(maxWidth: 320),
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

  Widget _buildCurrentUserStickyBar(bool isDark, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        vertical: isSmall ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 20),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusCircular),
            ),
            child: Text(
              '#$_currentUserRank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: AppConstants.paddingM),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentUserModel?.fullName ?? 'Your Ranking',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmall ? 12.5 : 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'Keep completing activities to climb!',
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Points
          if (_currentUserModel != null)
            Text(
              '${_currentUserModel!.ecoPoints} pts',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.energy,
              ),
            ),
        ],
      ),
    );
  }
}
