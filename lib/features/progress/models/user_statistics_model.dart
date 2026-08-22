/// Domain Model representing Aggregated User Progress and Environmental Statistics
class UserStatisticsModel {
  final int totalEcoPoints;
  final int level;
  final int totalActivitiesCompleted;
  final int completedChallengesCount;
  final int unlockedAchievementsCount;
  final Map<String, int> weeklyDailyCounts; // 'Mon': 2, 'Tue': 1, ...
  final Map<String, int> weeklyDailyPoints;
  final Map<String, int> categoryCounts; // 'Waste': 5, 'Energy': 2, ...
  final Map<String, double> categoryPercentages; // 'Waste': 0.71, ...
  final Map<String, int> monthlyCounts; // 'Aug 2026': 10, ...

  const UserStatisticsModel({
    required this.totalEcoPoints,
    required this.level,
    required this.totalActivitiesCompleted,
    required this.completedChallengesCount,
    required this.unlockedAchievementsCount,
    required this.weeklyDailyCounts,
    required this.weeklyDailyPoints,
    required this.categoryCounts,
    required this.categoryPercentages,
    required this.monthlyCounts,
  });

  /// Factory for an empty initial state with zeroed values
  factory UserStatisticsModel.empty() {
    return const UserStatisticsModel(
      totalEcoPoints: 0,
      level: 1,
      totalActivitiesCompleted: 0,
      completedChallengesCount: 0,
      unlockedAchievementsCount: 0,
      weeklyDailyCounts: {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      },
      weeklyDailyPoints: {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      },
      categoryCounts: {},
      categoryPercentages: {},
      monthlyCounts: {},
    );
  }

  /// Whether the user has recorded at least one activity
  bool get hasActivity => totalActivitiesCompleted > 0;

  /// Total points earned in the current week
  int get weeklyTotalPoints {
    return weeklyDailyPoints.values.fold(0, (sum, pts) => sum + pts);
  }

  /// Total activities completed in the current week
  int get weeklyTotalActivities {
    return weeklyDailyCounts.values.fold(0, (sum, count) => sum + count);
  }
}
