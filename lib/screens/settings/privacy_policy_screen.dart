import 'package:flutter/material.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_colors.dart';

/// A professional-grade Privacy Policy screen compliant with GDPR and CCPA standards.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Privacy Charter', style: AppStyles.heading3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Commitment to Data Transparency",
              style: AppStyles.heading2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            _buildBodyText(
                "Last Updated: October 2024\n\nUniPocket (\"Company\", \"we\", \"us\", or \"our\") operates as a Data Controller under the General Data Protection Regulation (GDPR). This document outlines our rigorous protocols for data collection, processing, and user sovereignty."),
            const SizedBox(height: 32),
            
            _buildSectionTitle("1. Scope of Data Processing"),
            _buildBodyText(
                "We process data categorized into two distinct environments:\n\n"
                "• On-Device Data: Your granular financial records, category structures, and budget configurations are stored in an encrypted local database. This data never leaves your device unless explicitly synced.\n\n"
                "• Cloud-Synchronized Data: If you utilize the 'Collaborative Sync' (Parent Link) features, specific snapshots of your financial health are transmitted via end-to-end encrypted channels to our secure Firebase-hosted infrastructure."),
            
            const SizedBox(height: 24),
            _buildSectionTitle("2. Legal Basis for Processing"),
            _buildBodyText(
                "Under GDPR Article 6, we process your data based on:\n"
                "• Consent: Your explicit opt-in for cloud synchronization.\n"
                "• Contractual Necessity: To provide the core financial tracking services requested by you."),

            const SizedBox(height: 24),
            _buildSectionTitle("3. User Sovereignty (Your Rights)"),
            _buildBodyText(
                "You possess the following 'Data Subject Rights':\n"
                "• Right to Erasure: The 'Factory Reset' feature in settings provides an instantaneous, irreversible purge of all local and cloud-linked data.\n"
                "• Right to Portability: You may export your financial data into PDF or Excel formats at any time.\n"
                "• Right to Restrict Processing: You can disable all cloud-sync features while maintaining local app functionality."),

            const SizedBox(height: 24),
            _buildSectionTitle("4. Retention Policy"),
            _buildBodyText(
                "Local data persists until app uninstallation or manual reset. Cloud-synchronized snapshots are retained for a maximum of 30 days or until the 'Collaborative Sync' link is deactivated, whichever occurs first."),

            const SizedBox(height: 24),
            _buildSectionTitle("5. Security Architecture"),
            _buildBodyText(
                "We utilize industry-standard AES-256 encryption for data at rest on our servers and TLS 1.3 for data in transit. On-device security is augmented by your biometric and PIN authentication protocols."),

            const SizedBox(height: 24),
            _buildSectionTitle("6. Contact our Data Protection Officer"),
            _buildBodyText(
                "For formal inquiries regarding your data privacy, please contact our lead developer and DPO:\n\n"
                "Alyan Khan Banochi\n"
                "muhammedalyankhanbu@gmail.com"),
            
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
