import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../services/subscription_service.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Plus'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Parent Plus',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Give your parents peace of mind',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 40),
            _buildBenefitRow(context, 'Share a live spending summary with parents'),
            _buildBenefitRow(context, 'Parents see balance, budget & recent activity'),
            _buildBenefitRow(context, 'Read-only — parents can view, not edit'),
            const SizedBox(height: 48),
            _buildPriceCard(context),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await SubscriptionService().purchaseParentPlus(context);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Subscribe Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Logic for restoring purchases would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restoring purchases...')),
                );
              },
              child: const Text('Restore Purchase'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment charged to your App Store/Google Play account. Subscription automatically renews unless cancelled 24 hours before the end of the current period.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            '\$7.99 / month',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cancel anytime',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
