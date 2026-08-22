import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';

/// Professional Dashboard Header showing dynamic greeting, actual user name, notification bell, and avatar menu
class DashboardHeader extends StatelessWidget {
  final String fullName;
  final VoidCallback onLogout;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onNotifications;
  final int unreadNotificationsCount;

  const DashboardHeader({
    super.key,
    required this.fullName,
    required this.onLogout,
    this.onProfile,
    this.onSettings,
    this.onNotifications,
    this.unreadNotificationsCount = 0,
  });

  /// Computes dynamic greeting based on current local time
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  /// Extracts user initials for the avatar badge
  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Greeting and Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getGreeting(),
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fullName.isNotEmpty ? fullName : 'EcoTrack User',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

        const SizedBox(width: AppConstants.paddingS),

        // Notification Bell Icon with Badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                unreadNotificationsCount > 0
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_outlined,
                size: 24,
                color: unreadNotificationsCount > 0
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              tooltip: 'Notifications',
              onPressed: onNotifications,
            ),
            if (unreadNotificationsCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      unreadNotificationsCount > 99
                          ? '99+'
                          : '$unreadNotificationsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 2),

        // User Avatar with Profile/Settings/Logout popup
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'profile') {
              onProfile?.call();
            } else if (value == 'settings') {
              onSettings?.call();
            } else if (value == 'logout') {
              onLogout();
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppConstants.paddingS),
                  Text(
                    'My Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppConstants.paddingS),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(height: 1),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                  SizedBox(width: AppConstants.paddingS),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            width: isSmall ? 38 : 44,
            height: isSmall ? 38 : 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.primaryLight, AppColors.primaryDark]
                    : [AppColors.primary, AppColors.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(fullName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
