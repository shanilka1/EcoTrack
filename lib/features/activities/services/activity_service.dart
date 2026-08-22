import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/utils/level_calculator.dart';
import '../models/activity_completion_model.dart';
import '../models/eco_activity_model.dart';

/// Repository / Service responsible for fetching activities, recording completions, and updating eco points atomically
class ActivityService {
  final FirebaseFirestore? _customFirestore;

  ActivityService({FirebaseFirestore? firestore})
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

  CollectionReference<Map<String, dynamic>> get _activitiesCollection =>
      _firestore.collection('ecoActivities');

  CollectionReference<Map<String, dynamic>> _userCompletionsCollection(
          String userId) =>
      _firestore.collection('users').doc(userId).collection('completedActivities');

  /// Fetches all active eco activities from Cloud Firestore
  Future<List<EcoActivityModel>> fetchActiveActivities() async {
    try {
      final querySnapshot = await _activitiesCollection
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => EcoActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch eco activities from database: $e');
    }
  }

  /// Fetches a specific activity by its ID
  Future<EcoActivityModel?> fetchActivityById(String id) async {
    try {
      final doc = await _activitiesCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return EcoActivityModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch activity details: $e');
    }
  }

  /// Real-time stream of all active eco activities
  Stream<List<EcoActivityModel>> streamActiveActivities() {
    try {
      return _activitiesCollection
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => EcoActivityModel.fromFirestore(doc))
            .toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Checks whether an activity has already been completed today by the user
  Future<bool> isActivityCompletedToday({
    required String userId,
    required String activityId,
  }) async {
    try {
      final todayKey = ActivityCompletionModel.formatDateKey(DateTime.now());
      final completionDocId = '${activityId}_$todayKey';

      final doc = await _userCompletionsCollection(userId)
          .doc(completionDocId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Securely completes an activity using an atomic Firestore transaction.
  /// Authoritative points and duplicate checks are enforced on the backend.
  Future<ActivityCompletionResult> completeActivity({
    required String userId,
    required String activityId,
  }) async {
    try {
      final now = DateTime.now();
      final dateKey = ActivityCompletionModel.formatDateKey(now);
      final completionDocId = '${activityId}_$dateKey';

      final activityDocRef = _activitiesCollection.doc(activityId);
      final userDocRef = _firestore.collection('users').doc(userId);
      final completionDocRef =
          _userCompletionsCollection(userId).doc(completionDocId);

      return await _firestore.runTransaction<ActivityCompletionResult>(
        (transaction) async {
          // 1. Read authoritative activity data
          final activitySnapshot = await transaction.get(activityDocRef);
          if (!activitySnapshot.exists || activitySnapshot.data() == null) {
            return ActivityCompletionResult.failure(
              'Activity not found in database.',
            );
          }

          final activity = EcoActivityModel.fromFirestore(activitySnapshot);
          if (!activity.isActive) {
            return ActivityCompletionResult.failure(
              'This activity is currently inactive.',
            );
          }

          // 2. Check duplicate completion for today
          final completionSnapshot = await transaction.get(completionDocRef);
          if (completionSnapshot.exists) {
            return ActivityCompletionResult.alreadyCompleted();
          }

          // 3. Read current user profile
          final userSnapshot = await transaction.get(userDocRef);
          final currentPoints =
              (userSnapshot.data()?['ecoPoints'] as num?)?.toInt() ?? 0;

          // 4. Calculate new points and derived level
          final pointsToAward = activity.points;
          final newTotalPoints = currentPoints + pointsToAward;
          final newLevel = LevelCalculator.calculateLevel(newTotalPoints);

          // 5. Create completion record
          final completionRecord = ActivityCompletionModel(
            id: completionDocId,
            activityId: activity.id,
            userId: userId,
            activityTitle: activity.title,
            category: activity.category,
            pointsAwarded: pointsToAward,
            completedAt: now,
            completionDate: dateKey,
          );

          transaction.set(completionDocRef, completionRecord.toMap());

          // 6. Atomically update user profile points and level
          transaction.update(userDocRef, {
            'ecoPoints': newTotalPoints,
            'level': newLevel,
          });

          return ActivityCompletionResult.success(
            pointsAwarded: pointsToAward,
            newTotalPoints: newTotalPoints,
            newLevel: newLevel,
          );
        },
      );
    } catch (e) {
      return ActivityCompletionResult.failure(
        'Failed to complete activity: $e',
      );
    }
  }

  /// Fetches all completion records for a user
  Future<List<ActivityCompletionModel>> getCompletedActivities(
      String userId) async {
    try {
      final snapshot = await _userCompletionsCollection(userId)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ActivityCompletionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch completion records: $e');
    }
  }

  /// Streams completion records in real-time
  Stream<List<ActivityCompletionModel>> streamCompletedActivities(
      String userId) {
    try {
      return _userCompletionsCollection(userId)
          .orderBy('completedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ActivityCompletionModel.fromFirestore(doc))
            .toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Backward-compatible alias
  Future<bool> prepareActivityCompletion({
    required String userId,
    required String activityId,
  }) async {
    final result = await completeActivity(
      userId: userId,
      activityId: activityId,
    );
    return result.isSuccess;
  }
}
