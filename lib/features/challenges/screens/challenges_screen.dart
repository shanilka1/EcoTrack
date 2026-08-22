import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/search_filter_bar.dart';
import '../../auth/services/auth_service.dart';
import '../models/challenge_filter_model.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';
import '../services/challenge_service.dart';
import '../widgets/challenge_card.dart';

/// Challenges Screen displaying real Firestore challenges categorized by status with live search & filtering
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

  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 250));

  List<ChallengeModel> _allChallenges = [];
  Map<String, UserChallengeProgressModel> _progressMap = {};
  ChallengeFilterModel _filter = ChallengeFilterModel.initial();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _challengeService = widget.challengeService ?? ChallengeService();
    _authService = widget.authService ?? AuthService();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    if (widget.initialChallenges != null) {
      _allChallenges = widget.initialChallenges!;
      _progressMap = widget.initialProgressMap ?? {};
      _isLoading = false;
    } else {
      _loadChallenges();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
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
          _allChallenges = challenges;
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

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      if (mounted) {
        setState(() {
          _filter = _filter.copyWith(searchQuery: query);
        });
      }
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _filter = _filter.copyWith(searchQuery: '');
    });
  }

  void _onTypeFilterSelected(String? type) {
    setState(() {
      _filter = _filter.copyWith(typeFilter: () => type == 'all' ? null : type);
    });
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _filter = ChallengeFilterModel.initial();
    });
  }

  List<ChallengeModel> _filterTabList(List<ChallengeModel> source) {
    return _filter.apply(source, userProgressMap: _progressMap);
  }

  List<ChallengeModel> get _activeChallenges {
    final active = _allChallenges.where((c) {
      final prog = _progressMap[c.id];
      final isCompleted = prog?.isCompleted ?? false;
      return !c.isExpired && !isCompleted;
    }).toList();
    return _filterTabList(active);
  }

  List<ChallengeModel> get _completedChallenges {
    final completed = _allChallenges.where((c) {
      final prog = _progressMap[c.id];
      return prog?.isCompleted ?? false;
    }).toList();
    return _filterTabList(completed);
  }

  List<ChallengeModel> get _expiredChallenges {
    final expired = _allChallenges.where((c) {
      final prog = _progressMap[c.id];
      final isCompleted = prog?.isCompleted ?? false;
      return c.isExpired && !isCompleted;
    }).toList();
    return _filterTabList(expired);
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

  void _openFilterBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusL),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Challenges',
                          style: AppTypography.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        if (_filter.hasActiveFilters)
                          TextButton(
                            onPressed: () {
                              _clearAllFilters();
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Reset All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingM),

                    // Challenge Type Filter
                    Text(
                      'Challenge Type',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTypeChip(
                          'All Types',
                          'all',
                          _filter.typeFilter == null ||
                              _filter.typeFilter == 'all',
                          setSheetState,
                          isDark,
                        ),
                        _buildTypeChip(
                          'Activity Count',
                          'activity_count',
                          _filter.typeFilter == 'activity_count',
                          setSheetState,
                          isDark,
                        ),
                        _buildTypeChip(
                          'Category Specific',
                          'category_activity',
                          _filter.typeFilter == 'category_activity',
                          setSheetState,
                          isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingL),

                    CustomButton(
                      text: 'Apply Filters',
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeChip(
    String label,
    String value,
    bool isSelected,
    StateSetter setSheetState,
    bool isDark,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.energy,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight),
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        _onTypeFilterSelected(value);
        setSheetState(() {});
      },
    );
  }

  List<Widget> _buildActiveFilterChips(bool isDark) {
    final chips = <Widget>[];

    // Type Chip
    if (_filter.typeFilter != null && _filter.typeFilter != 'all') {
      final label = _filter.typeFilter == 'activity_count'
          ? 'Type: Activity Count'
          : 'Type: Category Specific';

      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Chip(
            backgroundColor: AppColors.energy.withAlpha(isDark ? 50 : 30),
            label: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.energy,
              ),
            ),
            deleteIcon: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.energy,
            ),
            onDeleted: () => _onTypeFilterSelected('all'),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
          ),
        ),
      );
    }

    // Clear All Action Chip
    if (chips.isNotEmpty) {
      chips.add(
        ActionChip(
          label: const Text(
            'Clear all',
            style: TextStyle(fontSize: 11.5, color: AppColors.error),
          ),
          onPressed: _clearAllFilters,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
        ),
      );
    }

    return chips;
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
        child: Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                AppConstants.paddingS,
                isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                AppConstants.paddingS,
              ),
              child: SearchFilterBar(
                searchController: _searchController,
                hintText: 'Search challenges, types...',
                onSearchChanged: _onSearchChanged,
                onClearSearch: _onClearSearch,
                onFilterTap: _openFilterBottomSheet,
                activeFilterCount: _filter.activeFiltersCount,
                activeFilterChips: _buildActiveFilterChips(isDark),
              ),
            ),

            // Tab Content
            Expanded(
              child: _buildBody(isDark, isSmall),
            ),
          ],
        ),
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
      return _buildEmptyState(statusTab, isDark);
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
          final progress = _progressMap[challenge.id];

          return ChallengeCard(
            challenge: challenge,
            progress: progress,
            onTap: () => _navigateToDetails(challenge),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String statusTab, bool isDark) {
    if (_filter.hasActiveFilters) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(height: AppConstants.paddingM),
              Text(
                'No Matching Challenges',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                'Try adjusting your search query or removing active filters.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              CustomButton(
                text: 'Clear All Filters',
                width: 180,
                onPressed: _clearAllFilters,
              ),
            ],
          ),
        ),
      );
    }

    IconData icon;
    String title;
    String description;

    switch (statusTab) {
      case 'completed':
        icon = Icons.emoji_events_outlined;
        title = 'No Completed Challenges';
        description =
            'Complete active challenges to earn rewards and track achievements.';
        break;
      case 'expired':
        icon = Icons.history_rounded;
        title = 'No Expired Challenges';
        description = 'Past and ended community challenges will appear here.';
        break;
      default:
        icon = Icons.flag_outlined;
        title = 'No Active Challenges';
        description =
            'Check back soon for exciting new environmental challenges.';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
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
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              description,
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
}
