import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a system-wide Announcement created by Admins
class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String targetAudience;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    this.targetAudience = 'all',
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'targetAudience': targetAudience,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory AnnouncementModel.fromMap(
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

    return AnnouncementModel(
      id: map['id'] as String? ?? documentId ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      targetAudience: map['targetAudience'] as String? ?? 'all',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: parsedCreatedAt,
      createdBy: map['createdBy'] as String? ?? '',
    );
  }

  factory AnnouncementModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return AnnouncementModel.fromMap(data, documentId: snapshot.id);
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? message,
    String? targetAudience,
    bool? isActive,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      targetAudience: targetAudience ?? this.targetAudience,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
