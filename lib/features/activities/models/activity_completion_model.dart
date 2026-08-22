import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain Model for a Completed Activity record stored in `users/{uid}/completedActivities/{completionId}`
class ActivityCompletionModel {
  final String id;
  final String activityId;
  final String userId;
  final String activityTitle;
  final String category;
  final int pointsAwarded;
  final DateTime completedAt;
  final String completionDate;

  const ActivityCompletionModel({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.activityTitle,
    required this.category,
    required this.pointsAwarded,
    required this.completedAt,
    required this.completionDate,
  });

  /// Helper to generate a standardized date key `YYYY-MM-DD`
  static String formatDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Helper to generate a deterministic daily completion ID
  static String generateCompletionId(String activityId, DateTime date) {
    return '${activityId}_${formatDateKey(date)}';
  }

  /// Converts the ActivityCompletionModel to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'userId': userId,
      'activityTitle': activityTitle,
      'category': category,
      'pointsAwarded': pointsAwarded,
      'completedAt': Timestamp.fromDate(completedAt),
      'completionDate': completionDate,
    };
  }

  /// Creates an ActivityCompletionModel safely from Firestore document data
  factory ActivityCompletionModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    DateTime parsedCompletedAt;
    final rawCompletedAt = map['completedAt'];
    if (rawCompletedAt is Timestamp) {
      parsedCompletedAt = rawCompletedAt.toDate();
    } else if (rawCompletedAt is String) {
      parsedCompletedAt = DateTime.tryParse(rawCompletedAt) ?? DateTime.now();
    } else {
      parsedCompletedAt = DateTime.now();
    }

    return ActivityCompletionModel(
      id: map['id'] as String? ?? documentId ?? '',
      activityId: map['activityId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      activityTitle: map['activityTitle'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      pointsAwarded: (map['pointsAwarded'] as num?)?.toInt() ?? 0,
      completedAt: parsedCompletedAt,
      completionDate: map['completionDate'] as String? ?? formatDateKey(parsedCompletedAt),
    );
  }

  /// Creates an ActivityCompletionModel from a Firestore DocumentSnapshot
  factory ActivityCompletionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return ActivityCompletionModel.fromMap(data, documentId: snapshot.id);
  }
}

/// Result object returned by the activity completion service
class ActivityCompletionResult {
  final bool isSuccess;
  final int pointsAwarded;
  final int newTotalPoints;
  final int newLevel;
  final bool isAlreadyCompletedToday;
  final String? errorMessage;

  const ActivityCompletionResult({
    required this.isSuccess,
    this.pointsAwarded = 0,
    this.newTotalPoints = 0,
    this.newLevel = 1,
    this.isAlreadyCompletedToday = false,
    this.errorMessage,
  });

  factory ActivityCompletionResult.success({
    required int pointsAwarded,
    required int newTotalPoints,
    required int newLevel,
  }) {
    return ActivityCompletionResult(
      isSuccess: true,
      pointsAwarded: pointsAwarded,
      newTotalPoints: newTotalPoints,
      newLevel: newLevel,
    );
  }

  factory ActivityCompletionResult.alreadyCompleted() {
    return const ActivityCompletionResult(
      isSuccess: false,
      isAlreadyCompletedToday: true,
      errorMessage:
          'You have already completed this activity today. Come back tomorrow to earn more points!',
    );
  }

  factory ActivityCompletionResult.failure(String message) {
    return ActivityCompletionResult(
      isSuccess: false,
      errorMessage: message,
    );
  }
}
