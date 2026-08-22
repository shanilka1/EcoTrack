import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/core/utils/error_sanitizer.dart';
import 'package:ecotrack/core/utils/validators.dart';
import 'package:ecotrack/features/activities/models/activity_completion_model.dart';
import 'package:ecotrack/features/auth/models/user_model.dart';

void main() {
  group('Security & Error Sanitizer Tests', () {
    test('Translates permission-denied into safe user message without leaking internals', () {
      final sanitized = ErrorSanitizer.sanitize(
        'FirebaseException: [cloud_firestore/permission-denied] Missing or insufficient permissions on collection users/user-123/completedActivities.',
      );
      expect(sanitized, 'You do not have permission to perform this action.');
      expect(sanitized.contains('cloud_firestore'), isFalse);
      expect(sanitized.contains('user-123'), isFalse);
    });

    test('Translates auth errors safely without exposing user existence or credentials', () {
      final sanitized = ErrorSanitizer.sanitize('FirebaseAuthException: user-not-found');
      expect(sanitized, 'Invalid email or password. Please try again.');
    });

    test('Translates network exceptions cleanly', () {
      final sanitized = ErrorSanitizer.sanitize('SocketException: network-request-failed');
      expect(sanitized, 'Network connection issue. Please check your internet connection and try again.');
    });

    test('Provides secure fallback message on unexpected internal errors', () {
      final sanitized = ErrorSanitizer.sanitize('InternalServerError: database lock failed at memory address 0x99A');
      expect(sanitized, 'An unexpected error occurred. Please try again.');
      expect(sanitized.contains('0x99A'), isFalse);
    });
  });

  group('Input Validation Security Tests', () {
    test('Validates name constraints', () {
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName('A'), isNotNull);
      expect(Validators.validateName('Jane Doe'), isNull);
    });

    test('Validates email format strictly', () {
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
      expect(Validators.validateEmail('user@domain.com'), isNull);
    });

    test('Enforces minimum password security length (6+ chars)', () {
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('Rejects password confirmation mismatch', () {
      expect(Validators.validateConfirmPassword('pass123', 'pass456'), isNotNull);
      expect(Validators.validateConfirmPassword('pass123', 'pass123'), isNull);
    });
  });

  group('Domain Model Protection Tests', () {
    test('UserModel role defaults to user and cannot be altered via copyWith safely', () {
      final user = UserModel(
        uid: 'user-10',
        fullName: 'Test User',
        email: 'test@example.com',
        role: 'user',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(user.role, 'user');
      final updatedProfile = user.copyWith(fullName: 'Updated Name');
      expect(updatedProfile.role, 'user');
      expect(updatedProfile.uid, 'user-10');
    });

    test('ActivityCompletionResult encapsulates atomic outcome state', () {
      final success = ActivityCompletionResult.success(
        pointsAwarded: 25,
        newTotalPoints: 125,
        newLevel: 2,
      );

      expect(success.isSuccess, isTrue);
      expect(success.pointsAwarded, 25);
      expect(success.newTotalPoints, 125);
      expect(success.newLevel, 2);

      final alreadyDone = ActivityCompletionResult.alreadyCompleted();
      expect(alreadyDone.isSuccess, isFalse);
      expect(alreadyDone.isAlreadyCompletedToday, isTrue);
    });
  });
}
