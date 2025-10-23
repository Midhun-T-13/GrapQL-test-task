import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTheme {
  static BoxDecoration get primaryGradientDecoration => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
      );

  static BoxDecoration get primaryGradientHorizontalDecoration =>
      const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      );

  static BoxDecoration primaryGradientWithRadius(double radius) =>
      BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      );

  // Text styles
  static TextStyle get heading1 => TextStyle(
        fontSize: 26.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
      );

  static TextStyle get heading2 => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
      );

  static TextStyle get heading3 => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        color: AppColors.textSecondary,
      );

  static TextStyle get hintText => TextStyle(
        color: AppColors.textHint,
        fontSize: 14.sp,
      );

  // Card text styles
  static TextStyle get cardTitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get cardSubtitle => TextStyle(
        fontSize: 14.sp,
        color: AppColors.textSecondary,
      );

  static TextStyle get cardBody => TextStyle(
        fontSize: 13.sp,
        color: AppColors.textSecondary,
      );

  // Avatar text
  static TextStyle get avatarText => TextStyle(
        color: AppColors.textWhite,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get avatarTextLarge => TextStyle(
        color: AppColors.textWhite,
        fontSize: 40.sp,
        fontWeight: FontWeight.bold,
      );

  // Detail screen text
  static TextStyle get detailTitle => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get detailSubtitle => TextStyle(
        fontSize: 16.sp,
        color: AppColors.textSecondary,
      );

  static TextStyle get detailBody => TextStyle(
        fontSize: 16.sp,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  // Label text
  static TextStyle get labelText => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      );

  // Pagination text
  static TextStyle get paginationActive => TextStyle(
        color: AppColors.textWhite,
        fontWeight: FontWeight.bold,
        fontSize: 14.sp,
      );

  static TextStyle get paginationInactive => TextStyle(
        color: const Color(0xFF6366F1),
        fontWeight: FontWeight.bold,
        fontSize: 14.sp,
      );

  // Input decoration
  static InputDecoration textFieldDecoration({
    required String hintText,
  }) =>
      InputDecoration(
        hintText: hintText,
        hintStyle: AppTheme.hintText,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.borderFocus,
            width: 2.w,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.borderError,
            width: 2.w,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.borderError,
            width: 2.w,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
      );

  // Button styles
  static ButtonStyle get elevatedButtonStyle => ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      );

  // Border radius
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(8.r);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(12.r);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(16.r);
  static BorderRadius get borderRadiusXLarge => BorderRadius.circular(20.r);

  static BorderRadius get topRoundedBorder => BorderRadius.only(
        topLeft: Radius.circular(30.r),
        topRight: Radius.circular(30.r),
      );

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  // SnackBar
  static SnackBar successSnackBar(String message) => SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );

  static SnackBar errorSnackBar(String message) => SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );
}
