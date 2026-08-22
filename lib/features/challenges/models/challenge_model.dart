import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain Model for an Environmental Challenge stored in Firestore `challenges/{id}`
class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'activity_count', 'category_activity', 'eco_points', 'streak'
  final int target;
  final String? targetCategory;
  final int rewardPoints;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.targetCategory,
    required this.rewardPoints,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Checks if the challenge is currently ongoing based on dates
  bool get isOngoing {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Checks if the challenge has expired
  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(endDate);
  }

  /// Calculates remaining days until challenge expiry
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Converts the ChallengeModel to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'target': target,
      'targetCategory': targetCategory,
      'rewardPoints': rewardPoints,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Creates a ChallengeModel safely from Firestore document data
  factory ChallengeModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? fallback;
      return fallback;
    }

    final now = DateTime.now();

    return ChallengeModel(
      id: map['id'] as String? ?? documentId ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'activity_count',
      target: (map['target'] as num?)?.toInt() ?? 1,
      targetCategory: map['targetCategory'] as String?,
      rewardPoints: (map['rewardPoints'] as num?)?.toInt() ?? 0,
      startDate: parseDate(map['startDate'], now),
      endDate: parseDate(map['endDate'], now.add(const Duration(days: 7))),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: parseDate(map['createdAt'], now),
      updatedAt: map['updatedAt'] != null
          ? parseDate(map['updatedAt'], now)
          : null,
    );
  }

  /// Creates a ChallengeModel from a Firestore DocumentSnapshot
  factory ChallengeModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return ChallengeModel.fromMap(data, documentId: snapshot.id);
  }

  /// Copies model with updated fields
  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? target,
    String? targetCategory,
    int? rewardPoints,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      target: target ?? this.target,
      targetCategory: targetCategory ?? this.targetCategory,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
