import 'package:firebase_core/firebase_core.dart';

/// Sanitizes technical error messages to prevent exposing internal architecture,
/// stack traces, or raw security rule details to users.
class ErrorSanitizer {
  ErrorSanitizer._();

  /// Converts any exception into a safe, human-readable user message
  static String sanitize(Object? error, {String fallback = 'An unexpected error occurred. Please try again.'}) {
    if (error == null) return fallback;

    final str = error.toString().toLowerCase();

    // 1. Permission Denied / Authorization
    if (str.contains('permission-denied') || str.contains('permission_denied') || str.contains('missing or insufficient permissions')) {
      return 'You do not have permission to perform this action.';
    }

    // 2. Authentication Errors
    if (str.contains('user-not-found') || str.contains('wrong-password') || str.contains('invalid-credential')) {
      return 'Invalid email or password. Please try again.';
    }
    if (str.contains('email-already-in-use')) {
      return 'An account already exists for that email address.';
    }
    if (str.contains('weak-password')) {
      return 'The password provided is too weak. Please use at least 6 characters.';
    }
    if (str.contains('user-disabled')) {
      return 'This user account has been disabled by an administrator.';
    }
    if (str.contains('requires-recent-login')) {
      return 'This operation is sensitive and requires recent authentication. Please log in again.';
    }

    // 3. Network & Connection
    if (str.contains('network-request-failed') || str.contains('unavailable') || str.contains('socketexception')) {
      return 'Network connection issue. Please check your internet connection and try again.';
    }

    // 4. Resource Not Found
    if (str.contains('not-found')) {
      return 'The requested record was not found.';
    }

    // 5. Firebase Exception code mapping
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Access denied. You do not have authorization.';
        case 'unavailable':
          return 'Database service temporarily unavailable. Please retry shortly.';
        case 'deadline-exceeded':
          return 'The operation timed out. Please try again.';
        case 'already-exists':
          return 'A record with this information already exists.';
        default:
          return fallback;
      }
    }

    return fallback;
  }
}
