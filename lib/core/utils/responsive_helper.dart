import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Helper utility for handling responsive layouts across mobile screen sizes
class ResponsiveHelper {
  ResponsiveHelper._();

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static Orientation orientation(BuildContext context) =>
      MediaQuery.of(context).orientation;

  static bool isPortrait(BuildContext context) =>
      orientation(context) == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      orientation(context) == Orientation.landscape;

  static bool isSmallMobile(BuildContext context) =>
      screenWidth(context) < 360;

  static bool isMobile(BuildContext context) =>
      screenWidth(context) < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= AppConstants.mobileBreakpoint &&
      screenWidth(context) < AppConstants.tabletBreakpoint;

  /// Returns value based on screen size (small, normal, tablet)
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? smallMobile,
    T? tablet,
  }) {
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    if (isSmallMobile(context) && smallMobile != null) {
      return smallMobile;
    }
    return mobile;
  }
}
