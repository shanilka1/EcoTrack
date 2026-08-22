import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/exceptions/auth_exception.dart';
import '../models/user_model.dart';
import 'user_service.dart';

/// Service responsible for Firebase Authentication operations
class AuthService {
  final FirebaseAuth? _customFirebaseAuth;
  final UserService _userService;

  AuthService({
    FirebaseAuth? firebaseAuth,
    UserService? userService,
  })  : _customFirebaseAuth = firebaseAuth,
        _userService = userService ?? UserService();

  FirebaseAuth get _firebaseAuth {
    final customAuth = _customFirebaseAuth;
    if (customAuth != null) return customAuth;
    if (Firebase.apps.isEmpty) {
      throw const AuthException(
        'Firebase is not initialized. Please connect your Firebase project configuration.',
      );
    }
    return FirebaseAuth.instance;
  }

  /// Stream of Firebase auth state changes
  Stream<User?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Returns the current Firebase User if logged in
  User? get currentFirebaseUser {
    try {
      return _firebaseAuth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Registers a new user with email and password, then creates their profile in Firestore
  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException(
          'Registration failed: Unable to retrieve created user credentials.',
        );
      }

      // Update Firebase Auth display name
      await user.updateDisplayName(name.trim());

      // Create new user profile document in Firestore
      final newUser = UserModel.createDefault(
        uid: user.uid,
        fullName: name.trim(),
        email: email.trim(),
      );

      await _userService.createUserProfile(newUser);
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'An unexpected error occurred during registration: $e',
      );
    }
  }

  /// Logs in an existing user with email and password and loads their Firestore profile
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException(
          'Login failed: User credentials not found.',
        );
      }

      // Fetch Firestore profile
      final profile = await _userService.getUserProfile(user.uid);
      if (profile != null) {
        return profile;
      }

      // Fallback if profile document does not exist yet
      final fallbackProfile = UserModel.createDefault(
        uid: user.uid,
        fullName: user.displayName ?? email.split('@').first,
        email: user.email ?? email,
      );
      await _userService.createUserProfile(fallbackProfile);
      return fallbackProfile;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'An unexpected error occurred during login: $e',
      );
    }
  }

  /// Sends a password reset email to the given email address
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        'Failed to send password reset email: $e',
      );
    }
  }

  /// Logs the current user out of Firebase
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to log out: $e');
    }
  }

  /// Changes the authenticated user's password with re-authentication
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthException('No authenticated user found.');
    }

    try {
      // Re-authenticate user first for security
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to change password: $e');
    }
  }

  /// Retrieves the current authenticated user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return await _userService.getUserProfile(user.uid);
    } catch (_) {
      return null;
    }
  }
}
