import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? trend;
  final bool isTrendUp;
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
