import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/eco_logo.dart';

/// Clean, responsive, and validated Register / Create Account Screen for EcoTrack
class RegisterScreen extends StatefulWidget {
  /// Optional registration submission callback for future auth integration
  final void Function(String name, String email, String password)?
      onRegisterSubmitted;

  /// Optional navigation callback for login screen
  final VoidCallback? onNavigateToLogin;

  const RegisterScreen({
    super.key,
    this.onRegisterSubmitted,
    this.onNavigateToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _termsError = false;
  bool _submittedOnce = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _handleRegister() {
    setState(() {
      _submittedOnce = true;
      _termsError = !_agreeToTerms;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (isFormValid && _agreeToTerms) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Integration point for future Firebase Auth step
      if (widget.onRegisterSubmitted != null) {
        widget.onRegisterSubmitted!(name, email, password);
      } else {
        // Form is valid: show placeholder notice without pretending registration succeeded
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Input validation passed. Account creation will be connected in the Firebase step.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleGoogleSignUp() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Google Sign-Up will be connected in a future development step.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleTermsDetails() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Terms & Conditions details will be available in a future step.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSignIn() {
    if (widget.onNavigateToLogin != null) {
      widget.onNavigateToLogin!();
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);
    final logoSize = isSmall ? 64.0 : 76.0;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            size: 20,
          ),
          onPressed: _handleSignIn,
          tooltip: 'Back to Login',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isSmall
                  ? AppConstants.paddingM
                  : AppConstants.paddingL,
              vertical: AppConstants.paddingS,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                autovalidateMode: _submittedOnce
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo
                    Center(
                      child: EcoLogo(
                        size: logoSize,
                        showGlow: true,
                      ),
                    ),
                    SizedBox(height: isSmall ? 14 : 20),

                    // Heading
                    Text(
                      'Create Account',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: isSmall ? 24 : 28,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingXS + 2),

                    // Supporting Text
                    Text(
                      'Start your journey toward a greener lifestyle.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmall ? 20 : 28),

                    // Full Name Input Field
                    CustomTextField(
                      label: 'Full Name',
                      hintText: 'Enter your full name',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      validator: Validators.validateName,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_emailFocusNode);
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingM),

                    // Email Input Field
                    CustomTextField(
                      label: 'Email',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      validator: Validators.validateEmail,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingM),

                    // Password Input Field
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Create a password (min 6 characters)',
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        onPressed: _togglePasswordVisibility,
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                      ),
                      validator: Validators.validatePassword,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_confirmPasswordFocusNode);
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingM),

                    // Confirm Password Input Field
                    CustomTextField(
                      label: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      obscureText: _obscureConfirmPassword,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(
                        Icons.lock_reset_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
                        tooltip: _obscureConfirmPassword
                            ? 'Show confirm password'
                            : 'Hide confirm password',
                      ),
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      onFieldSubmitted: (_) => _handleRegister(),
                    ),
                    const SizedBox(height: AppConstants.paddingS),

                    // Terms and Conditions Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeToTerms,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (bool? value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                                if (_agreeToTerms) {
                                  _termsError = false;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingS + 2),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                                if (_agreeToTerms) {
                                  _termsError = false;
                                }
                              });
                            },
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'I agree to the ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _handleTermsDetails,
                                  child: Text(
                                    'Terms and Conditions',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Terms error message if unchecked on submit
                    if (_termsError) ...[
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.only(left: 32),
                        child: Text(
                          'You must accept the Terms and Conditions to continue',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: isSmall ? 16 : 24),

                    // Create Account Button
                    CustomButton(
                      text: 'Create Account',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: AppConstants.paddingL),

                    // Divider with "or" label
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingM,
                          ),
                          child: Text(
                            'or',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingL),

                    // Google Sign-Up Button (UI only)
                    CustomButton(
                      text: 'Sign up with Google',
                      type: ButtonType.outlined,
                      backgroundColor:
                          isDark ? AppColors.surfaceDark : Colors.white,
                      borderColor: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      textColor: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      leadingWidget: _buildGoogleIcon(),
                      onPressed: _handleGoogleSignUp,
                    ),
                    SizedBox(height: isSmall ? 20 : 28),

                    // Bottom Sign In Prompt
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleSignIn,
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Clean vector-rendered Google G emblem for the social button
  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Roboto',
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
