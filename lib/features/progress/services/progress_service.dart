import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_statistics_model.dart';

/// Repository / Service responsible for aggregating user progress and environmental statistics
class ProgressService {
  final FirebaseFirestore? _customFirestore;

  ProgressService({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore get _firestore {
    final customFirestore = _customFirestore;
    if (customFirestore != null) return customFirestore;
    if (Firebase.apps.isEmpty) {
      throw Exception(
        'Firebase is not initialized. Please connect your Firebase project configuration.',
      );
    }
    return FirebaseFirestore.instance;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  CollectionReference<Map<String, dynamic>> _completionsCollection(
          String userId) =>
      _userDoc(userId).collection('completedActivities');

  CollectionReference<Map<String, dynamic>> _challengeProgressCollection(
          String userId) =>
      _userDoc(userId).collection('challengeProgress');

  CollectionReference<Map<String, dynamic>> _achievementsCollection(
          String userId) =>
      _userDoc(userId).collection('achievements');

  /// Fetches and computes comprehensive user statistics from Cloud Firestore
  Future<UserStatisticsModel> getUserStatistics(String userId) async {
    try {
      final userDoc = await _userDoc(userId).get();
      final currentPoints =
          (userDoc.data()?['ecoPoints'] as num?)?.toInt() ?? 0;
      final currentLevel = (userDoc.data()?['level'] as num?)?.toInt() ?? 1;

      // 1. Fetch completed activities
      final completionsSnapshot = await _completionsCollection(userId)
          .orderBy('completedAt', descending: true)
          .get();

      // 2. Fetch completed challenges count
      final challengesSnapshot = await _challengeProgressCollection(userId)
          .where('status', isEqualTo: 'completed')
          .get();
      final completedChallengesCount = challengesSnapshot.docs.length;

      // 3. Fetch unlocked achievements count
      final achievementsSnapshot =
          await _achievementsCollection(userId).get();
      final unlockedAchievementsCount = achievementsSnapshot.docs.length;

      final totalActivities = completionsSnapshot.docs.length;

      // 4. Calculate Weekly Activity (Mon - Sun for current week)
      final now = DateTime.now();
      // Find Monday of the current week
      final currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
      final monday = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: currentWeekday - 1));

      final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final Map<String, int> weeklyCounts = {
        for (final day in dayLabels) day: 0,
      };
      final Map<String, int> weeklyPoints = {
        for (final day in dayLabels) day: 0,
      };

      // 5. Category distribution
      final Map<String, int> categoryCounts = {};

      // 6. Monthly distribution
      final Map<String, int> monthlyCounts = {};

      const monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];

      for (final doc in completionsSnapshot.docs) {
        final data = doc.data();
        DateTime completionDate = now;

        if (data['completedAt'] is Timestamp) {
          completionDate = (data['completedAt'] as Timestamp).toDate();
        } else if (data['completionDate'] is String) {
          completionDate =
              DateTime.tryParse(data['completionDate'] as String) ?? now;
        }

        final points = (data['pointsAwarded'] as num?)?.toInt() ?? 0;
        final category = data['category'] as String? ?? 'General';

        // Check if completion falls in current week
        final diffDays = completionDate.difference(monday).inDays;
        if (diffDays >= 0 && diffDays < 7) {
          final dayLabel = dayLabels[diffDays];
          weeklyCounts[dayLabel] = (weeklyCounts[dayLabel] ?? 0) + 1;
          weeklyPoints[dayLabel] = (weeklyPoints[dayLabel] ?? 0) + points;
        }

        // Category breakdown
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;

        // Monthly breakdown
        final monthKey = '${monthNames[completionDate.month - 1]} ${completionDate.year}';
        monthlyCounts[monthKey] = (monthlyCounts[monthKey] ?? 0) + 1;
      }

      // Compute category percentages
      final Map<String, double> categoryPercentages = {};
      if (totalActivities > 0) {
        for (final entry in categoryCounts.entries) {
          categoryPercentages[entry.key] = entry.value / totalActivities;
        }
      }

      return UserStatisticsModel(
        totalEcoPoints: currentPoints,
        level: currentLevel,
        totalActivitiesCompleted: totalActivities,
        completedChallengesCount: completedChallengesCount,
        unlockedAchievementsCount: unlockedAchievementsCount,
        weeklyDailyCounts: weeklyCounts,
        weeklyDailyPoints: weeklyPoints,
        categoryCounts: categoryCounts,
        categoryPercentages: categoryPercentages,
        monthlyCounts: monthlyCounts,
      );
    } catch (e) {
      throw Exception('Failed to calculate user statistics: $e');
    }
  }
}
