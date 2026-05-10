import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// A card widget that displays a summary statistic with an icon and optional trend indicator.
/// 
/// This widget is commonly used on dashboards to show metrics like total income, 
/// total expenses, or net savings. It includes an icon for quick identification 
/// and a trend percentage to show changes over time.
class StatsCard extends StatelessWidget {
  /// The descriptive label for the statistic (e.g., "Total Income").
  final String label;
  
  /// The formatted string representation of the numeric value.
  final String value;
  
  /// The icon representing the statistic.
  final IconData icon;
  
  /// An optional trend string (e.g., "+12%") showing the change relative to a previous period.
  final String? trend;
  
  /// Whether the trend is positive (up) or negative (down), which determines the trend icon and color.
  final bool isTrendUp;
  
  /// The primary color for the icon and its background. Defaults to [AppColors.primary].
  final Color? color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.trend,
    this.isTrendUp = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.borderRadiusMedium,
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: effectiveColor, size: 24),
              ),
              if (trend != null)
                Row(
                  children: [
                    Icon(
                      isTrendUp ? Icons.trending_up : Icons.trending_down,
                      color: isTrendUp ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isTrendUp ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
