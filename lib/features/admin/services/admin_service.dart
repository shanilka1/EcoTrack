import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../activities/models/eco_activity_model.dart';
import '../../auth/models/user_model.dart';
import '../../challenges/models/challenge_model.dart';
import '../../rewards/models/achievement_model.dart';
import '../models/admin_dashboard_stats_model.dart';
import '../models/announcement_model.dart';

/// Repository / Service managing administrative operations and protected content
class AdminService {
  final FirebaseFirestore? _customFirestore;

  AdminService({FirebaseFirestore? firestore}) : _customFirestore = firestore;

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

  CollectionReference<Map<String, dynamic>> get _activitiesCollection =>
      _firestore.collection('ecoActivities');

  CollectionReference<Map<String, dynamic>> get _challengesCollection =>
      _firestore.collection('challenges');

  CollectionReference<Map<String, dynamic>> get _achievementsCollection =>
      _firestore.collection('achievements');

  CollectionReference<Map<String, dynamic>> get _announcementsCollection =>
      _firestore.collection('announcements');

  /// Verifies if the given user UID possesses the authoritative "admin" role
  Future<bool> checkIsAdmin(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists || doc.data() == null) return false;
      return doc.data()?['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  /// Fetches live system counts for the Admin Dashboard
  Future<AdminDashboardStatsModel> fetchAdminDashboardStats() async {
    try {
      final usersCount = (await _usersCollection.count().get()).count ?? 0;
      final activitiesCount =
          (await _activitiesCollection.count().get()).count ?? 0;
      final activeChallengesCount = (await _challengesCollection
                  .where('isActive', isEqualTo: true)
                  .count()
                  .get())
              .count ??
          0;
      final achievementsCount =
          (await _achievementsCollection.count().get()).count ?? 0;
      final announcementsCount =
          (await _announcementsCollection.count().get()).count ?? 0;

      return AdminDashboardStatsModel(
        totalUsers: usersCount,
        totalActivities: activitiesCount,
        activeChallenges: activeChallengesCount,
        totalAchievements: achievementsCount,
        totalAnnouncements: announcementsCount,
      );
    } catch (e) {
      throw Exception('Failed to fetch admin stats: $e');
    }
  }

  // ==========================================
  // ECO ACTIVITIES MANAGEMENT
  // ==========================================

  Future<List<EcoActivityModel>> fetchAllActivities() async {
    try {
      final snapshot = await _activitiesCollection.get();
      return snapshot.docs
          .map((doc) => EcoActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load activities: $e');
    }
  }

  Future<void> saveActivity(EcoActivityModel activity, String adminUid) async {
    try {
      final isNew = activity.id.isEmpty;
      final docRef = isNew
          ? _activitiesCollection.doc()
          : _activitiesCollection.doc(activity.id);

      final data = {
        'id': docRef.id,
        'title': activity.title.trim(),
        'description': activity.description.trim(),
        'category': activity.category.trim(),
        'points': activity.points,
        'environmentalBenefit': activity.environmentalBenefit.trim(),
        'iconName': activity.iconName,
        'isActive': activity.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminUid,
      };

      if (isNew) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['createdBy'] = adminUid;
      }

      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save activity: $e');
    }
  }

  Future<void> toggleActivityStatus(
      String activityId, bool isActive, String adminUid) async {
    try {
      await _activitiesCollection.doc(activityId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminUid,
      });
    } catch (e) {
      throw Exception('Failed to toggle activity status: $e');
    }
  }

  // ==========================================
  // CHALLENGES MANAGEMENT
  // ==========================================

  Future<List<ChallengeModel>> fetchAllChallenges() async {
    try {
      final snapshot = await _challengesCollection.get();
      return snapshot.docs
          .map((doc) => ChallengeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load challenges: $e');
    }
  }

  Future<void> saveChallenge(ChallengeModel challenge, String adminUid) async {
    try {
      final isNew = challenge.id.isEmpty;
      final docRef = isNew
          ? _challengesCollection.doc()
          : _challengesCollection.doc(challenge.id);

      final data = {
        'id': docRef.id,
        'title': challenge.title.trim(),
        'description': challenge.description.trim(),
        'type': challenge.type,
        'target': challenge.target,
        'targetCategory': challenge.targetCategory,
        'rewardPoints': challenge.rewardPoints,
        'startDate': Timestamp.fromDate(challenge.startDate),
        'endDate': Timestamp.fromDate(challenge.endDate),
        'isActive': challenge.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminUid,
      };

      if (isNew) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['createdBy'] = adminUid;
      }

      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save challenge: $e');
    }
  }

  Future<void> toggleChallengeStatus(
      String challengeId, bool isActive, String adminUid) async {
    try {
      await _challengesCollection.doc(challengeId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminUid,
      });
    } catch (e) {
      throw Exception('Failed to toggle challenge status: $e');
    }
  }

  // ==========================================
  // ACHIEVEMENTS MANAGEMENT
  // ==========================================

  Future<List<AchievementModel>> fetchAllAchievements() async {
    try {
      final snapshot = await _achievementsCollection.get();
      return snapshot.docs
          .map((doc) => AchievementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load achievements: $e');
    }
  }

  Future<void> saveAchievement(
      AchievementModel achievement, String adminUid) async {
    try {
      final isNew = achievement.id.isEmpty;
      final docRef = isNew
          ? _achievementsCollection.doc()
          : _achievementsCollection.doc(achievement.id);

      final data = {
        'id': docRef.id,
        'title': achievement.title.trim(),
        'description': achievement.description.trim(),
        'requirementType': achievement.requirementType,
        'requirementValue': achievement.requirementValue,
        'requirementCategory': achievement.requirementCategory,
        'iconName': achievement.iconName,
        'isActive': achievement.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminUid,
      };

      if (isNew) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['createdBy'] = adminUid;
      }

      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save achievement: $e');
    }
  }

  Future<void> toggleAchievementStatus(
      String achievementId, bool isActive, String adminUid) async {
    try {
      await _achievementsCollection.doc(achievementId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminUid,
      });
    } catch (e) {
      throw Exception('Failed to toggle achievement status: $e');
    }
  }

  // ==========================================
  // USER DIRECTORY (NON-SENSITIVE)
  // ==========================================

  Future<List<UserModel>> fetchUsers({int limit = 50}) async {
    try {
      final snapshot = await _usersCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  // ==========================================
  // ANNOUNCEMENTS MANAGEMENT
  // ==========================================

  Future<List<AnnouncementModel>> fetchAllAnnouncements() async {
    try {
      final snapshot = await _announcementsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load announcements: $e');
    }
  }

  Future<void> saveAnnouncement(
      AnnouncementModel announcement, String adminUid) async {
    try {
      final isNew = announcement.id.isEmpty;
      final docRef = isNew
          ? _announcementsCollection.doc()
          : _announcementsCollection.doc(announcement.id);

      final data = {
        'id': docRef.id,
        'title': announcement.title.trim(),
        'message': announcement.message.trim(),
        'targetAudience': announcement.targetAudience,
        'isActive': announcement.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminUid,
      };

      if (isNew) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['createdBy'] = adminUid;
      }

      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save announcement: $e');
    }
  }

  Future<void> toggleAnnouncementStatus(
      String announcementId, bool isActive, String adminUid) async {
    try {
      await _announcementsCollection.doc(announcementId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminUid,
      });
    } catch (e) {
      throw Exception('Failed to toggle announcement status: $e');
    }
  }
}
