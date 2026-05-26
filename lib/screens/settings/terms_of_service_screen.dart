import 'package:flutter/material.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_colors.dart';

/// A professional-grade Terms of Service screen outlining the legal framework for UniPocket usage.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service', style: AppStyles.heading3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Service Agreement",
              style: AppStyles.heading2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            _buildBodyText(
                "Last Updated: October 2024\n\nPlease read these Terms of Service (\"Terms\") carefully before using UniPocket. By accessing or using the app, you agree to be bound by these legal conditions."),
            const SizedBox(height: 32),
            
            _buildSectionTitle("1. License Grant"),
            _buildBodyText(
                "UniPocket grants you a personal, non-exclusive, non-transferable, limited license to use the application strictly in accordance with these Terms for your personal financial management."),
            
            const SizedBox(height: 24),
            _buildSectionTitle("2. User Responsibilities"),
            _buildBodyText(
                "You are solely responsible for:\n"
                "• Maintaining the confidentiality of your PIN and biometric data.\n"
                "• All activity that occurs under your account or on your device.\n"
                "• Ensuring the accuracy of the financial data you input."),

            const SizedBox(height: 24),
            _buildSectionTitle("3. Financial Disclaimer"),
            _buildBodyText(
                "UniPocket is a tool for tracking and visualization. It DOES NOT provide professional financial advice, accounting services, or investment recommendations. All decisions made based on the data within this app are at the user's own risk."),

            const SizedBox(height: 24),
            _buildSectionTitle("4. Prohibited Use"),
            _buildBodyText(
                "You may not use UniPocket for any illegal purpose or in violation of any local, state, national, or international law. You agree not to reverse engineer, decompile, or attempt to extract the source code of the application."),

            const SizedBox(height: 24),
            _buildSectionTitle("5. Limitation of Liability"),
            _buildBodyText(
                "To the maximum extent permitted by law, UniPocket and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including loss of profits, data, or financial assets resulting from your use of the service."),

            const SizedBox(height: 24),
            _buildSectionTitle("6. Modifications to Service"),
            _buildBodyText(
                "We reserve the right to modify, suspend, or discontinue the service (or any part thereof) at any time with or without notice."),

            const SizedBox(height: 24),
            _buildSectionTitle("7. Governing Law"),
            _buildBodyText(
                "These Terms shall be governed and construed in accordance with the laws of the jurisdiction in which the Lead Developer resides, without regard to its conflict of law provisions."),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: AppStyles.heading3.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: AppStyles.body2.copyWith(height: 1.6, color: AppColors.textPrimary),
    );
  }
}
