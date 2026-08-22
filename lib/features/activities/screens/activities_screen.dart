import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/eco_activity_model.dart';
import '../services/activity_service.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/eco_activity_card.dart';

/// Eco Activities Screen displaying real Firestore activities with search & category filtering
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

  List<EcoActivityModel> _allActivities = [];
  List<EcoActivityModel> _filteredActivities = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

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

  /// Extracts unique categories dynamically from loaded activities
  List<String> get _categories {
    final categoriesSet = <String>{'All'};
    for (final act in _allActivities) {
      if (act.category.isNotEmpty) {
        categoriesSet.add(act.category);
      }
    }
    return categoriesSet.toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
      _applyFilter();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilter();
    });
  }

  void _applyFilter() {
    _filteredActivities = _allActivities.where((activity) {
      // 1. Category Filter
      final matchesCategory = _selectedCategory == 'All' ||
          activity.category.toLowerCase() == _selectedCategory.toLowerCase();

      // 2. Search Query Filter (Title, Description, Category)
      final matchesSearch = _searchQuery.isEmpty ||
          activity.title.toLowerCase().contains(_searchQuery) ||
          activity.description.toLowerCase().contains(_searchQuery) ||
          activity.category.toLowerCase().contains(_searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _navigateToDetails(EcoActivityModel activity) {
    Navigator.of(context).pushNamed(
      AppRoutes.activityDetails,
      arguments: activity,
    );
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
            // Search Input Field
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                AppConstants.paddingS,
                isSmall ? AppConstants.paddingM : AppConstants.paddingL,
                AppConstants.paddingS,
              ),
              child: CustomTextField(
                hintText: 'Search eco activities...',
                controller: _searchController,
                onChanged: _onSearchChanged,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),

            // Dynamic Category Filter Chips
            if (_categories.length > 1) ...[
              CategoryFilterChips(
                categories: _categories,
                selectedCategory: _selectedCategory,
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
    final hasActiveFilter = _searchQuery.isNotEmpty || _selectedCategory != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilter ? Icons.search_off_rounded : Icons.eco_outlined,
              size: 56,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              hasActiveFilter
                  ? 'No matching activities found'
                  : 'No active eco activities available',
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              hasActiveFilter
                  ? 'Try searching with different keywords or clearing your category filter.'
                  : 'New environmental habits and activities will appear here when published.',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasActiveFilter) ...[
              const SizedBox(height: AppConstants.paddingM),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = 'All';
                    _applyFilter();
                  });
                },
                child: const Text('Clear Filters'),
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
              'Unable to load activities',
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              _errorMessage ?? 'Please check your connection and retry.',
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
              onPressed: _loadActivities,
            ),
          ],
        ),
      ),
    );
  }
}
