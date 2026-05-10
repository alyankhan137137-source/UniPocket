import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App styles and decorations for a modern and consistent UI.
/// 
/// This class provides reusable text styles, button styles, decorations, 
/// and spacing constants used throughout the application to maintain
/// visual consistency.
class AppStyles {
  AppStyles._();

  // --- Border Radius ---
  /// Small border radius for elements like small chips or secondary buttons.
  static const double radiusSmall = 8.0;
  
  /// Medium border radius for primary buttons and standard cards.
  static const double radiusMedium = 16.0;
  
  /// Large border radius for large containers or prominent UI sections.
  static const double radiusLarge = 24.0;
  
  /// Extra large border radius for specialized circular or rounded designs.
  static const double radiusExtraLarge = 32.0;

  /// Reusable [BorderRadius] object for [radiusSmall].
  static final BorderRadius borderRadiusSmall = BorderRadius.circular(radiusSmall);
  
  /// Reusable [BorderRadius] object for [radiusMedium].
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(radiusMedium);
  
  /// Reusable [BorderRadius] object for [radiusLarge].
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(radiusLarge);

  // --- Spacing ---
  /// Small spacing constant for tight layouts.
  static const double spaceSmall = 8.0;
  
  /// Medium spacing constant for standard padding and margins.
  static const double spaceMedium = 16.0;
  
  /// Large spacing constant for separating major UI sections.
  static const double spaceLarge = 24.0;
  
  /// Extra large spacing constant for significant separation.
  static const double spaceExtraLarge = 32.0;

  // --- Shadows ---
  /// Standard soft shadow for elevated cards.
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  // --- Typography ---
  /// Style for main page headings and large titles.
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );

  /// Style for secondary section headings.
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Style for smaller sub-headings or prominent list item titles.
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Standard body text style for readability.
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Secondary body text style for less prominent information.
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// Smallest text style for hints, metadata, or labels.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  // --- Button Styles ---
  /// Default elevated button style used for primary actions.
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    elevation: 2,
  );

  /// Outlined button style used for secondary or neutral actions.
  static final ButtonStyle outlineButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
  );

  // --- Input Decoration ---
  /// Generates a consistent [InputDecoration] for text fields.
  /// 
  /// [labelText] is the floating label.
  /// [hintText] is the placeholder text when the field is empty.
  /// [prefixIcon] is an optional widget shown at the start of the field.
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
  /// Reusable [BoxDecoration] for cards and elevated containers.
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: borderRadiusMedium,
    boxShadow: cardShadow,
  );
}
