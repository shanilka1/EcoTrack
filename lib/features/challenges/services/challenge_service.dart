import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';

/// Repository / Service responsible for managing Challenges and Challenge Progress in Cloud Firestore
class ChallengeService {
  final FirebaseFirestore? _customFirestore;

  ChallengeService({FirebaseFirestore? firestore})
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

  CollectionReference<Map<String, dynamic>> get _challengesCollection =>
      _firestore.collection('challenges');

  CollectionReference<Map<String, dynamic>> _userProgressCollection(
          String userId) =>
      _firestore.collection('users').doc(userId).collection('challengeProgress');

  /// Fetches all active challenges from Cloud Firestore
  Future<List<ChallengeModel>> fetchActiveChallenges() async {
    try {
      final querySnapshot = await _challengesCollection
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ChallengeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch challenges from database: $e');
    }
  }

  /// Fetches a specific challenge by ID
  Future<ChallengeModel?> fetchChallengeById(String id) async {
    try {
      final doc = await _challengesCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return ChallengeModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch challenge details: $e');
    }
  }

  /// Streams active challenges in real-time
  Stream<List<ChallengeModel>> streamActiveChallenges() {
    try {
      return _challengesCollection
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ChallengeModel.fromFirestore(doc))
            .toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Retrieves user's progress for a specific challenge
  Future<UserChallengeProgressModel?> getUserChallengeProgress({
    required String userId,
    required String challengeId,
  }) async {
    try {
      final doc =
          await _userProgressCollection(userId).doc(challengeId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserChallengeProgressModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// Retrieves all challenge progress records for a user mapped by challenge ID
  Future<Map<String, UserChallengeProgressModel>> getUserAllChallengeProgress(
      String userId) async {
    try {
      final snapshot = await _userProgressCollection(userId).get();
      final map = <String, UserChallengeProgressModel>{};
      for (final doc in snapshot.docs) {
        final progress = UserChallengeProgressModel.fromFirestore(doc);
        map[progress.challengeId] = progress;
      }
      return map;
    } catch (e) {
      return {};
    }
  }

  /// Streams user's challenge progress in real-time
  Stream<Map<String, UserChallengeProgressModel>> streamUserChallengeProgress(
      String userId) {
    try {
      return _userProgressCollection(userId).snapshots().map((snapshot) {
        final map = <String, UserChallengeProgressModel>{};
        for (final doc in snapshot.docs) {
          final progress = UserChallengeProgressModel.fromFirestore(doc);
          map[progress.challengeId] = progress;
        }
        return map;
      });
    } catch (_) {
      return const Stream.empty();
    }
  }
}
