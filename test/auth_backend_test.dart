import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/core/exceptions/auth_exception.dart';
import 'package:ecotrack/features/auth/models/user_model.dart';
import 'package:ecotrack/features/auth/state/auth_notifier.dart';

void main() {
  group('UserModel Serialization & Domain Logic Tests', () {
    test('UserModel.createDefault initializes default values correctly', () {
      final user = UserModel.createDefault(
        uid: 'user-123',
        fullName: '  Sunil Perera  ',
        email: '  SUNIL@EcoTrack.ORG  ',
      );

      expect(user.uid, 'user-123');
      expect(user.fullName, 'Sunil Perera');
      expect(user.email, 'sunil@ecotrack.org');
      expect(user.role, 'user');
      expect(user.ecoPoints, 0);
      expect(user.level, 1);
      expect(user.createdAt, isA<DateTime>());
    });

    test('UserModel toMap and fromMap serialization maintains fidelity', () {
      final now = DateTime(2026, 8, 22, 10, 0, 0);
      final user = UserModel(
        uid: 'uid-456',
        fullName: 'Kasun Silva',
        email: 'kasun@ecotrack.org',
        role: 'user',
        ecoPoints: 150,
        level: 2,
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['uid'], 'uid-456');
      expect(map['fullName'], 'Kasun Silva');
      expect(map['email'], 'kasun@ecotrack.org');
      expect(map['role'], 'user');
      expect(map['ecoPoints'], 150);
      expect(map['level'], 2);
      expect(map['createdAt'], isA<Timestamp>());

      final deserialized = UserModel.fromMap(map);
      expect(deserialized.uid, user.uid);
      expect(deserialized.fullName, user.fullName);
      expect(deserialized.email, user.email);
      expect(deserialized.role, user.role);
      expect(deserialized.ecoPoints, user.ecoPoints);
      expect(deserialized.level, user.level);
    });

    test('UserModel copyWith creates accurate modified copies', () {
      final original = UserModel.createDefault(
        uid: 'uid-789',
        fullName: 'Nimali Fernando',
        email: 'nimali@ecotrack.org',
      );

      final updated = original.copyWith(
        ecoPoints: 500,
        level: 3,
      );

      expect(updated.uid, original.uid);
      expect(updated.fullName, original.fullName);
      expect(updated.ecoPoints, 500);
      expect(updated.level, 3);
      expect(original.ecoPoints, 0);
    });
  });

  group('AuthException Error Code Mapping Tests', () {
    test('Maps standard Firebase Auth error codes to user-friendly messages', () {
      final wrongPass = AuthException.fromFirebaseAuthException(
        FirebaseAuthException(code: 'wrong-password'),
      );
      expect(wrongPass.message, contains('Incorrect password'));

      final emailInUse = AuthException.fromFirebaseAuthException(
        FirebaseAuthException(code: 'email-already-in-use'),
      );
      expect(emailInUse.message, contains('already exists'));

      final invalidEmail = AuthException.fromFirebaseAuthException(
        FirebaseAuthException(code: 'invalid-email'),
      );
      expect(invalidEmail.message, contains('formatted incorrectly'));

      final weakPass = AuthException.fromFirebaseAuthException(
        FirebaseAuthException(code: 'weak-password'),
      );
      expect(weakPass.message, contains('too weak'));

      final netError = AuthException.fromFirebaseAuthException(
        FirebaseAuthException(code: 'network-request-failed'),
      );
      expect(netError.message, contains('internet connection'));
    });
  });

  group('AuthNotifier State Lifecycle Tests', () {
    test('Initializes with initial status and null user', () {
      // Create a standalone notifier without active firebase connection
      final notifier = AuthNotifier();
      expect(notifier.currentUser, isNull);
      expect(notifier.isAuthenticated, isFalse);
    });
  });
}
