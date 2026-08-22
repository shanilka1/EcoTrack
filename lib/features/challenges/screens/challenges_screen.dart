import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';
import '../services/challenge_service.dart';
import '../widgets/challenge_card.dart';

/// Challenges Screen displaying real Firestore challenges categorized by status
class ChallengesScreen extends StatefulWidget {
  final ChallengeService? challengeService;
  final AuthService? authService;
  final List<ChallengeModel>? initialChallenges;
  final Map<String, UserChallengeProgressModel>? initialProgressMap;

  const ChallengesScreen({
    super.key,
    this.challengeService,
    this.authService,
    this.initialChallenges,
    this.initialProgressMap,
  });

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late final ChallengeService _challengeService;
  late final AuthService _authService;
  late final TabController _tabController;

  List<ChallengeModel> _challenges = [];
  Map<String, UserChallengeProgressModel> _progressMap = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _challengeService = widget.challengeService ?? ChallengeService();
    _authService = widget.authService ?? AuthService();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.initialChallenges != null) {
      _challenges = widget.initialChallenges!;
      _progressMap = widget.initialProgressMap ?? {};
      _isLoading = false;
    } else {
      _loadChallenges();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final challenges = await _challengeService.fetchActiveChallenges();
      final user = _authService.currentFirebaseUser;
      Map<String, UserChallengeProgressModel> progress = {};

      if (user != null) {
        progress =
            await _challengeService.getUserAllChallengeProgress(user.uid);
      }

      if (mounted) {
        setState(() {
          _challenges = challenges;
          _progressMap = progress;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load challenges. Please check your internet connection.';
        });
      }
    }
  }

  List<ChallengeModel> get _activeChallenges {
    return _challenges.where((c) {
      final prog = _progressMap[c.id];
      final isCompleted = prog?.isCompleted ?? false;
      return !c.isExpired && !isCompleted;
    }).toList();
  }

  List<ChallengeModel> get _completedChallenges {
    return _challenges.where((c) {
      final prog = _progressMap[c.id];
      return prog?.isCompleted ?? false;
    }).toList();
  }

  List<ChallengeModel> get _expiredChallenges {
    return _challenges.where((c) {
      final prog = _progressMap[c.id];
      final isCompleted = prog?.isCompleted ?? false;
      return c.isExpired && !isCompleted;
    }).toList();
  }

  void _navigateToDetails(ChallengeModel challenge) {
    Navigator.of(context).pushNamed(
      AppRoutes.challengeDetails,
      arguments: {
        'challenge': challenge,
        'progress': _progressMap[challenge.id],
      },
    );
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
        title: const Text('Eco Challenges'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor:
              isDark ? AppColors.primaryLight : AppColors.primary,
          labelColor:
              isDark ? AppColors.primaryLight : AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: 'Active (${_activeChallenges.length})'),
            Tab(text: 'Completed (${_completedChallenges.length})'),
            Tab(text: 'Expired (${_expiredChallenges.length})'),
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
        child: LoadingIndicator(message: 'Fetching eco challenges...'),
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
                'Unable to load challenges',
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
                onPressed: _loadChallenges,
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildChallengeList(_activeChallenges, 'active', isDark, isSmall),
        _buildChallengeList(
            _completedChallenges, 'completed', isDark, isSmall),
        _buildChallengeList(_expiredChallenges, 'expired', isDark, isSmall),
      ],
    );
  }

  Widget _buildChallengeList(
    List<ChallengeModel> list,
    String statusTab,
    bool isDark,
    bool isSmall,
  ) {
    if (list.isEmpty) {
      return _buildEmptyTab(statusTab, isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
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
          final challenge = list[index];
          return ChallengeCard(
            challenge: challenge,
            progress: _progressMap[challenge.id],
            onTap: () => _navigateToDetails(challenge),
          );
        },
      ),
    );
  }

  Widget _buildEmptyTab(String statusTab, bool isDark) {
    String title;
    String subtitle;
    IconData icon;

    switch (statusTab) {
      case 'completed':
        icon = Icons.emoji_events_outlined;
        title = 'No completed challenges yet';
        subtitle =
            'Complete ongoing eco challenges to earn special rewards and badges!';
        break;
      case 'expired':
        icon = Icons.history_rounded;
        title = 'No expired challenges';
        subtitle = 'Expired and past environmental events will appear here.';
        break;
      default:
        icon = Icons.flag_outlined;
        title = 'No active challenges available';
        subtitle =
            'New community and personal environmental challenges will appear here.';
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
