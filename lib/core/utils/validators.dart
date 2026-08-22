/// Input validation utilities for form fields
class Validators {
  Validators._();

  /// Regular expression for basic email format validation
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$',
  );

  /// Validates a full name input string
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  /// Validates an email input string
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a password input string
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  /// Validates that confirm password matches original password
  static String? validateConfirmPassword(
    String? confirmValue,
    String originalPassword,
  ) {
    if (confirmValue == null || confirmValue.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmValue != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
