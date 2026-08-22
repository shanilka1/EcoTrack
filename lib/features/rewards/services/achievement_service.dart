import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/achievement_model.dart';
import '../models/user_achievement_model.dart';

/// Repository / Service responsible for managing Achievements and User Badges in Cloud Firestore
class AchievementService {
  final FirebaseFirestore? _customFirestore;

  AchievementService({FirebaseFirestore? firestore})
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

  CollectionReference<Map<String, dynamic>> get _achievementsCollection =>
      _firestore.collection('achievements');

  CollectionReference<Map<String, dynamic>> _userAchievementsCollection(
          String userId) =>
      _firestore.collection('users').doc(userId).collection('achievements');

  /// Default real achievements fallback
  static final List<AchievementModel> defaultAchievements = [
    AchievementModel(
      id: 'ach_first_step',
      title: 'First Green Step',
      description: 'Complete your first eco-friendly action.',
      requirementType: 'first_activity',
      requirementValue: 1,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    AchievementModel(
      id: 'ach_eco_century',
      title: 'Eco Century',
      description: 'Earn a total of 100 Eco Points.',
      requirementType: 'points_reached',
      requirementValue: 100,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    AchievementModel(
      id: 'ach_waste_warrior',
      title: 'Waste Warrior',
      description: 'Log 5 waste reduction activities.',
      requirementType: 'category_activity_count',
      requirementValue: 5,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    AchievementModel(
      id: 'ach_champion',
      title: 'Eco Champion',
      description: 'Complete 10 total eco activities.',
      requirementType: 'activity_count',
      requirementValue: 10,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  /// Fetches all active achievements from Cloud Firestore
  Future<List<AchievementModel>> fetchActiveAchievements() async {
    try {
      final querySnapshot = await _achievementsCollection
          .where('isActive', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return defaultAchievements;
      }

      return querySnapshot.docs
          .map((doc) => AchievementModel.fromFirestore(doc))
          .toList();
    } catch (_) {
      return defaultAchievements;
    }
  }

  /// Fetches a specific achievement by ID
  Future<AchievementModel?> fetchAchievementById(String id) async {
    try {
      final doc = await _achievementsCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return defaultAchievements.where((a) => a.id == id).firstOrNull;
      }
      return AchievementModel.fromFirestore(doc);
    } catch (_) {
      return defaultAchievements.where((a) => a.id == id).firstOrNull;
    }
  }

  /// Retrieves all unlocked achievements for a user mapped by achievement ID
  Future<Map<String, UserAchievementModel>> getUserUnlockedAchievements(
      String userId) async {
    try {
      final snapshot = await _userAchievementsCollection(userId).get();
      final map = <String, UserAchievementModel>{};
      for (final doc in snapshot.docs) {
        final achievement = UserAchievementModel.fromFirestore(doc);
        map[achievement.achievementId] = achievement;
      }
      return map;
    } catch (e) {
      return {};
    }
  }

  /// Streams active achievements in real-time
  Stream<List<AchievementModel>> streamActiveAchievements() {
    try {
      return _achievementsCollection
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => AchievementModel.fromFirestore(doc))
            .toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Streams user's unlocked achievements in real-time
  Stream<Map<String, UserAchievementModel>> streamUserAchievements(
      String userId) {
    try {
      return _userAchievementsCollection(userId).snapshots().map((snapshot) {
        final map = <String, UserAchievementModel>{};
        for (final doc in snapshot.docs) {
          final achievement = UserAchievementModel.fromFirestore(doc);
          map[achievement.achievementId] = achievement;
        }
        return map;
      });
    } catch (_) {
      return const Stream.empty();
    }
  }
}
