import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/services/auth_service.dart';
import '../../challenges/models/challenge_model.dart';
import '../services/admin_service.dart';

/// Screen for Administrators to view, create, configure, and deactivate Challenges
class ManageChallengesScreen extends StatefulWidget {
  final AdminService? adminService;
  final AuthService? authService;
  final List<ChallengeModel>? initialChallenges;

  const ManageChallengesScreen({
    super.key,
    this.adminService,
    this.authService,
    this.initialChallenges,
  });

  @override
  State<ManageChallengesScreen> createState() => _ManageChallengesScreenState();
}

class _ManageChallengesScreenState extends State<ManageChallengesScreen> {
  late final AdminService _adminService;
  late final AuthService _authService;

  List<ChallengeModel>? _challenges;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _adminService = widget.adminService ?? AdminService();
    _authService = widget.authService ?? AuthService();

    if (widget.initialChallenges != null) {
      _challenges = widget.initialChallenges;
      _isLoading = false;
    } else {
      _loadChallenges();
    }
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _adminService.fetchAllChallenges();
      if (mounted) {
        setState(() {
          _challenges = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load challenges: $e';
        });
      }
    }
  }

  Future<void> _showChallengeFormDialog([ChallengeModel? existing]) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');
    final targetController =
        TextEditingController(text: '${existing?.target ?? 5}');
    final rewardController =
        TextEditingController(text: '${existing?.rewardPoints ?? 50}');
    String selectedType = existing?.type ?? 'activity_count';
    String selectedCategory = existing?.targetCategory ?? 'Waste';
    bool isActive = existing?.isActive ?? true;

    final categories = ['Waste', 'Energy', 'Transport', 'Water', 'Nature'];

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add Challenge' : 'Edit Challenge'),
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
                      labelText: 'Challenge Title *',
                      hintText: 'e.g., Plastic-Free Week',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Challenge Type *'),
                    items: const [
                      DropdownMenuItem(
                        value: 'activity_count',
                        child: Text('Total Activity Count'),
                      ),
                      DropdownMenuItem(
                        value: 'category_activity',
                        child: Text('Category Specific'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedType = val);
                      }
                    },
                  ),
                  if (selectedType == 'category_activity') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Target Category *'),
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: targetController,
                          decoration: const InputDecoration(
                            labelText: 'Target (Count) *',
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: rewardController,
                          decoration: const InputDecoration(
                            labelText: 'Reward Points *',
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Rules and requirements for participants',
                    ),
                    maxLines: 2,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Is Active', style: TextStyle(fontSize: 14)),
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

                final challenge = ChallengeModel(
                  id: existing?.id ?? '',
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  type: selectedType,
                  target: int.parse(targetController.text.trim()),
                  targetCategory: selectedType == 'category_activity'
                      ? selectedCategory
                      : null,
                  rewardPoints: int.parse(rewardController.text.trim()),
                  startDate: existing?.startDate ?? DateTime.now(),
                  endDate: existing?.endDate ??
                      DateTime.now().add(const Duration(days: 30)),
                  isActive: isActive,
                  createdAt: existing?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                try {
                  await _adminService.saveChallenge(challenge, adminUid);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop(true);
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error saving challenge: $e')),
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
      _loadChallenges();
    }
  }

  Future<void> _toggleChallenge(ChallengeModel challenge) async {
    final newStatus = !challenge.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newStatus ? 'Activate Challenge' : 'Deactivate Challenge'),
        content: Text(
          'Are you sure you want to ${newStatus ? "activate" : "deactivate"} "${challenge.title}"?',
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
      await _adminService.toggleChallengeStatus(
          challenge.id, newStatus, adminUid);
      _loadChallenges();
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
        title: const Text('Manage Challenges'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showChallengeFormDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Challenge'),
        backgroundColor: AppColors.energy,
      ),
      body: SafeArea(
        child: _buildBody(isDark, isSmall),
      ),
    );
  }

  Widget _buildBody(bool isDark, bool isSmall) {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Loading challenges...'),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _loadChallenges,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final challenges = _challenges ?? [];

    if (challenges.isEmpty) {
      return const Center(
        child: Text('No challenges configured. Tap + to create one.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(
          isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        ),
        itemCount: challenges.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final chal = challenges[index];
          return CustomCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: chal.isActive
                      ? AppColors.energy.withAlpha(30)
                      : Colors.grey.withAlpha(40),
                  child: Icon(
                    Icons.flag_rounded,
                    color: chal.isActive ? AppColors.energy : Colors.grey,
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
                              chal.title,
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
                              color: chal.isActive
                                  ? AppColors.primary.withAlpha(30)
                                  : Colors.grey.withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              chal.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: chal.isActive
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Target: ${chal.target} • Reward: +${chal.rewardPoints} pts',
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
                  onPressed: () => _showChallengeFormDialog(chal),
                ),
                IconButton(
                  icon: Icon(
                    chal.isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    size: 20,
                    color: chal.isActive ? AppColors.energy : AppColors.primary,
                  ),
                  onPressed: () => _toggleChallenge(chal),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
