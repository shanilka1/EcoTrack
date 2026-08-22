import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';

enum ChallengeStatusFilter {
  all,
  active,
  completed,
  expired;

  String get label {
    switch (this) {
      case ChallengeStatusFilter.all:
        return 'All Statuses';
      case ChallengeStatusFilter.active:
        return 'Active';
      case ChallengeStatusFilter.completed:
        return 'Completed';
      case ChallengeStatusFilter.expired:
        return 'Expired';
    }
  }
}

/// Model encapsulating Search & Filtering state for Environmental Challenges
class ChallengeFilterModel {
  final String searchQuery;
  final ChallengeStatusFilter statusFilter;
  final String? typeFilter;

  const ChallengeFilterModel({
    this.searchQuery = '',
    this.statusFilter = ChallengeStatusFilter.all,
    this.typeFilter,
  });

  /// Factory for default initial state
  factory ChallengeFilterModel.initial() {
    return const ChallengeFilterModel();
  }

  /// Whether any active filter or search query is applied
  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      statusFilter != ChallengeStatusFilter.all ||
      (typeFilter != null && typeFilter != 'all');

  /// Counts the total number of active non-search filters
  int get activeFiltersCount {
    int count = 0;
    if (statusFilter != ChallengeStatusFilter.all) count++;
    if (typeFilter != null && typeFilter != 'all') count++;
    return count;
  }

  /// Evaluates whether a single challenge meets search & filter criteria
  bool matches(
    ChallengeModel challenge, {
    UserChallengeProgressModel? progress,
  }) {
    // 1. Search Query filter (matches Title, Description, Type, or Category)
    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      final inTitle = challenge.title.toLowerCase().contains(query);
      final inDesc = challenge.description.toLowerCase().contains(query);
      final inType = challenge.type.toLowerCase().contains(query);
      final inCat =
          (challenge.targetCategory ?? '').toLowerCase().contains(query);

      if (!inTitle && !inDesc && !inType && !inCat) {
        return false;
      }
    }

    // 2. Type Filter
    if (typeFilter != null &&
        typeFilter != 'all' &&
        typeFilter!.isNotEmpty) {
      if (challenge.type.toLowerCase() != typeFilter!.toLowerCase()) {
        return false;
      }
    }

    // 3. Status Filter
    final isCompleted = progress?.isCompleted ?? false;
    final isExpired = challenge.isExpired;
    final isOngoing = challenge.isOngoing;

    switch (statusFilter) {
      case ChallengeStatusFilter.all:
        return true;
      case ChallengeStatusFilter.active:
        return isOngoing && !isCompleted;
      case ChallengeStatusFilter.completed:
        return isCompleted;
      case ChallengeStatusFilter.expired:
        return isExpired && !isCompleted;
    }
  }

  /// Applies filters in-memory to a list of challenges
  List<ChallengeModel> apply(
    List<ChallengeModel> source, {
    Map<String, UserChallengeProgressModel>? userProgressMap,
  }) {
    return source.where((c) {
      final progress = userProgressMap?[c.id];
      return matches(c, progress: progress);
    }).toList();
  }

  ChallengeFilterModel copyWith({
    String? searchQuery,
    ChallengeStatusFilter? statusFilter,
    String? Function()? typeFilter,
  }) {
    return ChallengeFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter != null ? typeFilter() : this.typeFilter,
    );
  }
}
