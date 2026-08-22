import '../models/eco_activity_model.dart';

enum PointsRangeFilter {
  all,
  low, // 1 - 20 pts
  medium, // 21 - 50 pts
  high; // 51+ pts

  String get label {
    switch (this) {
      case PointsRangeFilter.all:
        return 'All Points';
      case PointsRangeFilter.low:
        return '1 - 20 pts';
      case PointsRangeFilter.medium:
        return '21 - 50 pts';
      case PointsRangeFilter.high:
        return '50+ pts';
    }
  }

  bool matches(int points) {
    switch (this) {
      case PointsRangeFilter.all:
        return true;
      case PointsRangeFilter.low:
        return points <= 20;
      case PointsRangeFilter.medium:
        return points >= 21 && points <= 50;
      case PointsRangeFilter.high:
        return points > 50;
    }
  }
}

/// Model encapsulating Search & Filtering state for Eco Activities
class ActivityFilterModel {
  final String searchQuery;
  final String? selectedCategory;
  final PointsRangeFilter pointsFilter;

  const ActivityFilterModel({
    this.searchQuery = '',
    this.selectedCategory,
    this.pointsFilter = PointsRangeFilter.all,
  });

  /// Factory for default empty filter state
  factory ActivityFilterModel.initial() {
    return const ActivityFilterModel();
  }

  /// Whether any active filter or search query is applied
  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      (selectedCategory != null && selectedCategory != 'All') ||
      pointsFilter != PointsRangeFilter.all;

  /// Counts the total number of active non-search filters
  int get activeFiltersCount {
    int count = 0;
    if (selectedCategory != null && selectedCategory != 'All') count++;
    if (pointsFilter != PointsRangeFilter.all) count++;
    return count;
  }

  /// Evaluates whether a single activity satisfies all search & filter criteria
  bool matches(EcoActivityModel activity) {
    // 1. Search Query filter (matches Title, Description, or Category)
    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      final inTitle = activity.title.toLowerCase().contains(query);
      final inDesc = activity.description.toLowerCase().contains(query);
      final inCat = activity.category.toLowerCase().contains(query);
      final inBenefit =
          activity.environmentalBenefit.toLowerCase().contains(query);

      if (!inTitle && !inDesc && !inCat && !inBenefit) {
        return false;
      }
    }

    // 2. Category Filter
    if (selectedCategory != null &&
        selectedCategory != 'All' &&
        selectedCategory!.isNotEmpty) {
      if (activity.category.toLowerCase() !=
          selectedCategory!.toLowerCase()) {
        return false;
      }
    }

    // 3. Points Range Filter
    if (!pointsFilter.matches(activity.points)) {
      return false;
    }

    return true;
  }

  /// Applies filters in-memory on a collection of activities
  List<EcoActivityModel> apply(List<EcoActivityModel> source) {
    return source.where(matches).toList();
  }

  /// Creates a copy with modified values
  ActivityFilterModel copyWith({
    String? searchQuery,
    String? Function()? selectedCategory,
    PointsRangeFilter? pointsFilter,
  }) {
    return ActivityFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory != null
          ? selectedCategory()
          : this.selectedCategory,
      pointsFilter: pointsFilter ?? this.pointsFilter,
    );
  }
}
