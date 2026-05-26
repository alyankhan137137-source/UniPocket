import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../router/app_routes.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardBackgroundDark : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Information', style: AppStyles.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    height: 100, width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: AppStyles.cardShadow,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('UniPocket', style: AppStyles.heading2),
                  const Text('v1.0.0 (Stable)', style: AppStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildInfoSection(context, cardColor),
            const SizedBox(height: 30),
            _buildDeveloperCard(cardColor),
            const SizedBox(height: 40),
            Text(
              '© ${DateTime.now().year} UniPocket Inc. All rights reserved.',
              style: AppStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          _infoTile(Icons.privacy_tip_outlined, 'Privacy Policy', () => context.push(AppRoutes.privacyPolicy)),
          const Divider(height: 1, indent: 56),
          _infoTile(Icons.description_outlined, 'Terms of Service', () => context.push(AppRoutes.termsOfService)),
          const Divider(height: 1, indent: 56),
          _infoTile(Icons.support_agent_rounded, 'Contact Support', () => _showContactDialog(context)),
          const Divider(height: 1, indent: 56),
          _infoTile(Icons.star_outline_rounded, 'Rate UniPocket', () {}),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  Widget _buildDeveloperCard(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Developer Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Alyan Khan Banochi', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Lead Software Architect', style: AppStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Committed to building high-performance financial tools for the modern student.',
            style: AppStyles.body2,
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Customer Support'),
        content: const Text('Our technical support team is available at:\n\nmuhammedalyankhanbu@gmail.com'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
