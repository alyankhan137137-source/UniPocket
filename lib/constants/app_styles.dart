import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App styles and decorations for a modern and consistent UI.
class AppStyles {
  AppStyles._();

  // --- Border Radius ---
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusExtraLarge = 32.0;

  static final BorderRadius borderRadiusSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(radiusLarge);

  // --- Spacing ---
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceExtraLarge = 32.0;

  // --- Shadows ---
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  // --- Typography ---
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  // --- Button Styles ---
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    elevation: 2,
  );

  static final ButtonStyle outlineButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
  );

  // --- Input Decoration ---
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textHint),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: borderRadiusMedium,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusMedium,
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusMedium,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  // --- Card Decoration ---
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: borderRadiusMedium,
    boxShadow: cardShadow,
  );
}
