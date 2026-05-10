import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// A card widget that displays a transaction category with an icon and label.
/// 
/// This widget is used in category selection grids or lists. it features 
/// an animated selection state that changes its background color, border, 
/// and shadow when [isSelected] is true.
class CategoryCard extends StatelessWidget {
  /// The display name of the category (e.g., "Food").
  final String label;
  
  /// The emoji or icon string representing the category.
  final String icon;
  
  /// Whether this category is currently selected by the user.
  final bool isSelected;
  
  /// Callback function triggered when the user taps on the card.
  final VoidCallback onTap;
  
  /// The primary color used for the selection state. Defaults to [AppColors.primary].
  final Color? color;

  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppColors.primary) : Colors.white,
          borderRadius: AppStyles.borderRadiusMedium,
          border: Border.all(
            color: isSelected ? (color ?? AppColors.primary) : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: isSelected ? AppColors.primaryShadow : AppStyles.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
