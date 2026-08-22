import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../models/announcement_model.dart';
import '../services/admin_service.dart';

/// Screen for Administrators to create and manage system announcements
class ManageAnnouncementsScreen extends StatefulWidget {
  final AdminService? adminService;
  final AuthService? authService;
  final List<AnnouncementModel>? initialAnnouncements;

  const ManageAnnouncementsScreen({
    super.key,
    this.adminService,
    this.authService,
    this.initialAnnouncements,
  });

  @override
  State<ManageAnnouncementsScreen> createState() =>
      _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState extends State<ManageAnnouncementsScreen> {
  late final AdminService _adminService;
  late final AuthService _authService;

  List<AnnouncementModel>? _announcements;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _adminService = widget.adminService ?? AdminService();
    _authService = widget.authService ?? AuthService();

    if (widget.initialAnnouncements != null) {
      _announcements = widget.initialAnnouncements;
      _isLoading = false;
    } else {
      _loadAnnouncements();
    }
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _adminService.fetchAllAnnouncements();
      if (mounted) {
        setState(() {
          _announcements = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load announcements: $e';
        });
      }
    }
  }

  Future<void> _showAnnouncementDialog([AnnouncementModel? existing]) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: existing?.title ?? '');
    final msgController = TextEditingController(text: existing?.message ?? '');
    String audience = existing?.targetAudience ?? 'all';
    bool isActive = existing?.isActive ?? true;

    final audiences = ['all', 'beginners', 'active_users'];

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Broadcast Announcement' : 'Edit Announcement'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Announcement Title *',
                      hintText: 'e.g., Earth Day Community Challenge',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: audience,
                    decoration:
                        const InputDecoration(labelText: 'Target Audience *'),
                    items: audiences
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => audience = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: msgController,
                    decoration: const InputDecoration(
                      labelText: 'Message Body *',
                      hintText: 'Announcement message content',
                    ),
                    maxLines: 3,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Message is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Is Active',
                        style: TextStyle(fontSize: 14)),
                    value: isActive,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setDialogState(() => isActive = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final adminUid =
                    _authService.currentFirebaseUser?.uid ?? 'admin';

                final announcement = AnnouncementModel(
                  id: existing?.id ?? '',
                  title: titleController.text.trim(),
                  message: msgController.text.trim(),
                  targetAudience: audience,
                  isActive: isActive,
                  createdAt: existing?.createdAt ?? DateTime.now(),
                  createdBy: adminUid,
                );

                try {
                  await _adminService.saveAnnouncement(announcement, adminUid);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop(true);
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error saving announcement: $e')),
                    );
                  }
                }
              },
              child: const Text('Publish'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      _loadAnnouncements();
    }
  }

  Future<void> _toggleAnnouncement(AnnouncementModel announcement) async {
    final newStatus = !announcement.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newStatus ? 'Activate Announcement' : 'Deactivate Announcement'),
        content: Text(
          'Are you sure you want to ${newStatus ? "activate" : "deactivate"} "${announcement.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(newStatus ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final adminUid = _authService.currentFirebaseUser?.uid ?? 'admin';
      await _adminService.toggleAnnouncementStatus(
          announcement.id, newStatus, adminUid);
      _loadAnnouncements();
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
        title: const Text('System Announcements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAnnouncementDialog(),
        icon: const Icon(Icons.campaign_rounded),
        label: const Text('New Announcement'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: _buildBody(isDark, isSmall),
      ),
    );
  }

  Widget _buildBody(bool isDark, bool isSmall) {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Loading announcements...'),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _loadAnnouncements,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final list = _announcements ?? [];

    if (list.isEmpty) {
      return const Center(
        child: Text('No announcements published yet. Tap + to create one.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnnouncements,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(
          isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        ),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final ann = list[index];
          return CustomCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: ann.isActive
                      ? AppColors.primary.withAlpha(30)
                      : Colors.grey.withAlpha(40),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: ann.isActive ? AppColors.primary : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              ann.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ann.isActive
                                  ? AppColors.primary.withAlpha(30)
                                  : Colors.grey.withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ann.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ann.isActive
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ann.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showAnnouncementDialog(ann),
                ),
                IconButton(
                  icon: Icon(
                    ann.isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    size: 20,
                    color: ann.isActive ? AppColors.energy : AppColors.primary,
                  ),
                  onPressed: () => _toggleAnnouncement(ann),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
