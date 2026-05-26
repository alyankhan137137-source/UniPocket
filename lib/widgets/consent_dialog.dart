import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../router/app_routes.dart';

class ConsentDialog extends StatelessWidget {
  const ConsentDialog({super.key});

  static Future<void> checkAndShow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('legal_consent_accepted') ?? false;
    
    if (!accepted && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ConsentDialog(),
      );
    }
  }

  Future<void> _accept(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('legal_consent_accepted', true);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.gavel_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Legal & Compliance', style: AppStyles.heading3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Before you proceed, please review and accept our professional standards for data processing.',
              style: AppStyles.body2,
            ),
            const SizedBox(height: 20),
            _buildLink(context, 'Data Privacy Charter (GDPR)', AppRoutes.privacyPolicy),
            const SizedBox(height: 12),
            _buildLink(context, 'Terms of Service', AppRoutes.termsOfService),
            const SizedBox(height: 20),
            const Text(
              'By tapping "Accept & Continue", you acknowledge that you have read and agreed to the above terms.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _accept(context),
            style: AppStyles.primaryButton.copyWith(
              minimumSize: const MaterialStatePropertyAll(Size(double.infinity, 50)),
            ),
            child: const Text('Accept & Continue'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLink(BuildContext context, String text, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
