import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Reusable styled card container
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardBorderRadius =
        borderRadius ?? BorderRadius.circular(AppConstants.radiusM);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardTheme.color,
        borderRadius: cardBorderRadius,
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: elevation ?? AppConstants.elevationLow,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: cardBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardBorderRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppConstants.paddingM),
            child: child,
          ),
        ),
      ),
    );
  }
}
