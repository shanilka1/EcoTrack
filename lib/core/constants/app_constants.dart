/// Common app-wide constants for dimensions, paddings, and configuration
class AppConstants {
  AppConstants._();

  // Spacing & Paddings
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radii
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 999.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Animation Durations
  static const Duration animDurationShort = Duration(milliseconds: 200);
  static const Duration animDurationMedium = Duration(milliseconds: 350);
  static const Duration animDurationLong = Duration(milliseconds: 500);

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
}
