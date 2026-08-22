import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/notification_model.dart';

/// Repository / Service responsible for managing user notifications in Cloud Firestore
class NotificationService {
  final FirebaseFirestore? _customFirestore;

  NotificationService({FirebaseFirestore? firestore})
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

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  CollectionReference<Map<String, dynamic>> _notificationsCollection(
          String userId) =>
      _userDoc(userId).collection('notifications');

  DocumentReference<Map<String, dynamic>> _preferencesDoc(String userId) =>
      _userDoc(userId).collection('settings').doc('notificationPreferences');

  /// Fetches paginated/limited notifications for a user ordered by timestamp descending
  Future<List<NotificationModel>> fetchNotifications(
    String userId, {
    int limit = 40,
  }) async {
    try {
      final snapshot = await _notificationsCollection(userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Streams real-time notifications for the active user
  Stream<List<NotificationModel>> streamNotifications(
    String userId, {
    int limit = 40,
  }) {
    try {
      return _notificationsCollection(userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => NotificationModel.fromFirestore(doc))
                .toList(),
          );
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Streams real-time unread notification count
  Stream<int> streamUnreadCount(String userId) {
    try {
      return _notificationsCollection(userId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (_) {
      return Stream.value(0);
    }
  }

  /// Marks an individual notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _notificationsCollection(userId)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Marks all unread notifications as read via a Firestore batch
  Future<void> markAllAsRead(String userId) async {
    try {
      final unreadSnapshot = await _notificationsCollection(userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadSnapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in unreadSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Creates a notification idempotently (supports atomic transactions)
  Future<void> createNotification(
    String userId,
    NotificationModel notification, {
    Transaction? transaction,
  }) async {
    final docRef = _notificationsCollection(userId).doc(notification.id);
    if (transaction != null) {
      transaction.set(docRef, notification.toMap(), SetOptions(merge: true));
    } else {
      await docRef.set(notification.toMap(), SetOptions(merge: true));
    }
  }

  /// Fetches user's notification preferences
  Future<Map<String, bool>> fetchNotificationPreferences(String userId) async {
    try {
      final doc = await _preferencesDoc(userId).get();
      if (!doc.exists || doc.data() == null) {
        return {
          'activities': true,
          'challenges': true,
          'achievements': true,
          'general': true,
        };
      }
      final data = doc.data()!;
      return {
        'activities': data['activities'] as bool? ?? true,
        'challenges': data['challenges'] as bool? ?? true,
        'achievements': data['achievements'] as bool? ?? true,
        'general': data['general'] as bool? ?? true,
      };
    } catch (_) {
      return {
        'activities': true,
        'challenges': true,
        'achievements': true,
        'general': true,
      };
    }
  }

  /// Updates user's notification preferences
  Future<void> updateNotificationPreferences(
    String userId,
    Map<String, bool> preferences,
  ) async {
    try {
      await _preferencesDoc(userId).set(
        {
          ...preferences,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to update notification preferences: $e');
    }
  }
}
