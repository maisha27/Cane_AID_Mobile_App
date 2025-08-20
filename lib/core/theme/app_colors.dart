import 'package:flutter/material.dart';

/// App color scheme based on accessibility and trust
/// Primary: Deep Blue (#006C99) - Trust, calming, official
/// Secondary: Teal Green (#00A676) - Accessibility, nature, health
/// Accent: Golden Yellow (#F9A825) - Highlights, call-to-action
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF006C99);      // Deep Blue
  static const Color secondary = Color(0xFF00A676);    // Teal Green
  static const Color accent = Color(0xFFF9A825);       // Golden Yellow

  // Background Colors
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF121212);

  // Text Colors
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF757575);

  // Status Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // High Contrast Colors (for accessibility)
  static const Color highContrastPrimary = Color(0xFF000080);
  static const Color highContrastSecondary = Color(0xFF008000);
  static const Color highContrastText = Color(0xFF000000);
  static const Color highContrastBackground = Color(0xFFFFFFFF);

  // Bluetooth Connection Status Colors
  static const Color bluetoothConnected = success;
  static const Color bluetoothDisconnected = error;
  static const Color bluetoothConnecting = warning;

  // Sensor Status Colors
  static const Color sensorActive = success;
  static const Color sensorInactive = error;
  static const Color sensorWarning = warning;

  // Distance Warning Colors
  static const Color distanceClose = error;        // Very close objects
  static const Color distanceMedium = warning;     // Medium distance
  static const Color distanceFar = success;        // Safe distance

  // Color Detection Display
  static const Color colorCardBackground = surface;
  static const Color colorCardBorder = Color(0xFFE0E0E0);
}
