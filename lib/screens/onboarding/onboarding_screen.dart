import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../providers/settings_provider.dart';
import '../../utils/animations.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/profile/models/user_profile.dart';
import '../../router/app_routes.dart';
import 'package:uuid/uuid.dart';

/// A screen that guides new users through the app's features and initial setup.
/// 
/// This screen uses a [PageView] to show introduction slides and a final 
/// setup page where users can enter their name and select their primary currency.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  /// Data for the introductory slides.
  final List<_OnboardingData> _pages = [
    _OnboardingData("Track Every Expense",
        "Log your daily transactions in seconds and stay on top of your spending.", AppColors.primary),
    _OnboardingData("Set Smart Budgets",
        "Define limits for different categories and get notified before you overspend.", Colors.orange),
    _OnboardingData("Insightful Reports",
        "Visualize your financial health with beautiful charts and deep analytics.", Colors.green),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Finalizes the onboarding process, saves the user's profile, and navigates to the home screen.
  Future<void> _completeOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name to continue')),
      );
      return;
    }

    // Save profile with real name
    final now = DateTime.now();
    final profile = UserProfile(
      id: const Uuid().v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(profileNotifierProvider.notifier).updateProfile(profile);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);

    if (mounted) {
      // Use GoRouter for navigation to ensure compatibility with the app's routing configuration.
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length + 1,
            itemBuilder: (context, index) {
              if (index < _pages.length) return _buildPage(_pages[index]);
              return _buildSetupPage();
            },
          ),
          _buildTopBar(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  /// Builds the top bar with skip button and page indicators.
  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage < _pages.length)
              TextButton(
                onPressed: () => _pageController.jumpToPage(_pages.length),
                child: const Text("Skip", style: TextStyle(color: AppColors.textSecondary)),
              )
            else
              const SizedBox.shrink(),
            Row(
              children: List.generate(_pages.length + 1, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == i ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? AppColors.primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an individual introduction page.
  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/empty_state.json', height: 280,
            errorBuilder: (_, __, ___) => Icon(Icons.show_chart, size: 150, color: data.color)),
          const SizedBox(height: 40),
          Text(data.title, style: AppStyles.heading1, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(data.description,
              style: AppStyles.body1.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  /// Builds the setup page where the user configures their profile.
  Widget _buildSetupPage() {
    final settingsProvider = context.watch<SettingsProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.waving_hand_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text("Welcome!", style: AppStyles.heading1),
          const SizedBox(height: 10),
          const Text("Track your uni spending, stress-free",
              textAlign: TextAlign.center, style: AppStyles.body1),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: AppStyles.inputDecoration(
              labelText: "Your Name",
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 20),
          AppAnimations.scaleOnPress(
            onTap: () => showCurrencyPicker(
              context: context,
              onSelect: (c) => settingsProvider.setCurrency(c.code),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppStyles.cardShadow,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_outlined, color: AppColors.primary),
                  const SizedBox(width: 15),
                  const Text("Currency", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(settingsProvider.settings.currency,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const Icon(Icons.chevron_right, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text("You can change these anytime in settings.",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  /// Builds the navigation controls at the bottom of the screen.
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 50, left: 40, right: 40,
      child: _currentPage == _pages.length
          ? ElevatedButton(
              onPressed: _completeOnboarding,
              style: AppStyles.primaryButton.copyWith(
                minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 60)),
              ),
              child: const Text("Get Started 🚀"),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 60),
                FloatingActionButton(
                  heroTag: 'fab_onboarding',
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
    );
  }
}

/// Helper class to store onboarding slide content.
class _OnboardingData {
  final String title, description;
  final Color color;
  _OnboardingData(this.title, this.description, this.color);
}
