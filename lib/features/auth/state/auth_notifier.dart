import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/exceptions/auth_exception.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStateStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// State notifier managing the user's authentication lifecycle and profile data
class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription? _authSubscription;

  AuthStateStatus _status = AuthStateStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthNotifier({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _initAuthListener();
  }

  AuthStateStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated =>
      _status == AuthStateStatus.authenticated && _currentUser != null;
  bool get isLoading => _status == AuthStateStatus.loading;
  bool get isInitial => _status == AuthStateStatus.initial;

  void _initAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _status = AuthStateStatus.unauthenticated;
        notifyListeners();
      } else {
        try {
          _currentUser = await _authService.getCurrentUserProfile();
          _status = _currentUser != null
              ? AuthStateStatus.authenticated
              : AuthStateStatus.unauthenticated;
        } catch (_) {
          _status = AuthStateStatus.unauthenticated;
        }
        notifyListeners();
      }
    });
  }

  /// Attempts to register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final user = await _authService.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStateStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    }
  }

  /// Attempts to log in an existing user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final user = await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStateStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    }
  }

  /// Sends a password reset email
  Future<bool> sendPasswordReset(String email) async {
    _setLoading();
    try {
      await _authService.sendPasswordResetEmail(email);
      _status = _currentUser != null
          ? AuthStateStatus.authenticated
          : AuthStateStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Password reset failed: $e');
      return false;
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    _setLoading();
    try {
      await _authService.logout();
      _currentUser = null;
      _status = AuthStateStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    }
  }

  /// Clears any existing error message
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading() {
    _status = AuthStateStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStateStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
