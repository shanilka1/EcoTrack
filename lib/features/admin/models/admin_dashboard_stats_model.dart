/// Domain Model representing Aggregated Statistics for the Admin Dashboard
class AdminDashboardStatsModel {
  final int totalUsers;
  final int totalActivities;
  final int activeChallenges;
  final int totalAchievements;
  final int totalAnnouncements;

  const AdminDashboardStatsModel({
    required this.totalUsers,
    required this.totalActivities,
    required this.activeChallenges,
    required this.totalAchievements,
    required this.totalAnnouncements,
  });

  factory AdminDashboardStatsModel.empty() {
    return const AdminDashboardStatsModel(
      totalUsers: 0,
      totalActivities: 0,
      activeChallenges: 0,
      totalAchievements: 0,
      totalAnnouncements: 0,
    );
  }
}
