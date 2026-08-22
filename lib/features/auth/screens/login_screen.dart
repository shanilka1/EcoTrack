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

/// Clean, responsive, and validated Login Screen for EcoTrack
class LoginScreen extends StatefulWidget {
  /// Optional login submission callback for future auth integration
  final void Function(String email, String password)? onLoginSubmitted;

  /// Optional navigation callback for register screen
  final VoidCallback? onNavigateToRegister;

  const LoginScreen({
    super.key,
    this.onLoginSubmitted,
    this.onNavigateToRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _submittedOnce = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleLogin() {
    setState(() {
      _submittedOnce = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Integration point for future Firebase Auth step
      if (widget.onLoginSubmitted != null) {
        widget.onLoginSubmitted!(email, password);
      } else {
        // Form is valid: show placeholder notice without pretending authentication succeeded
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Input validation passed. Authentication will be connected in the Firebase step.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password recovery will be connected in a future development step.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleGoogleSignIn() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Google Sign-In will be connected in a future development step.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSignUp() {
    if (widget.onNavigateToRegister != null) {
      widget.onNavigateToRegister!();
    } else {
      // Prepared navigation target toward Register screen
      Navigator.of(context).pushNamed(AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);
    final logoSize = isSmall ? 68.0 : 84.0;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Back',
              )
            : null,
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
                    SizedBox(height: isSmall ? 16 : 24),

                    // Heading
                    Text(
                      'Welcome Back!',
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
                      'Sign in to continue your EcoTrack journey.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmall ? 24 : 32),

                    // Email Input Field
                    CustomTextField(
                      label: 'Email',
                      hintText: 'Enter your email',
                      controller: _emailController,
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
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
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
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: AppConstants.paddingXS),

                    // Forgot Password Action
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingXS,
                            vertical: AppConstants.paddingXS,
                          ),
                        ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmall ? 16 : 24),

                    // Primary Login Button
                    CustomButton(
                      text: 'Sign In',
                      icon: Icons.login_rounded,
                      onPressed: _handleLogin,
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

                    // Google Sign-In Button (UI only)
                    CustomButton(
                      text: 'Continue with Google',
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
                      onPressed: _handleGoogleSignIn,
                    ),
                    SizedBox(height: isSmall ? 24 : 32),

                    // Bottom Sign Up Prompt
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleSignUp,
                          child: Text(
                            'Sign Up',
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
