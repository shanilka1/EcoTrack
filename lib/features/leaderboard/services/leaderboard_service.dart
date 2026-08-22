import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/leaderboard_user_model.dart';

/// Repository / Service responsible for fetching global and periodic leaderboard rankings
class LeaderboardService {
  final FirebaseFirestore? _customFirestore;

  LeaderboardService({FirebaseFirestore? firestore})
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

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Fetches top users sorted by ecoPoints descending with pagination support
  Future<List<LeaderboardUserModel>> fetchOverallLeaderboard({
    int limit = 50,
    DocumentSnapshot? startAfterDoc,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _usersCollection
          .orderBy('ecoPoints', descending: true)
          .limit(limit);

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      final snapshot = await query.get();

      final List<LeaderboardUserModel> list = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        list.add(
          LeaderboardUserModel.fromFirestore(
            doc,
            rank: i + 1,
          ),
        );
      }
      return list;
    } catch (e) {
      throw Exception('Failed to fetch leaderboard from database: $e');
    }
  }

  /// Calculates the specific rank of a given user
  Future<int> fetchUserRank(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists || userDoc.data() == null) {
        return 0;
      }

      final userPoints =
          (userDoc.data()?['ecoPoints'] as num?)?.toInt() ?? 0;

      // Count how many users have strictly more points than current user
      final countQuery = await _usersCollection
          .where('ecoPoints', isGreaterThan: userPoints)
          .count()
          .get();

      return (countQuery.count ?? 0) + 1;
    } catch (e) {
      return 0;
    }
  }

  /// Real-time stream of top users ordered by ecoPoints
  Stream<List<LeaderboardUserModel>> streamOverallLeaderboard({
    int limit = 50,
  }) {
    try {
      return _usersCollection
          .orderBy('ecoPoints', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        final List<LeaderboardUserModel> list = [];
        for (int i = 0; i < snapshot.docs.length; i++) {
          final doc = snapshot.docs[i];
          list.add(
            LeaderboardUserModel.fromFirestore(
              doc,
              rank: i + 1,
            ),
          );
        }
        return list;
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Fetches weekly rankings if available
  Future<List<LeaderboardUserModel>> fetchWeeklyLeaderboard() async {
    // Periodic aggregations will be recorded in backend jobs
    return [];
  }

  /// Fetches monthly rankings if available
  Future<List<LeaderboardUserModel>> fetchMonthlyLeaderboard() async {
    // Periodic aggregations will be recorded in backend jobs
    return [];
  }
}
