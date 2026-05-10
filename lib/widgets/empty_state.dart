import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// A reusable widget to display when there is no data to show in a list or section.
/// 
/// This widget typically includes a visual (Lottie animation or Icon), a title,
/// a descriptive message, and an optional action button to help users 
/// recover from the empty state (e.g., "Add Transaction").
class EmptyState extends StatelessWidget {
  /// The primary heading for the empty state.
  final String title;
  
  /// A secondary message providing more context or instructions.
  final String description;
  
  /// The local path to a Lottie animation file. If null, a default icon is used.
  final String? animationPath;
  
  /// The text to display on the optional action button.
  final String? actionLabel;
  
  /// The callback function to execute when the action button is pressed.
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.animationPath,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (animationPath != null)
              Lottie.asset(
                animationPath!,
                height: 200,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.hourglass_empty_rounded,
                  size: 80,
                  color: AppColors.textHint,
                ),
              )
            else
              const Icon(
                Icons.hourglass_empty_rounded,
                size: 80,
                color: AppColors.textHint,
              ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppStyles.heading3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppStyles.body2,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onActionPressed,
                style: AppStyles.primaryButton,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
