import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../activities/models/eco_activity_model.dart';
import '../../auth/services/auth_service.dart';
import '../services/admin_service.dart';

/// Screen for Administrators to view, create, edit, and deactivate Eco Activities
class ManageActivitiesScreen extends StatefulWidget {
  final AdminService? adminService;
  final AuthService? authService;
  final List<EcoActivityModel>? initialActivities;

  const ManageActivitiesScreen({
    super.key,
    this.adminService,
    this.authService,
    this.initialActivities,
  });

  @override
  State<ManageActivitiesScreen> createState() => _ManageActivitiesScreenState();
}

class _ManageActivitiesScreenState extends State<ManageActivitiesScreen> {
  late final AdminService _adminService;
  late final AuthService _authService;

  List<EcoActivityModel>? _activities;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _adminService = widget.adminService ?? AdminService();
    _authService = widget.authService ?? AuthService();

    if (widget.initialActivities != null) {
      _activities = widget.initialActivities;
      _isLoading = false;
    } else {
      _loadActivities();
    }
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _adminService.fetchAllActivities();
      if (mounted) {
        setState(() {
          _activities = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load activities: $e';
        });
      }
    }
  }

  Future<void> _showActivityFormDialog([EcoActivityModel? existing]) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');
    final pointsController =
        TextEditingController(text: '${existing?.points ?? 20}');
    final benefitController =
        TextEditingController(text: existing?.environmentalBenefit ?? '');
    String selectedCategory = existing?.category ?? 'Waste';
    bool isActive = existing?.isActive ?? true;

    final categories = ['Waste', 'Energy', 'Transport', 'Water', 'Nature'];

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add New Activity' : 'Edit Activity'),
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
                      labelText: 'Activity Title *',
                      hintText: 'e.g., Plant a Tree',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category *'),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedCategory = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: pointsController,
                    decoration: const InputDecoration(
                      labelText: 'Points Awarded *',
                      hintText: 'e.g., 25',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final parsed = int.tryParse(v ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid points value (> 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Detailed instructions for this green action',
                    ),
                    maxLines: 2,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: benefitController,
                    decoration: const InputDecoration(
                      labelText: 'Environmental Benefit',
                      hintText: 'e.g., Absorbs CO2 and provides oxygen',
                    ),
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

                final activity = EcoActivityModel(
                  id: existing?.id ?? '',
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  category: selectedCategory,
                  points: int.parse(pointsController.text.trim()),
                  environmentalBenefit: benefitController.text.trim(),
                  isActive: isActive,
                  createdAt: existing?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                try {
                  await _adminService.saveActivity(activity, adminUid);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop(true);
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error saving: $e')),
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
      _loadActivities();
    }
  }

  Future<void> _toggleActivity(EcoActivityModel activity) async {
    final newStatus = !activity.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newStatus ? 'Activate Activity' : 'Deactivate Activity'),
        content: Text(
          'Are you sure you want to ${newStatus ? "activate" : "deactivate"} "${activity.title}"?',
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
      await _adminService.toggleActivityStatus(
          activity.id, newStatus, adminUid);
      _loadActivities();
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
        title: const Text('Manage Activities'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActivityFormDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Activity'),
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
        child: LoadingIndicator(message: 'Loading activities...'),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _loadActivities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final activities = _activities ?? [];

    if (activities.isEmpty) {
      return const Center(
        child: Text('No activities created yet. Tap + to add one.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActivities,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(
          isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        ),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final act = activities[index];
          return CustomCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: act.isActive
                      ? AppColors.primary.withAlpha(30)
                      : Colors.grey.withAlpha(40),
                  child: Icon(
                    Icons.eco_rounded,
                    color: act.isActive ? AppColors.primary : Colors.grey,
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
                              act.title,
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
                              color: act.isActive
                                  ? AppColors.primary.withAlpha(30)
                                  : Colors.grey.withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              act.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: act.isActive
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${act.category} • +${act.points} pts',
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
                  onPressed: () => _showActivityFormDialog(act),
                ),
                IconButton(
                  icon: Icon(
                    act.isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    size: 20,
                    color: act.isActive ? AppColors.energy : AppColors.primary,
                  ),
                  onPressed: () => _toggleActivity(act),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
