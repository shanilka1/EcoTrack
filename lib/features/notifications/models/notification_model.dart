import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification Types supported by EcoTrack
enum NotificationType {
  activityCompleted,
  challengeCompleted,
  achievementUnlocked,
  levelUp,
  pointsAwarded,
  general;

  static NotificationType fromString(String? type) {
    switch (type) {
      case 'activity_completed':
        return NotificationType.activityCompleted;
      case 'challenge_completed':
        return NotificationType.challengeCompleted;
      case 'achievement_unlocked':
        return NotificationType.achievementUnlocked;
      case 'level_up':
        return NotificationType.levelUp;
      case 'points_awarded':
        return NotificationType.pointsAwarded;
      default:
        return NotificationType.general;
    }
  }

  String toDbString() {
    switch (this) {
      case NotificationType.activityCompleted:
        return 'activity_completed';
      case NotificationType.challengeCompleted:
        return 'challenge_completed';
      case NotificationType.achievementUnlocked:
        return 'achievement_unlocked';
      case NotificationType.levelUp:
        return 'level_up';
      case NotificationType.pointsAwarded:
        return 'points_awarded';
      case NotificationType.general:
        return 'general';
    }
  }
}

/// Domain Model for User Notifications in `users/{uid}/notifications/{id}`
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  /// Converts the notification model into a Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toDbString(),
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a NotificationModel from a Map / Firestore document data
  factory NotificationModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    DateTime parsedCreatedAt;
    final rawCreatedAt = map['createdAt'];

    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else if (rawCreatedAt is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return NotificationModel(
      id: map['id'] as String? ?? documentId ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      type: NotificationType.fromString(map['type'] as String?),
      relatedId: map['relatedId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: parsedCreatedAt,
    );
  }

  /// Creates a NotificationModel from a Firestore DocumentSnapshot
  factory NotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return NotificationModel.fromMap(data, documentId: snapshot.id);
  }

  /// Creates a copy of the notification model with modified fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    String? relatedId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.relatedId == relatedId &&
        other.isRead == isRead &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      title,
      message,
      type,
      relatedId,
      isRead,
      createdAt,
    );
  }
}
