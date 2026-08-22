import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain Model for a User's Challenge Progress stored in `users/{uid}/challengeProgress/{challengeId}`
class UserChallengeProgressModel {
  final String challengeId;
  final String userId;
  final int progress;
  final int target;
  final String status; // 'in_progress', 'completed', 'expired'
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool rewardClaimed;

  const UserChallengeProgressModel({
    required this.challengeId,
    required this.userId,
    required this.progress,
    required this.target,
    this.status = 'in_progress',
    required this.startedAt,
    this.completedAt,
    this.rewardClaimed = false,
  });

  /// Calculates percentage progress between 0.0 and 1.0
  double get progressPercentage {
    if (target <= 0) return 1.0;
    return (progress / target).clamp(0.0, 1.0);
  }

  /// Whether the challenge requirements are completely met
  bool get isCompleted => status == 'completed' || progress >= target;

  /// Converts model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'progress': progress,
      'target': target,
      'status': status,
      'startedAt': Timestamp.fromDate(startedAt),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'rewardClaimed': rewardClaimed,
    };
  }

  /// Creates a UserChallengeProgressModel safely from Firestore document data
  factory UserChallengeProgressModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? fallback;
      return fallback;
    }

    final now = DateTime.now();

    return UserChallengeProgressModel(
      challengeId: map['challengeId'] as String? ?? documentId ?? '',
      userId: map['userId'] as String? ?? '',
      progress: (map['progress'] as num?)?.toInt() ?? 0,
      target: (map['target'] as num?)?.toInt() ?? 1,
      status: map['status'] as String? ?? 'in_progress',
      startedAt: parseDate(map['startedAt'], now),
      completedAt: map['completedAt'] != null
          ? parseDate(map['completedAt'], now)
          : null,
      rewardClaimed: map['rewardClaimed'] as bool? ?? false,
    );
  }

  /// Creates a UserChallengeProgressModel from a Firestore DocumentSnapshot
  factory UserChallengeProgressModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return UserChallengeProgressModel.fromMap(data, documentId: snapshot.id);
  }

  /// Copies model with updated fields
  UserChallengeProgressModel copyWith({
    String? challengeId,
    String? userId,
    int? progress,
    int? target,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? rewardClaimed,
  }) {
    return UserChallengeProgressModel(
      challengeId: challengeId ?? this.challengeId,
      userId: userId ?? this.userId,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rewardClaimed: rewardClaimed ?? this.rewardClaimed,
    );
  }
}
