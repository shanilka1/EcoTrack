import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/utils/level_calculator.dart';
import '../models/activity_completion_model.dart';
import '../models/eco_activity_model.dart';

/// Repository / Service responsible for fetching activities, recording completions,
/// updating eco points, and evaluating challenge and achievement progress atomically.
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

  CollectionReference<Map<String, dynamic>> get _challengesCollection =>
      _firestore.collection('challenges');

  CollectionReference<Map<String, dynamic>> _userChallengeProgressCollection(
          String userId) =>
      _firestore.collection('users').doc(userId).collection('challengeProgress');

  CollectionReference<Map<String, dynamic>> get _achievementsCollection =>
      _firestore.collection('achievements');

  CollectionReference<Map<String, dynamic>> _userAchievementsCollection(
          String userId) =>
      _firestore.collection('users').doc(userId).collection('achievements');

  CollectionReference<Map<String, dynamic>> _userNotificationsCollection(
          String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  /// Default authoritative verified activities fallback for new / unpopulated databases
  static final List<EcoActivityModel> defaultActivities = [
    EcoActivityModel(
      id: 'act_tree_planting',
      title: 'Plant an Indigenous Tree',
      description:
          'Plant a native tree or shrub in your garden or local community space.',
      category: 'Nature',
      points: 50,
      environmentalBenefit: 'Absorbs CO2 and supports local biodiversity.',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    EcoActivityModel(
      id: 'act_compost_food',
      title: 'Compost Kitchen Food Scraps',
      description:
          'Collect fruit and vegetable peels in a compost bin rather than landfill trash.',
      category: 'Waste',
      points: 25,
      environmentalBenefit:
          'Prevents landfill methane emissions and enriches soil.',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    EcoActivityModel(
      id: 'act_bicycle_commute',
      title: 'Bicycle or Walk Commute',
      description:
          'Choose walking or cycling for a trip under 5km instead of driving.',
      category: 'Transport',
      points: 30,
      environmentalBenefit:
          'Zero emissions and reduces urban traffic congestion.',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    EcoActivityModel(
      id: 'act_reusable_bottle',
      title: 'Use Reusable Water Bottle',
      description:
          'Carry your own stainless steel or glass bottle instead of single-use bottles.',
      category: 'Waste',
      points: 15,
      environmentalBenefit:
          'Reduces plastic pollution and manufacturing emissions.',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    EcoActivityModel(
      id: 'act_energy_saving',
      title: 'Turn Off Unused Lights & Appliances',
      description:
          'Switch off lights, fans, and unplug chargers when not in use.',
      category: 'Energy',
      points: 20,
      environmentalBenefit: 'Reduces electricity generation carbon footprint.',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    EcoActivityModel(
      id: 'act_plant_meal',
      title: 'Enjoy a Plant-Based Meal',
      description:
          'Eat a delicious vegetarian or vegan meal for breakfast, lunch, or dinner.',
      category: 'Food',
      points: 35,
      environmentalBenefit:
          'Significantly lower greenhouse gas and water usage footprint.',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  /// Fetches all active eco activities from Cloud Firestore
  Future<List<EcoActivityModel>> fetchActiveActivities() async {
    try {
      final querySnapshot = await _activitiesCollection
          .where('isActive', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return defaultActivities;
      }

      return querySnapshot.docs
          .map((doc) => EcoActivityModel.fromFirestore(doc))
          .toList();
    } catch (_) {
      return defaultActivities;
    }
  }

  /// Fetches a specific activity by its ID
  Future<EcoActivityModel?> fetchActivityById(String id) async {
    try {
      final doc = await _activitiesCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return defaultActivities.where((a) => a.id == id).firstOrNull;
      }
      return EcoActivityModel.fromFirestore(doc);
    } catch (_) {
      return defaultActivities.where((a) => a.id == id).firstOrNull;
    }
  }

  /// Real-time stream of all active eco activities
  Stream<List<EcoActivityModel>> streamActiveActivities() {
    try {
      return _activitiesCollection
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return defaultActivities;
        }
        return snapshot.docs
            .map((doc) => EcoActivityModel.fromFirestore(doc))
            .toList();
      });
    } catch (_) {
      return Stream.value(defaultActivities);
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
  /// Authoritative points, duplicate checks, challenge progressions, and achievements
  /// are evaluated and awarded atomically.
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

      // Pre-fetch active challenges and achievements before the transaction
      final challengesQuery = await _challengesCollection
          .where('isActive', isEqualTo: true)
          .get();

      final achievementsQuery = await _achievementsCollection
          .where('isActive', isEqualTo: true)
          .get();

      final previousCompletionsSnapshot =
          await _userCompletionsCollection(userId).get();
      final previousCompletionsCount = previousCompletionsSnapshot.docs.length;
      final categoryCompletionsCount = previousCompletionsSnapshot.docs
          .where((doc) =>
              (doc.data()['category'] as String?)?.toLowerCase() ==
              activityId.toLowerCase())
          .length;

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

          // 4. Calculate initial activity points
          final basePointsAwarded = activity.points;
          int totalBonusPoints = 0;
          int newlyCompletedChallenges = 0;

          // 5. Create activity completion record
          final completionRecord = ActivityCompletionModel(
            id: completionDocId,
            activityId: activity.id,
            userId: userId,
            activityTitle: activity.title,
            category: activity.category,
            pointsAwarded: basePointsAwarded,
            completedAt: now,
            completionDate: dateKey,
          );

          transaction.set(completionDocRef, completionRecord.toMap());

          // Write activity completion notification
          final notifActivityRef = _userNotificationsCollection(userId)
              .doc('notif_act_$completionDocId');
          transaction.set(
            notifActivityRef,
            {
              'id': 'notif_act_$completionDocId',
              'userId': userId,
              'title': 'Activity Logged: ${activity.title}',
              'message':
                  'Great job! You earned +$basePointsAwarded eco points.',
              'type': 'activity_completed',
              'relatedId': activity.id,
              'isRead': false,
              'createdAt': Timestamp.fromDate(now),
            },
            SetOptions(merge: true),
          );

          // 6. Process ongoing challenges matching this activity
          for (final challengeDoc in challengesQuery.docs) {
            final challengeData = challengeDoc.data();
            final challengeId = challengeDoc.id;
            final type = challengeData['type'] as String? ?? 'activity_count';
            final target = (challengeData['target'] as num?)?.toInt() ?? 1;
            final targetCategory = challengeData['targetCategory'] as String?;
            final rewardPoints =
                (challengeData['rewardPoints'] as num?)?.toInt() ?? 0;

            final startDate = (challengeData['startDate'] is Timestamp)
                ? (challengeData['startDate'] as Timestamp).toDate()
                : now;
            final endDate = (challengeData['endDate'] is Timestamp)
                ? (challengeData['endDate'] as Timestamp).toDate()
                : now.add(const Duration(days: 30));

            // Only process if within valid date window
            if (now.isBefore(startDate) || now.isAfter(endDate)) {
              continue;
            }

            // Check if criteria matches
            bool isMatching = false;
            if (type == 'activity_count') {
              isMatching = true;
            } else if (type == 'category_activity') {
              isMatching = targetCategory == null ||
                  activity.category.toLowerCase() ==
                      targetCategory.toLowerCase();
            }

            if (!isMatching) continue;

            // Read user's progress for this challenge
            final progressDocRef =
                _userChallengeProgressCollection(userId).doc(challengeId);
            final progressSnapshot = await transaction.get(progressDocRef);

            final currentProgress = (progressSnapshot.data()?['progress'] as num?)
                    ?.toInt() ??
                0;
            final isAlreadyClaimed =
                progressSnapshot.data()?['rewardClaimed'] as bool? ?? false;

            final newProgress = currentProgress + 1;
            final isTargetReached = newProgress >= target;

            if (isTargetReached && !isAlreadyClaimed) {
              totalBonusPoints += rewardPoints;
              newlyCompletedChallenges++;
              transaction.set(
                progressDocRef,
                {
                  'challengeId': challengeId,
                  'userId': userId,
                  'progress': newProgress,
                  'target': target,
                  'status': 'completed',
                  'startedAt': progressSnapshot.exists
                      ? (progressSnapshot.data()?['startedAt'] ??
                          Timestamp.fromDate(now))
                      : Timestamp.fromDate(now),
                  'completedAt': Timestamp.fromDate(now),
                  'rewardClaimed': true,
                },
                SetOptions(merge: true),
              );

              // Write Challenge Completion notification
              final chalTitle = challengeData['title'] as String? ?? 'Community Challenge';
              final notifChalRef = _userNotificationsCollection(userId)
                  .doc('notif_chal_${challengeId}_completed');
              transaction.set(
                notifChalRef,
                {
                  'id': 'notif_chal_${challengeId}_completed',
                  'userId': userId,
                  'title': 'Challenge Completed: $chalTitle',
                  'message':
                      'Congratulations! You finished the challenge and earned +$rewardPoints bonus points.',
                  'type': 'challenge_completed',
                  'relatedId': challengeId,
                  'isRead': false,
                  'createdAt': Timestamp.fromDate(now),
                },
                SetOptions(merge: true),
              );
            } else if (!isAlreadyClaimed) {
              transaction.set(
                progressDocRef,
                {
                  'challengeId': challengeId,
                  'userId': userId,
                  'progress': newProgress,
                  'target': target,
                  'status': 'in_progress',
                  'startedAt': progressSnapshot.exists
                      ? (progressSnapshot.data()?['startedAt'] ??
                          Timestamp.fromDate(now))
                      : Timestamp.fromDate(now),
                  'rewardClaimed': false,
                },
                SetOptions(merge: true),
              );
            }
          }

          // 7. Update user profile points and derived level
          final finalAwardedPoints = basePointsAwarded + totalBonusPoints;
          final newTotalPoints = currentPoints + finalAwardedPoints;
          final newLevel = LevelCalculator.calculateLevel(newTotalPoints);
          final oldLevel = (userSnapshot.data()?['level'] as num?)?.toInt() ?? 1;

          transaction.update(userDocRef, {
            'ecoPoints': newTotalPoints,
            'level': newLevel,
          });

          // Write Level Up notification if increased
          if (newLevel > oldLevel) {
            final notifLvlRef = _userNotificationsCollection(userId)
                .doc('notif_lvl_$newLevel');
            transaction.set(
              notifLvlRef,
              {
                'id': 'notif_lvl_$newLevel',
                'userId': userId,
                'title': 'Level Up! Reached Level $newLevel',
                'message':
                    'Milestone unlocked! You have reached Level $newLevel (${LevelCalculator.getTierName(newLevel)}).',
                'type': 'level_up',
                'relatedId': null,
                'isRead': false,
                'createdAt': Timestamp.fromDate(now),
              },
              SetOptions(merge: true),
            );
          }

          // 8. Evaluate eligible achievements atomically
          final totalUserCompletions = previousCompletionsCount + 1;
          final totalCategoryCompletions = categoryCompletionsCount + 1;

          for (final achievementDoc in achievementsQuery.docs) {
            final aData = achievementDoc.data();
            final achievementId = achievementDoc.id;
            final reqType =
                aData['requirementType'] as String? ?? 'activity_count';
            final reqVal = (aData['requirementValue'] as num?)?.toInt() ?? 1;
            final reqCategory = aData['requirementCategory'] as String?;

            final userAchDocRef =
                _userAchievementsCollection(userId).doc(achievementId);
            final userAchSnapshot = await transaction.get(userAchDocRef);

            // If not unlocked yet, check criteria
            if (!userAchSnapshot.exists) {
              bool isEligible = false;
              if (reqType == 'first_activity') {
                isEligible = totalUserCompletions >= 1;
              } else if (reqType == 'activity_count') {
                isEligible = totalUserCompletions >= reqVal;
              } else if (reqType == 'points_reached') {
                isEligible = newTotalPoints >= reqVal;
              } else if (reqType == 'category_activity_count') {
                if (reqCategory == null ||
                    activity.category.toLowerCase() ==
                        reqCategory.toLowerCase()) {
                  isEligible = totalCategoryCompletions >= reqVal;
                }
              } else if (reqType == 'challenges_completed') {
                isEligible = newlyCompletedChallenges >= reqVal;
              }

              if (isEligible) {
                transaction.set(userAchDocRef, {
                  'achievementId': achievementId,
                  'userId': userId,
                  'unlockedAt': Timestamp.fromDate(now),
                  'status': 'unlocked',
                  'rewardPointsAwarded': 0,
                });

                // Write Achievement notification
                final aTitle = aData['title'] as String? ?? 'New Badge';
                final notifAchRef = _userNotificationsCollection(userId)
                    .doc('notif_ach_$achievementId');
                transaction.set(
                  notifAchRef,
                  {
                    'id': 'notif_ach_$achievementId',
                    'userId': userId,
                    'title': 'Badge Unlocked: $aTitle',
                    'message':
                        'Congratulations! You earned the "$aTitle" badge.',
                    'type': 'achievement_unlocked',
                    'relatedId': achievementId,
                    'isRead': false,
                    'createdAt': Timestamp.fromDate(now),
                  },
                  SetOptions(merge: true),
                );
              }
            }
          }

          return ActivityCompletionResult.success(
            pointsAwarded: finalAwardedPoints,
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
