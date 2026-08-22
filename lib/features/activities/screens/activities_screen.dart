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
import '../models/activity_filter_model.dart';
import '../models/eco_activity_model.dart';
import '../services/activity_service.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/eco_activity_card.dart';

/// Eco Activities Screen displaying real Firestore activities with live search & multi-facet filtering
class ActivitiesScreen extends StatefulWidget {
  final ActivityService? activityService;
  final List<EcoActivityModel>? initialActivities;

  const ActivitiesScreen({
    super.key,
    this.activityService,
    this.initialActivities,
  });

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  late final ActivityService _activityService;
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 250));

  List<EcoActivityModel> _allActivities = [];
  List<EcoActivityModel> _filteredActivities = [];
  ActivityFilterModel _filter = ActivityFilterModel.initial();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _activityService = widget.activityService ?? ActivityService();

    if (widget.initialActivities != null) {
      _allActivities = widget.initialActivities!;
      _isLoading = false;
      _applyFilter();
    } else {
      _loadActivities();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final activities = await _activityService.fetchActiveActivities();
      if (mounted) {
        setState(() {
          _allActivities = activities;
          _isLoading = false;
          _applyFilter();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load eco activities. Please check your internet connection.';
        });
      }
    }
  }

  /// Extracts unique categories dynamically from loaded backend activities
  List<String> get _categories {
    final categoriesSet = <String>{'All'};
    for (final act in _allActivities) {
      if (act.category.trim().isNotEmpty) {
        categoriesSet.add(act.category.trim());
      }
    }
    return categoriesSet.toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filter = _filter.copyWith(searchQuery: query);
      _applyFilter();
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _filter = _filter.copyWith(searchQuery: '');
      _applyFilter();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _filter = _filter.copyWith(
        selectedCategory: () => category == 'All' ? null : category,
      );
      _applyFilter();
    });
  }

  void _onPointsRangeSelected(PointsRangeFilter range) {
    setState(() {
      _filter = _filter.copyWith(pointsFilter: range);
      _applyFilter();
    });
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _filter = ActivityFilterModel.initial();
      _applyFilter();
    });
  }

  void _applyFilter() {
    _filteredActivities = _filter.apply(_allActivities);
  }

  void _navigateToDetails(EcoActivityModel activity) {
    Navigator.of(context).pushNamed(
      AppRoutes.activityDetails,
      arguments: activity,
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
                          'Filter Activities',
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

                    // Points Range Filter
                    Text(
                      'Points Range',
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
                      children: PointsRangeFilter.values.map((range) {
                        final isSelected = _filter.pointsFilter == range;
                        return ChoiceChip(
                          label: Text(range.label),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            _onPointsRangeSelected(range);
                            setSheetState(() {});
                          },
                        );
                      }).toList(),
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

  List<Widget> _buildActiveFilterChips(bool isDark) {
    final chips = <Widget>[];

    // Category Chip
    if (_filter.selectedCategory != null &&
        _filter.selectedCategory != 'All') {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Chip(
            backgroundColor: AppColors.primary.withAlpha(isDark ? 50 : 30),
            label: Text(
              'Category: ${_filter.selectedCategory}',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            deleteIcon: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
            ),
            onDeleted: () => _onCategorySelected('All'),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
          ),
        ),
      );
    }

    // Points Range Chip
    if (_filter.pointsFilter != PointsRangeFilter.all) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Chip(
            backgroundColor: AppColors.secondary.withAlpha(isDark ? 50 : 30),
            label: Text(
              _filter.pointsFilter.label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            deleteIcon: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.secondary,
            ),
            onDeleted: () =>
                _onPointsRangeSelected(PointsRangeFilter.all),
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
        title: const Text('Eco Activities'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Reusable Search & Filter Bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                AppConstants.paddingS,
                isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                AppConstants.paddingS,
              ),
              child: SearchFilterBar(
                searchController: _searchController,
                hintText: 'Search activities, categories...',
                onSearchChanged: _onSearchChanged,
                onClearSearch: _onClearSearch,
                onFilterTap: _openFilterBottomSheet,
                activeFilterCount: _filter.activeFiltersCount,
                activeFilterChips: _buildActiveFilterChips(isDark),
              ),
            ),

            // Dynamic Category Filter Chips
            if (_categories.length > 1) ...[
              CategoryFilterChips(
                categories: _categories,
                selectedCategory: _filter.selectedCategory ?? 'All',
                onCategorySelected: _onCategorySelected,
              ),
              const SizedBox(height: AppConstants.paddingS),
            ],

            // Content List / Loading / Empty / Error State
            Expanded(
              child: _buildContent(isDark, isSmall),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, bool isSmall) {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Fetching eco activities...'),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark);
    }

    if (_filteredActivities.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadActivities,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.all(
          isSmall ? AppConstants.paddingM : AppConstants.paddingL,
        ),
        itemCount: _filteredActivities.length,
        itemBuilder: (context, index) {
          final activity = _filteredActivities[index];
          return EcoActivityCard(
            activity: activity,
            onTap: () => _navigateToDetails(activity),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _filter.hasActiveFilters
                  ? Icons.search_off_rounded
                  : Icons.eco_outlined,
              size: 56,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              _filter.hasActiveFilters
                  ? 'No matching activities found'
                  : 'No active eco activities available',
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              _filter.hasActiveFilters
                  ? 'Try adjusting your search query or removing active filters.'
                  : 'Check back soon for new eco-friendly actions to complete.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (_filter.hasActiveFilters) ...[
              const SizedBox(height: AppConstants.paddingL),
              CustomButton(
                text: 'Clear Filters',
                width: 180,
                onPressed: _clearAllFilters,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              'Failed to Load Activities',
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
              width: 140,
              onPressed: _loadActivities,
            ),
          ],
        ),
      ),
    );
  }
}
