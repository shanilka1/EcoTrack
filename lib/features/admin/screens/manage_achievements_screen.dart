import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../../rewards/models/achievement_model.dart';
import '../services/admin_service.dart';

/// Screen for Administrators to define and manage Achievement Badges
class ManageAchievementsScreen extends StatefulWidget {
  final AdminService? adminService;
  final AuthService? authService;
  final List<AchievementModel>? initialAchievements;

  const ManageAchievementsScreen({
    super.key,
    this.adminService,
    this.authService,
    this.initialAchievements,
  });

  @override
  State<ManageAchievementsScreen> createState() =>
      _ManageAchievementsScreenState();
}

class _ManageAchievementsScreenState extends State<ManageAchievementsScreen> {
  late final AdminService _adminService;
  late final AuthService _authService;

  List<AchievementModel>? _achievements;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _adminService = widget.adminService ?? AdminService();
    _authService = widget.authService ?? AuthService();

    if (widget.initialAchievements != null) {
      _achievements = widget.initialAchievements;
      _isLoading = false;
    } else {
      _loadAchievements();
    }
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _adminService.fetchAllAchievements();
      if (mounted) {
        setState(() {
          _achievements = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load achievements: $e';
        });
      }
    }
  }

  Future<void> _showAchievementFormDialog([AchievementModel? existing]) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');
    final reqValController =
        TextEditingController(text: '${existing?.requirementValue ?? 1}');
    String selectedReqType = existing?.requirementType ?? 'activity_count';
    String selectedCategory = existing?.requirementCategory ?? 'Waste';
    bool isActive = existing?.isActive ?? true;

    final categories = ['Waste', 'Energy', 'Transport', 'Water', 'Nature'];

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'New Achievement Badge' : 'Edit Badge'),
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
                      labelText: 'Badge Title *',
                      hintText: 'e.g., Recycling Champion',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReqType,
                    decoration:
                        const InputDecoration(labelText: 'Requirement Type *'),
                    items: const [
                      DropdownMenuItem(
                        value: 'first_activity',
                        child: Text('First Activity Logged'),
                      ),
                      DropdownMenuItem(
                        value: 'activity_count',
                        child: Text('Total Activity Count'),
                      ),
                      DropdownMenuItem(
                        value: 'points_reached',
                        child: Text('Eco Points Threshold'),
                      ),
                      DropdownMenuItem(
                        value: 'category_activity_count',
                        child: Text('Category Activity Count'),
                      ),
                      DropdownMenuItem(
                        value: 'challenges_completed',
                        child: Text('Challenges Completed'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedReqType = val);
                      }
                    },
                  ),
                  if (selectedReqType == 'category_activity_count') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                          labelText: 'Required Category *'),
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedCategory = val);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: reqValController,
                    decoration: const InputDecoration(
                      labelText: 'Requirement Target Value *',
                      hintText: 'e.g., 10 (activities/points)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final parsed = int.tryParse(v ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Must be > 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Badge Description *',
                      hintText: 'e.g., Complete 10 recycling actions',
                    ),
                    maxLines: 2,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Description is required'
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

                final achievement = AchievementModel(
                  id: existing?.id ?? '',
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  requirementType: selectedReqType,
                  requirementValue: int.parse(reqValController.text.trim()),
                  requirementCategory: selectedReqType == 'category_activity_count'
                      ? selectedCategory
                      : null,
                  isActive: isActive,
                  createdAt: existing?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                try {
                  await _adminService.saveAchievement(achievement, adminUid);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop(true);
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error saving achievement: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      _loadAchievements();
    }
  }

  Future<void> _toggleAchievement(AchievementModel achievement) async {
    final newStatus = !achievement.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newStatus ? 'Activate Badge' : 'Deactivate Badge'),
        content: Text(
          'Are you sure you want to ${newStatus ? "activate" : "deactivate"} "${achievement.title}"?',
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
      await _adminService.toggleAchievementStatus(
          achievement.id, newStatus, adminUid);
      _loadAchievements();
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
        title: const Text('Manage Badges'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAchievementFormDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Badge'),
        backgroundColor: const Color(0xFFFFA000),
      ),
      body: SafeArea(
        child: _buildBody(isDark, isSmall),
      ),
    );
  }

  Widget _buildBody(bool isDark, bool isSmall) {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Loading badges...'),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _loadAchievements,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final list = _achievements ?? [];

    if (list.isEmpty) {
      return const Center(
        child: Text('No badges configured. Tap + to create one.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(
          isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        ),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final ach = list[index];
          return CustomCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: ach.isActive
                      ? const Color(0xFFFFA000).withAlpha(30)
                      : Colors.grey.withAlpha(40),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: ach.isActive ? const Color(0xFFFFA000) : Colors.grey,
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
                              ach.title,
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
                              color: ach.isActive
                                  ? AppColors.primary.withAlpha(30)
                                  : Colors.grey.withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ach.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ach.isActive
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Req: ${ach.requirementType} (${ach.requirementValue})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showAchievementFormDialog(ach),
                ),
                IconButton(
                  icon: Icon(
                    ach.isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    size: 20,
                    color: ach.isActive ? AppColors.energy : AppColors.primary,
                  ),
                  onPressed: () => _toggleAchievement(ach),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
