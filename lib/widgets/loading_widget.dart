import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable widget to display a centered loading indicator with an optional message.
/// 
/// This widget provides a consistent loading experience throughout the app. 
/// It can be used as a standalone widget within a screen or as a full-page overlay.
class LoadingWidget extends StatelessWidget {
  /// Whether to display the loader as a full-page scaffold with a semi-transparent background.
  final bool isFullPage;
  
  /// An optional message to display below the loading indicator (e.g., "Processing...").
  final String? message;

  const LoadingWidget({
    super.key,
    this.isFullPage = false,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );

    if (isFullPage) {
      return Scaffold(
        backgroundColor: AppColors.background.withValues(alpha: 0.5),
        body: content,
      );
    }

    return content;
  }
}

/// A simple placeholder widget that simulates a "shimmer" effect during content loading.
/// 
/// Used to build skeleton loaders for lists and cards, giving users a visual hint 
/// of the content structure while data is being fetched.
class ShimmerLoading extends StatelessWidget {
  /// The width of the shimmer placeholder.
  final double width;
  
  /// The height of the shimmer placeholder.
  final double height;
  
  /// The corner radius of the shimmer placeholder.
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      // Note: This is a static implementation. For actual animation, 
      // consider integrating the 'shimmer' package.
    );
  }
}
