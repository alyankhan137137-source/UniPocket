import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final bool isFullPage;
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

/// A simple Shimmer-like loading effect for lists
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
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
      // In a real app, you'd use the 'shimmer' package here.
      // For now, we use a subtle solid color to simulate the skeleton.
    );
  }
}
