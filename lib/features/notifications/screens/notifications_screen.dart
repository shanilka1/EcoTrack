import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// Notifications Screen displaying real event-based notifications and alerts
class NotificationsScreen extends StatefulWidget {
  final NotificationService? notificationService;
  final AuthService? authService;
  final List<NotificationModel>? initialNotifications;

  const NotificationsScreen({
    super.key,
    this.notificationService,
    this.authService,
    this.initialNotifications,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationService _notificationService;
  late final AuthService _authService;

  List<NotificationModel>? _notifications;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _notificationService = widget.notificationService ?? NotificationService();
    _authService = widget.authService ?? AuthService();

    if (widget.initialNotifications != null) {
      _notifications = widget.initialNotifications;
      _isLoading = false;
    } else {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUid = _authService.currentFirebaseUser?.uid;
    if (currentUid == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please sign in to view notifications.';
      });
      return;
    }

    try {
      final notifs = await _notificationService.fetchNotifications(currentUid);
      if (mounted) {
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load notifications. Please check your connection.';
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final currentUid = _authService.currentFirebaseUser?.uid;
    if (currentUid == null || _notifications == null) return;

    try {
      await _notificationService.markAllAsRead(currentUid);
      if (mounted) {
        setState(() {
          _notifications = _notifications!
              .map((n) => n.copyWith(isRead: true))
              .toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    final currentUid = _authService.currentFirebaseUser?.uid;

    // Mark as read in background
    if (!notification.isRead && currentUid != null) {
      _notificationService.markAsRead(currentUid, notification.id);
      setState(() {
        final index =
            _notifications?.indexWhere((n) => n.id == notification.id) ?? -1;
        if (index != -1 && _notifications != null) {
          _notifications![index] = notification.copyWith(isRead: true);
        }
      });
    }

    // Navigate to related feature if applicable
    if (notification.relatedId != null) {
      switch (notification.type) {
        case NotificationType.activityCompleted:
          Navigator.of(context).pushNamed(
            AppRoutes.activityDetails,
            arguments: notification.relatedId,
          );
          break;
        case NotificationType.challengeCompleted:
          Navigator.of(context).pushNamed(
            AppRoutes.challengeDetails,
            arguments: notification.relatedId,
          );
          break;
        case NotificationType.achievementUnlocked:
          Navigator.of(context).pushNamed(AppRoutes.rewards);
          break;
        default:
          break;
      }
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.activityCompleted:
        return Icons.eco_rounded;
      case NotificationType.challengeCompleted:
        return Icons.emoji_events_rounded;
      case NotificationType.achievementUnlocked:
        return Icons.military_tech_rounded;
      case NotificationType.levelUp:
        return Icons.trending_up_rounded;
      case NotificationType.pointsAwarded:
        return Icons.stars_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.activityCompleted:
        return AppColors.primary;
      case NotificationType.challengeCompleted:
        return AppColors.energy;
      case NotificationType.achievementUnlocked:
        return const Color(0xFFFFA000);
      case NotificationType.levelUp:
        return AppColors.secondary;
      case NotificationType.pointsAwarded:
        return AppColors.energy;
      case NotificationType.general:
        return AppColors.primaryLight;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    final hasUnread = _notifications?.any((n) => !n.isRead) ?? false;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (hasUnread)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, size: 22),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
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
        child: LoadingIndicator(message: 'Loading notifications...'),
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
                'Unable to load notifications',
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
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final notifications = _notifications ?? [];

    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNotifications,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.all(
            isSmall ? AppConstants.paddingM : AppConstants.paddingL,
          ),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              'No Notifications Yet',
              textAlign: TextAlign.center,
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              'When you complete activities, achieve milestones, or earn new badges, you will see your updates here.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.all(
          isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        ),
        itemCount: notifications.length,
        separatorBuilder: (_, __) =>
            SizedBox(height: isSmall ? 8 : AppConstants.paddingS + 2),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final color = _getNotificationColor(notif.type);
          final icon = _getNotificationIcon(notif.type);

          return CustomCard(
            padding: EdgeInsets.all(
              isSmall ? AppConstants.paddingM - 2 : AppConstants.paddingM,
            ),
            border: !notif.isRead
                ? Border.all(
                    color: AppColors.primary.withAlpha(isDark ? 100 : 70),
                    width: 1.5,
                  )
                : null,
            child: InkWell(
              onTap: () => _handleNotificationTap(notif),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(isDark ? 40 : 25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: isSmall ? 18 : 20,
                      color: color,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                notif.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSmall ? 13 : 14.5,
                                  fontWeight: notif.isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatTimestamp(notif.createdAt),
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          notif.message,
                          style: TextStyle(
                            fontSize: isSmall ? 11.5 : 12.5,
                            height: 1.35,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Unread Dot
                  if (!notif.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
