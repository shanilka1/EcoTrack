import 'package:firebase_auth/firebase_auth.dart';

/// Custom Application Exception for Authentication Errors
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  /// Factory constructor to map FirebaseAuthException error codes to user-friendly messages
  factory AuthException.fromFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthException(
          'The email address is formatted incorrectly.',
          code: e.code,
        );
      case 'user-disabled':
        return AuthException(
          'This user account has been disabled. Please contact support.',
          code: e.code,
        );
      case 'user-not-found':
        return AuthException(
          'No account found with this email address. Please check or sign up.',
          code: e.code,
        );
      case 'wrong-password':
        return AuthException(
          'Incorrect password. Please try again or reset your password.',
          code: e.code,
        );
      case 'invalid-credential':
        return AuthException(
          'Invalid email or password. Please verify your details.',
          code: e.code,
        );
      case 'email-already-in-use':
        return AuthException(
          'An account already exists for this email address. Please sign in.',
          code: e.code,
        );
      case 'operation-not-allowed':
        return AuthException(
          'Email and password sign-in is currently disabled.',
          code: e.code,
        );
      case 'weak-password':
        return AuthException(
          'The password is too weak. Please use at least 6 characters.',
          code: e.code,
        );
      case 'network-request-failed':
        return AuthException(
          'Network connection error. Please check your internet connection and retry.',
          code: e.code,
        );
      case 'too-many-requests':
        return AuthException(
          'Too many unsuccessful attempts. Please wait a moment and try again.',
          code: e.code,
        );
      case 'channel-error':
        return AuthException(
          'Please complete all required fields.',
          code: e.code,
        );
      case 'requires-recent-login':
        return AuthException(
          'Please log in again to continue this sensitive operation.',
          code: e.code,
        );
      default:
        return AuthException(
          e.message ?? 'An unexpected authentication error occurred. Please try again.',
          code: e.code,
        );
    }
  }

  @override
  String toString() => message;
}
