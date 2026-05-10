import 'package:flutter/material.dart';
import '../exceptions/app_exception.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';

/// A widget that displays a user-friendly error message and an optional retry button.
/// 
/// This widget automatically extracts a user-friendly message if the provided
/// [error] is an [AppException]. Otherwise, it displays a generic error message.
class ErrorDisplayWidget extends StatelessWidget {
  /// The error object to display.
  final dynamic error;
  
  /// An optional callback to trigger when the "Try Again" button is pressed.
  final VoidCallback? onRetry;
  
  /// Whether to display this widget as a full-screen scaffold.
  final bool isFullScreen;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    // Map dynamic error to AppException to get userMessage
    final message = error is AppException
        ? (error as AppException).userMessage
        : "An unexpected error occurred.";

    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 24),
            Text("Oops!", style: AppStyles.heading2),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.body1.copyWith(color: AppColors.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Try Again"),
                style: AppStyles.primaryButton,
              ),
            ],
          ],
        ),
      ),
    );

    return isFullScreen ? Scaffold(body: content) : content;
  }
}
