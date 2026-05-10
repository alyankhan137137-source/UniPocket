import 'package:flutter/material.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_colors.dart';

/// A screen that displays the application's privacy policy.
/// 
/// This screen provides clear information to the user about how their data 
/// is handled, emphasizing that all data is stored locally on the device 
/// and not shared with external servers.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: AppStyles.heading3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Introduction"),
            _buildBodyText(
                "PocketTrack Lite (\"we\", \"our\", or \"us\") is committed to protecting your privacy. This Privacy Policy explains how your information is collected, used, and safeguarded when you use our mobile application."),
            const SizedBox(height: 20),
            _buildSectionTitle("Data Collection & Storage"),
            _buildBodyText(
                "1. Local Storage: All financial data, categories, and budgets you enter are stored locally on your device. We do not have access to this data on our servers.\n\n"
                "2. Permissions: The app may request access to notifications to provide budget alerts. You can manage these permissions in your device settings."),
            const SizedBox(height: 20),
            _buildSectionTitle("Data Security"),
            _buildBodyText(
                "We implement local security features such as PIN Lock and Biometric authentication to help you protect your data on your device. However, you are responsible for maintaining the security of your device."),
            const SizedBox(height: 20),
            _buildSectionTitle("User Rights"),
            _buildBodyText(
                "You have full control over your data. You can edit, delete, or clear all data within the application at any time via the Settings menu."),
            const SizedBox(height: 20),
            _buildSectionTitle("Contact Us"),
            _buildBodyText(
                "If you have any questions about this Privacy Policy, please contact the developer:\n"
                "Name: Alyan Khan Banochi\n"
                "Email: muhammedalyankhanbu@gmail.com"),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "Last Updated: October 2023",
                style: AppStyles.caption,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Builds a section title with consistent styling.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppStyles.heading3.copyWith(fontSize: 18, color: AppColors.primary),
      ),
    );
  }

  /// Builds the body text for a policy section.
  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: AppStyles.body1.copyWith(height: 1.5),
    );
  }
}
