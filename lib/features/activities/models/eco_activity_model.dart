import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain Model for an Environmental Action / Habit in Cloud Firestore `ecoActivities/{id}`
class EcoActivityModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int points;
  final String environmentalBenefit;
  final String? iconName;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EcoActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.environmentalBenefit,
    this.iconName,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Converts the EcoActivityModel to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'environmentalBenefit': environmentalBenefit,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Creates an EcoActivityModel safely from a Map / Firestore document data
  factory EcoActivityModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    DateTime parsedCreatedAt;
    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    DateTime? parsedUpdatedAt;
    final rawUpdatedAt = map['updatedAt'];
    if (rawUpdatedAt is Timestamp) {
      parsedUpdatedAt = rawUpdatedAt.toDate();
    } else if (rawUpdatedAt is String) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt);
    }

    return EcoActivityModel(
      id: map['id'] as String? ?? documentId ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      points: (map['points'] as num?)?.toInt() ?? 0,
      environmentalBenefit: map['environmentalBenefit'] as String? ?? '',
      iconName: map['iconName'] as String?,
      imageUrl: map['imageUrl'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  /// Creates an EcoActivityModel from a Firestore DocumentSnapshot
  factory EcoActivityModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return EcoActivityModel.fromMap(data, documentId: snapshot.id);
  }

  /// Copies model with updated fields
  EcoActivityModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? points,
    String? environmentalBenefit,
    String? iconName,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EcoActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      points: points ?? this.points,
      environmentalBenefit: environmentalBenefit ?? this.environmentalBenefit,
      iconName: iconName ?? this.iconName,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EcoActivityModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.points == points &&
        other.environmentalBenefit == environmentalBenefit &&
        other.iconName == iconName &&
        other.imageUrl == imageUrl &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      category,
      points,
      environmentalBenefit,
      iconName,
      imageUrl,
      isActive,
    );
  }
}
