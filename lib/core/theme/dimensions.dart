/// App-wide dimension constants for consistent spacing and sizing
/// Following accessibility guidelines with minimum touch targets of 48x48dp
class AppDimensions {
  AppDimensions._();

  // Padding
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Margins
  static const double marginXSmall = 4.0;
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginXLarge = 32.0;

  // Border Radius (soft, friendly design)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;

  // Button Dimensions (accessibility compliant)
  static const double buttonHeight = 48.0;          // Minimum touch target
  static const double buttonMinWidth = 48.0;        // Minimum touch target
  static const double buttonLargeHeight = 56.0;     // For primary actions
  static const double buttonRadius = radiusMedium;

  // Card Dimensions
  static const double cardElevation = 4.0;          // Subtle shadow
  static const double cardRadius = radiusMedium;
  static const double cardPadding = paddingMedium;

  // Icon Sizes (large for accessibility)
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  static const double iconXXLarge = 64.0;

  // Text Field Dimensions
  static const double textFieldHeight = 48.0;
  static const double textFieldRadius = radiusSmall;
  static const double textFieldPadding = paddingMedium;

  // App Bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 2.0;

  // Bottom Navigation
  static const double bottomNavHeight = 56.0;
  static const double bottomNavIconSize = iconMedium;

  // Color Detection Card
  static const double colorCardHeight = 120.0;
  static const double colorPreviewSize = 80.0;
  static const double rgbDisplayHeight = 60.0;

  // Distance Detection
  static const double distanceGaugeSize = 150.0;
  static const double distanceWarningHeight = 80.0;

  // Location Card
  static const double locationCardHeight = 100.0;
  static const double gpsIconSize = iconLarge;

  // Bluetooth Status
  static const double bluetoothStatusHeight = 80.0;
  static const double connectionIndicatorSize = iconMedium;

  // Loading Indicators
  static const double loadingIndicatorSize = 32.0;
  static const double progressIndicatorHeight = 4.0;

  // Dialog Dimensions
  static const double dialogMaxWidth = 400.0;
  static const double dialogRadius = radiusLarge;
  static const double dialogPadding = paddingLarge;

  // Accessibility
  static const double minTouchTarget = 48.0;        // WCAG AA compliance
  static const double accessibleSpacing = 8.0;     // Minimum spacing between elements
}
