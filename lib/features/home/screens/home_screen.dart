import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/user_service.dart';
import '../../notifications/services/notification_service.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_loading_skeleton.dart';
import '../widgets/eco_points_card.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/level_card.dart';
import '../widgets/quick_action_item.dart';

/// Production-ready Home Dashboard consuming real Firebase & Cloud Firestore user data
class HomeScreen extends StatefulWidget {
  final UserModel? initialUser;
  final AuthService? authService;
  final UserService? userService;
  final NotificationService? notificationService;

  const HomeScreen({
    super.key,
    this.initialUser,
    this.authService,
    this.userService,
    this.notificationService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  late final UserService _userService;
  late final NotificationService _notificationService;

  UserModel? _user;
  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<int>? _unreadSubscription;
  int _unreadCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _userService = widget.userService ?? UserService();
    _notificationService = widget.notificationService ?? NotificationService();

    _user = widget.initialUser;
    _loadUserProfile();
    _initUserStream();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _unreadSubscription?.cancel();
    super.dispose();
  }

  void _initUserStream() {
    final currentFirebaseUser = _authService.currentFirebaseUser;
    final uid = _user?.uid ?? currentFirebaseUser?.uid;
    if (uid != null) {
      _userSubscription = _userService.streamUserProfile(uid).listen(
        (updatedUser) {
          if (updatedUser != null && mounted) {
            setState(() {
              _user = updatedUser;
              _isLoading = false;
            });
          }
        },
        onError: (_) {},
      );

      _unreadSubscription =
          _notificationService.streamUnreadCount(uid).listen(
        (count) {
          if (mounted) {
            setState(() {
              _unreadCount = count;
            });
          }
        },
      );
    }
  }

  Future<void> _loadUserProfile() async {
    final currentFirebaseUser = _authService.currentFirebaseUser;

    if (currentFirebaseUser == null && _user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No active session found. Please sign in again.';
      });
      return;
    }

    final uid = _user?.uid ?? currentFirebaseUser!.uid;

    setState(() {
      _isLoading = _user == null;
      _errorMessage = null;
    });

    try {
      final profile = await _userService.getUserProfile(uid);
      if (mounted) {
        setState(() {
          _user = profile ?? _user;
          _isLoading = false;
          _errorMessage = profile == null && _user == null
              ? 'Unable to load user profile from database.'
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_user == null) {
            _errorMessage =
                'Failed to load user profile. Please check your connection.';
          }
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void _handleQuickAction(String featureName) {
    if (featureName == 'Activities' || featureName == 'Log Activity') {
      Navigator.of(context).pushNamed(AppRoutes.activities);
      return;
    }

    if (featureName == 'Challenges' || featureName == 'Browse Challenges') {
      Navigator.of(context).pushNamed(AppRoutes.challenges);
      return;
    }

    if (featureName == 'Badges' || featureName == 'Achievements') {
      Navigator.of(context).pushNamed(AppRoutes.rewards);
      return;
    }

    if (featureName == 'Leaderboard') {
      Navigator.of(context).pushNamed(AppRoutes.leaderboard);
      return;
    }

    if (featureName == 'Progress' || featureName == 'Statistics') {
      Navigator.of(context).pushNamed(AppRoutes.progress);
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$featureName feature will be connected in a future development step.',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
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
      body: SafeArea(
        child: _buildBody(isDark, isSmall),
      ),
    );
  }

  Widget _buildBody(bool isDark, bool isSmall) {
    if (_isLoading) {
      return const DashboardLoadingSkeleton();
    }

    if (_errorMessage != null && _user == null) {
      return _buildErrorView(isDark, isSmall);
    }

    final user = _user!;

    return RefreshIndicator(
      onRefresh: _loadUserProfile,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall
              ? AppConstants.paddingM
              : AppConstants.paddingL,
          vertical: AppConstants.paddingM,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Dashboard Header (Greeting + User Name from Firestore + Notifications + Avatar/Profile/Settings/Logout)
                DashboardHeader(
                  fullName: user.fullName,
                  unreadNotificationsCount: _unreadCount,
                  onNotifications: () => Navigator.of(context).pushNamed(
                    AppRoutes.notifications,
                  ),
                  onLogout: _handleLogout,
                  onProfile: () => Navigator.of(context).pushNamed(
                    AppRoutes.profile,
                    arguments: user,
                  ),
                  onSettings: () => Navigator.of(context).pushNamed(
                    AppRoutes.settings,
                  ),
                ),
                SizedBox(height: isSmall ? 16 : 24),

                // 2. Prominent Eco Points Card (Real Firestore ecoPoints)
                EcoPointsCard(
                  points: user.ecoPoints,
                  level: user.level,
                ),
                const SizedBox(height: AppConstants.paddingM),

                // 3. Level & Rank Tier Card (Real Firestore level)
                LevelCard(
                  level: user.level,
                  currentPoints: user.ecoPoints,
                ),
                SizedBox(height: isSmall ? 20 : 28),

                // 4. Quick Actions Section
                _buildSectionTitle('Quick Actions', isDark),
                const SizedBox(height: AppConstants.paddingS + 2),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 360;
                    return GridView.count(
                      crossAxisCount: isNarrow ? 2 : 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppConstants.paddingS,
                      crossAxisSpacing: AppConstants.paddingS,
                      childAspectRatio: isNarrow ? 2.1 : 0.95,
                      children: [
                        QuickActionItem(
                          icon: Icons.checklist_rtl_rounded,
                          label: 'Activities',
                          color: AppColors.primary,
                          onTap: () => _handleQuickAction('Activities'),
                        ),
                        QuickActionItem(
                          icon: Icons.emoji_events_outlined,
                          label: 'Challenges',
                          color: AppColors.energy,
                          onTap: () => _handleQuickAction('Challenges'),
                        ),
                        QuickActionItem(
                          icon: Icons.insights_rounded,
                          label: 'Progress',
                          color: AppColors.secondary,
                          onTap: () => _handleQuickAction('Progress'),
                        ),
                        QuickActionItem(
                          icon: Icons.military_tech_outlined,
                          label: 'Badges',
                          color: AppColors.accent,
                          onTap: () => _handleQuickAction('Achievements'),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: isSmall ? 20 : 28),

                // 5. Daily Progress Section (Clean Empty State)
                _buildSectionTitle("Today's Activities", isDark),
                const SizedBox(height: AppConstants.paddingS + 2),
                EmptyStateCard(
                  icon: Icons.spa_outlined,
                  title: 'No activities completed today.',
                  subtitle:
                      'Track daily green actions like recycling, saving energy, and walking to earn points.',
                  actionLabel: 'Log Activity',
                  onAction: () => _handleQuickAction('Log Activity'),
                ),
                SizedBox(height: isSmall ? 20 : 28),

                // 6. Current Challenge Section (Clean Empty State)
                _buildSectionTitle('Active Challenges', isDark),
                const SizedBox(height: AppConstants.paddingS + 2),
                EmptyStateCard(
                  icon: Icons.flag_outlined,
                  title: 'No active challenges.',
                  subtitle:
                      'Join community eco-challenges to boost your impact and level up faster.',
                  actionLabel: 'Browse Challenges',
                  onAction: () => _handleQuickAction('Browse Challenges'),
                ),
                const SizedBox(height: AppConstants.paddingL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.headingMedium.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildErrorView(bool isDark, bool isSmall) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              'Unable to load profile',
              style: AppTypography.headingMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              _errorMessage ?? 'Please check your connection and retry.',
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
              onPressed: _loadUserProfile,
            ),
          ],
        ),
      ),
    );
  }
}
