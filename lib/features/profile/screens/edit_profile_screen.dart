import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/user_service.dart';

/// Screen allowing the user to update allowed profile fields (Full Name, Photo URL)
class EditProfileScreen extends StatefulWidget {
  final UserModel? initialUser;
  final UserService? userService;
  final AuthService? authService;

  const EditProfileScreen({
    super.key,
    this.initialUser,
    this.userService,
    this.authService,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final UserService _userService;
  late final AuthService _authService;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _photoUrlController;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _userService = widget.userService ?? UserService();
    _authService = widget.authService ?? AuthService();

    _user = widget.initialUser;
    _nameController = TextEditingController(text: _user?.fullName ?? '');
    _photoUrlController = TextEditingController(text: _user?.photoUrl ?? '');

    if (_user == null) {
      _loadUser();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final currentUid = _authService.currentFirebaseUser?.uid;
    if (currentUid == null) return;

    try {
      final user = await _userService.getUserProfile(currentUid);
      if (mounted && user != null) {
        setState(() {
          _user = user;
          _nameController.text = user.fullName;
          _photoUrlController.text = user.photoUrl ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUid = _authService.currentFirebaseUser?.uid;
    if (currentUid == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedName = _nameController.text.trim();
      final updatedPhotoUrl = _photoUrlController.text.trim();

      await _userService.updateUserProfile(
        currentUid,
        {
          'fullName': updatedName,
          'photoUrl': updatedPhotoUrl.isNotEmpty ? updatedPhotoUrl : null,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to update profile: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveHelper.isSmallMobile(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isSmall ? AppConstants.paddingM : AppConstants.paddingL,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingM),
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.paddingM,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(25),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(
                            color: AppColors.error.withAlpha(80),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Profile Photo Preview Card
                    CustomCard(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: isDark
                                ? AppColors.surfaceLight.withAlpha(40)
                                : AppColors.borderLight,
                            backgroundImage: _photoUrlController
                                    .text.trim().isNotEmpty
                                ? NetworkImage(_photoUrlController.text.trim())
                                : null,
                            child: _photoUrlController.text.trim().isEmpty
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 32,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppConstants.paddingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Image',
                                  style: AppTypography.headingSmall.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Enter an image URL below to update your avatar.',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingL),

                    // Full Name Input
                    Text(
                      'Full Name',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Full name cannot be empty.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.paddingM),

                    // Photo URL Input
                    Text(
                      'Profile Image URL (Optional)',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _photoUrlController,
                      hintText: 'https://example.com/avatar.jpg',
                      prefixIcon: const Icon(Icons.image_outlined),
                      keyboardType: TextInputType.url,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: AppConstants.paddingM),

                    // Email Read-Only Information Card
                    CustomCard(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 18,
                            color: AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _user?.email ??
                                      _authService.currentFirebaseUser?.email ??
                                      'Protected Account Email',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingXL),

                    // Save Changes Button
                    CustomButton(
                      text: 'Save Changes',
                      isLoading: _isLoading,
                      onPressed: _handleSave,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
