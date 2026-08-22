import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain Model for a User's Unlocked Achievement stored in `users/{uid}/achievements/{achievementId}`
class UserAchievementModel {
  final String achievementId;
  final String userId;
  final DateTime unlockedAt;
  final String status; // 'unlocked'
  final int rewardPointsAwarded;

  const UserAchievementModel({
    required this.achievementId,
    required this.userId,
    required this.unlockedAt,
    this.status = 'unlocked',
    this.rewardPointsAwarded = 0,
  });

  /// Converts model to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'userId': userId,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'status': status,
      'rewardPointsAwarded': rewardPointsAwarded,
    };
  }

  /// Creates a UserAchievementModel safely from Firestore document data
  factory UserAchievementModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? fallback;
      return fallback;
    }

    return UserAchievementModel(
      achievementId: map['achievementId'] as String? ?? documentId ?? '',
      userId: map['userId'] as String? ?? '',
      unlockedAt: parseDate(map['unlockedAt'], DateTime.now()),
      status: map['status'] as String? ?? 'unlocked',
      rewardPointsAwarded:
          (map['rewardPointsAwarded'] as num?)?.toInt() ?? 0,
    );
  }

  /// Creates a UserAchievementModel from a Firestore DocumentSnapshot
  factory UserAchievementModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return UserAchievementModel.fromMap(data, documentId: snapshot.id);
  }
}
