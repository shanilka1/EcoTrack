import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain Model for an Environmental Achievement / Badge in Firestore `achievements/{id}`
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String requirementType; // 'first_activity', 'activity_count', 'points_reached', 'category_activity_count', 'challenges_completed'
  final int requirementValue;
  final String? requirementCategory;
  final String? iconName;
  final String? badgeColorHex;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requirementType,
    required this.requirementValue,
    this.requirementCategory,
    this.iconName,
    this.badgeColorHex,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Converts the AchievementModel to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requirementType': requirementType,
      'requirementValue': requirementValue,
      'requirementCategory': requirementCategory,
      'iconName': iconName,
      'badgeColorHex': badgeColorHex,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Creates an AchievementModel safely from Firestore document data
  factory AchievementModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? fallback;
      return fallback;
    }

    final now = DateTime.now();

    return AchievementModel(
      id: map['id'] as String? ?? documentId ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      requirementType: map['requirementType'] as String? ?? 'activity_count',
      requirementValue: (map['requirementValue'] as num?)?.toInt() ?? 1,
      requirementCategory: map['requirementCategory'] as String?,
      iconName: map['iconName'] as String?,
      badgeColorHex: map['badgeColorHex'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: parseDate(map['createdAt'], now),
      updatedAt: map['updatedAt'] != null
          ? parseDate(map['updatedAt'], now)
          : null,
    );
  }

  /// Creates an AchievementModel from a Firestore DocumentSnapshot
  factory AchievementModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return AchievementModel.fromMap(data, documentId: snapshot.id);
  }

  /// Copies model with updated fields
  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? requirementType,
    int? requirementValue,
    String? requirementCategory,
    String? iconName,
    String? badgeColorHex,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requirementType: requirementType ?? this.requirementType,
      requirementValue: requirementValue ?? this.requirementValue,
      requirementCategory: requirementCategory ?? this.requirementCategory,
      iconName: iconName ?? this.iconName,
      badgeColorHex: badgeColorHex ?? this.badgeColorHex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
