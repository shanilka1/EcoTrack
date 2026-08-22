import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../models/admin_dashboard_stats_model.dart';
import '../services/admin_service.dart';

/// Central Admin Dashboard Screen providing live metrics and management hubs
class AdminDashboardScreen extends StatefulWidget {
  final AdminService? adminService;
  final AuthService? authService;
  final AdminDashboardStatsModel? initialStats;
  final bool? isVerifiedAdmin;

  const AdminDashboardScreen({
    super.key,
    this.adminService,
    this.authService,
    this.initialStats,
    this.isVerifiedAdmin,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminService _adminService;
  late final AuthService _authService;

  AdminDashboardStatsModel? _stats;
  bool _isAdmin = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _adminService = widget.adminService ?? AdminService();
    _authService = widget.authService ?? AuthService();

    if (widget.initialStats != null && widget.isVerifiedAdmin != null) {
      _stats = widget.initialStats;
      _isAdmin = widget.isVerifiedAdmin!;
      _isLoading = false;
    } else {
      _verifyAndLoad();
    }
  }

  Future<void> _verifyAndLoad() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUid = _authService.currentFirebaseUser?.uid;
    if (currentUid == null) {
      setState(() {
        _isLoading = false;
        _isAdmin = false;
        _errorMessage = 'Authentication required. Please sign in as an Administrator.';
      });
      return;
    }

    try {
      final isAdmin = await _adminService.checkIsAdmin(currentUid);
      if (!isAdmin) {
        if (mounted) {
          setState(() {
            _isAdmin = false;
            _isLoading = false;
          });
        }
        return;
      }

      final stats = await _adminService.fetchAdminDashboardStats();

      if (mounted) {
        setState(() {
          _isAdmin = true;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load admin dashboard: $e';
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
        title: const Text('Admin Console'),
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
        child: LoadingIndicator(message: 'Verifying admin authorization...'),
      );
    }

    // Access Denied State for non-admins
    if (!_isAdmin) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppConstants.paddingM),
              Text(
                'Access Denied',
                style: AppTypography.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have administrative privileges to view or manage this console.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Return to App'),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _verifyAndLoad,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final stats = _stats ?? AdminDashboardStatsModel.empty();

    return RefreshIndicator(
      onRefresh: _verifyAndLoad,
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
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(isDark ? 35 : 20),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: AppColors.primary.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Authorized Administrator',
                              style: TextStyle(
                                fontSize: isSmall ? 13 : 14.5,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              'Full platform oversight and real-time content management.',
                              style: TextStyle(
                                fontSize: isSmall ? 11 : 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmall ? 16 : 22),

                // Live Metrics Grid
                Text(
                  'Live System Metrics',
                  style: AppTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Users',
                        value: '${stats.totalUsers}',
                        icon: Icons.people_outline_rounded,
                        color: AppColors.primary,
                        isDark: isDark,
                        isSmall: isSmall,
                      ),
                    ),
                    SizedBox(width: isSmall ? 8 : 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Activities',
                        value: '${stats.totalActivities}',
                        icon: Icons.eco_rounded,
                        color: AppColors.secondary,
                        isDark: isDark,
                        isSmall: isSmall,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmall ? 8 : 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Active Challenges',
                        value: '${stats.activeChallenges}',
                        icon: Icons.flag_outlined,
                        color: AppColors.energy,
                        isDark: isDark,
                        isSmall: isSmall,
                      ),
                    ),
                    SizedBox(width: isSmall ? 8 : 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Achievements',
                        value: '${stats.totalAchievements}',
                        icon: Icons.emoji_events_outlined,
                        color: const Color(0xFFFFA000),
                        isDark: isDark,
                        isSmall: isSmall,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmall ? 20 : 28),

                // Management Sections
                Text(
                  'Management Consoles',
                  style: AppTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),

                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildNavTile(
                        icon: Icons.checklist_rtl_rounded,
                        title: 'Manage Eco Activities',
                        subtitle: 'Create, update, or deactivate green actions',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.adminActivities),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildNavTile(
                        icon: Icons.flag_rounded,
                        title: 'Manage Challenges',
                        subtitle: 'Configure community challenges & rewards',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.adminChallenges),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildNavTile(
                        icon: Icons.emoji_events_rounded,
                        title: 'Manage Achievements',
                        subtitle: 'Define milestone badges and requirements',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.adminAchievements),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildNavTile(
                        icon: Icons.group_outlined,
                        title: 'User Directory',
                        subtitle: 'Inspect registered accounts and standings',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.adminUsers),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildNavTile(
                        icon: Icons.campaign_outlined,
                        title: 'System Announcements',
                        subtitle: 'Broadcast news & platform updates',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.adminAnnouncements),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required bool isSmall,
  }) {
    return CustomCard(
      padding: EdgeInsets.all(
        isSmall ? AppConstants.paddingS + 2 : AppConstants.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: isSmall ? 18 : 22, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headingMedium.copyWith(
              fontSize: isSmall ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              fontSize: isSmall ? 11 : 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11.5,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
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
