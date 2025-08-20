import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography styles for the Cane AID app
/// Main: Noto Sans for English text
/// Alternative: Poppins for headings
class AppTextStyles {
  AppTextStyles._();

  // Base text style
  static TextStyle get _baseTextStyle => GoogleFonts.notoSans(
        color: AppColors.textDark,
      );

  // Headings (English)
  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        height: 1.2,
      );

  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        height: 1.2,
      );

  static TextStyle get heading3 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 1.3,
      );

  static TextStyle get heading4 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 1.3,
      );

  // Body Text
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  // Labels and Captions
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // Button Text
  static TextStyle get buttonLarge => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      );

  static TextStyle get buttonMedium => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      );

  static TextStyle get buttonSmall => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      );

  // Special Text Styles
  static TextStyle get colorNameDisplay => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle get distanceDisplay => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.warning,
      );

  static TextStyle get locationDisplay => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        fontFamily: 'monospace', // For coordinate display
      );

  static TextStyle get statusText => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get errorText => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.error,
      );

  static TextStyle get successText => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.success,
      );

  // High Contrast Styles (for accessibility)
  static TextStyle get highContrastBody => _baseTextStyle.copyWith(
        fontSize: 18, // Larger for better readability
        fontWeight: FontWeight.w600, // Bolder for contrast
        color: AppColors.highContrastText,
      );

  static TextStyle get highContrastHeading => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.highContrastText,
      );
}
