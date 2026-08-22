import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

enum ButtonType { primary, secondary, outlined, text }

/// Reusable Custom Button supporting multiple variants, loading state, and icons
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 50.0,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ButtonType.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(context, textColor ?? AppColors.primary),
      );
    }

    if (type == ButtonType.outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: backgroundColor ?? AppColors.primary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
          ),
          child: _buildChild(context, textColor ?? AppColors.primary),
        ),
      );
    }

    final Color bgColor = backgroundColor ??
        (type == ButtonType.secondary
            ? AppColors.secondary
            : AppColors.primary);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
        child: _buildChild(context, textColor ?? Colors.white),
      ),
    );
  }

  Widget _buildChild(BuildContext context, Color color) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppConstants.paddingS),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
