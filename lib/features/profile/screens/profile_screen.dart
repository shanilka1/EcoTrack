import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/level_calculator.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/user_service.dart';
import '../../progress/models/user_statistics_model.dart';
import '../../progress/services/progress_service.dart';

/// User Profile Screen displaying authenticated account information and quick shortcuts
class ProfileScreen extends StatefulWidget {
  final UserModel? initialUser;
  final UserStatisticsModel? initialStats;
  final AuthService? authService;
  final UserService? userService;
  final ProgressService? progressService;

  const ProfileScreen({
    super.key,
    this.initialUser,
    this.initialStats,
    this.authService,
    this.userService,
    this.progressService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthService _authService;
  late final UserService _userService;
  late final ProgressService _progressService;

  UserModel? _user;
  UserStatisticsModel? _stats;
  StreamSubscription<UserModel?>? _userSubscription;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _userService = widget.userService ?? UserService();
    _progressService = widget.progressService ?? ProgressService();

    _user = widget.initialUser;
    _stats = widget.initialStats;

    if (_user != null && _stats != null) {
      _isLoading = false;
    } else {
      _loadProfileData();
    }
    _initUserStream();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _initUserStream() {
    final uid = _authService.currentFirebaseUser?.uid;
    if (uid == null) return;

    try {
      _userSubscription = _userService.streamUserProfile(uid).listen((user) {
        if (user != null && mounted) {
          setState(() {
            _user = user;
          });
        }
      });
    } catch (_) {}
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUid = _authService.currentFirebaseUser?.uid;
    if (currentUid == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No authenticated user found.';
      });
      return;
    }

    try {
      final user = await _userService.getUserProfile(currentUid);
      final stats = await _progressService.getUserStatistics(currentUid);

      if (mounted) {
        setState(() {
          _user = user ?? _user;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load profile data. Please check your connection.';
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to sign out of your EcoTrack account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
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
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(isDark, isSmall),
      ),
    );
  }

  Widget _buildBody(bool isDark, bool isSmall) {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Loading user profile...'),
      );
    }

    if (_errorMessage != null && _user == null) {
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
                'Unable to load profile',
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
            ],
          ),
        ),
      );
    }

    final user = _user;
    final stats = _stats;
    final level = user?.level ?? 1;
    final tierName = LevelCalculator.getTierName(level);

    final initials = (user?.fullName ?? 'Eco Warrior').isNotEmpty
        ? (user?.fullName ?? 'Eco Warrior')
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join()
        : 'U';

    return RefreshIndicator(
      onRefresh: _loadProfileData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.all(
          isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // 1. User Avatar & Info Card
                CustomCard(
                  padding: EdgeInsets.all(
                    isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: isSmall ? 36 : 42,
                        backgroundColor: isDark
                            ? AppColors.surfaceLight.withAlpha(40)
                            : AppColors.borderLight,
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        child: user?.photoUrl == null
                            ? Text(
                                initials,
                                style: TextStyle(
                                  fontSize: isSmall ? 22 : 26,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.fullName ?? 'Eco Warrior',
                        style: AppTypography.headingMedium.copyWith(
                          fontSize: isSmall ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user?.email ?? 'No email found',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: isSmall ? 11.5 : 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(isDark ? 40 : 25),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusCircular,
                          ),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(80),
                          ),
                        ),
                        child: Text(
                          'Level $level • $tierName',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmall ? 14 : 20),

                // 2. Real Stats Summary Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Points',
                        value: '${user?.ecoPoints ?? 0}',
                        icon: Icons.stars_rounded,
                        color: AppColors.energy,
                        isDark: isDark,
                        isSmall: isSmall,
                      ),
                    ),
                    SizedBox(width: isSmall ? 6 : 10),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Activities',
                        value: '${stats?.totalActivitiesCompleted ?? 0}',
                        icon: Icons.checklist_rtl_rounded,
                        color: AppColors.primary,
                        isDark: isDark,
                        isSmall: isSmall,
                      ),
                    ),
                    SizedBox(width: isSmall ? 6 : 10),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Badges',
                        value: '${stats?.unlockedAchievementsCount ?? 0}',
                        icon: Icons.emoji_events_rounded,
                        color: const Color(0xFFFFA000),
                        isDark: isDark,
                        isSmall: isSmall,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmall ? 14 : 20),

                // 3. Quick Actions Menu
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildMenuTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.editProfile),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildMenuTile(
                        icon: Icons.insights_rounded,
                        title: 'My Progress & Stats',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.progress),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildMenuTile(
                        icon: Icons.military_tech_outlined,
                        title: 'Badges & Achievements',
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.rewards),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildMenuTile(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.settings),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmall ? 14 : 20),

                // 4. Logout Card
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onTap: _handleLogout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required bool isSmall,
  }) {
    return CustomCard(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : AppConstants.paddingS,
        vertical: isSmall ? 8 : 12,
      ),
      child: Column(
        children: [
          Icon(icon, size: isSmall ? 16 : 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 10 : 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 52,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}
