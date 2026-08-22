import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Reusable Loading Indicator with optional message
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.paddingM),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
