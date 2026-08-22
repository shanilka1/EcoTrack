import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';

/// Repository / Service responsible for managing user profiles in Cloud Firestore
class UserService {
  final FirebaseFirestore? _customFirestore;

  UserService({FirebaseFirestore? firestore})
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

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Creates a new user profile document in Firestore `users/{uid}`
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Failed to create user profile in database: $e');
    }
  }

  /// Retrieves the user profile document by UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Updates allowed fields of the user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      // Remove any protected fields to protect data integrity
      final safeData = Map<String, dynamic>.from(data)
        ..remove('role')
        ..remove('ecoPoints')
        ..remove('level')
        ..remove('createdAt')
        ..remove('uid');

      await _usersCollection.doc(uid).update(safeData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Streams real-time updates for a user profile
  Stream<UserModel?> streamUserProfile(String uid) {
    try {
      return _usersCollection.doc(uid).snapshots().map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return null;
        }
        return UserModel.fromFirestore(snapshot);
      });
    } catch (_) {
      return const Stream.empty();
    }
  }
}
