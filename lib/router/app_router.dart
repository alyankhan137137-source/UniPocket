import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home/home_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/settings/privacy_policy_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../features/parent_link/screens/parent_link_screen.dart';
import '../features/parent_link/screens/parent_view_screen.dart';
import '../features/subscription/screens/upgrade_screen.dart';
import 'app_routes.dart';

/// Global navigator key to access the [NavigatorState] outside of the widget tree.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// The main routing configuration for the application using the [GoRouter] package.
final goRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: [
    // Splash Route: Entry point for startup logic
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Onboarding Route: First-time user experience
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Main Navigation Shell: Contains the BottomNavigationBar
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationScreen(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.analytics,
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: AppRoutes.budget,
          builder: (context, state) => const BudgetScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),

    // Standalone / Modal routes
    GoRoute(
      path: AppRoutes.addTransaction,
      builder: (context, state) => const AddExpenseScreen(),
    ),
    
    // Deeper settings routes (can be pushed on top of the shell)
    GoRoute(
      path: AppRoutes.categories,
      builder: (context, state) => const Center(child: Text('Category Management')),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.parentLink,
      builder: (context, state) => const ParentLinkScreen(),
    ),
    GoRoute(
      path: AppRoutes.parentView,
      builder: (context, state) => const ParentViewScreen(),
    ),
    GoRoute(
      path: AppRoutes.upgrade,
      builder: (context, state) => const UpgradeScreen(),
    ),
  ],
);

/// A Splash screen that handles initial app state logic.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  /// Evaluates the app state and determines the next screen.
  Future<void> _handleStartup() async {
    // Show splash visual for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingDone = prefs.getBool('is_first_launch') == false;
    final bool isFirstLaunch = !onboardingDone;

    if (isFirstLaunch) {
      if (mounted) context.go(AppRoutes.onboarding);
      return;
    }

    if (mounted) context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Initializing UniPocket...", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
