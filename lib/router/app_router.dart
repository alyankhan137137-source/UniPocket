import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home/home_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../utils/security_helper.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: [
    // Splash Route
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Onboarding Route
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Main Navigation Shell (Bottom Nav)
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationShell(navigationShell: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.transactions,
          builder: (context, state) => const Center(child: Text('Transactions List')),
        ),
        GoRoute(
          path: AppRoutes.budget,
          builder: (context, state) => const BudgetScreen(),
        ),
        GoRoute(
          path: AppRoutes.analytics,
          builder: (context, state) => const AnalyticsScreen(),
        ),
      ],
    ),

    // Standalone routes
    GoRoute(
      path: AppRoutes.addTransaction,
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'categories',
          builder: (context, state) => const Center(child: Text('Category Management')),
        ),
        GoRoute(
          path: 'backup',
          builder: (context, state) => const Center(child: Text('Backup')),
        ),
      ],
    ),
  ],
);

/// A Splash screen that handles initial app logic:
/// 1. Check if first launch -> Go to Onboarding
/// 2. Check if PIN set -> Show PIN Lock (logic can be here or in main)
/// 3. Otherwise -> Go to Dashboard
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

  Future<void> _handleStartup() async {
    // Small delay to show splash logo
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingDone = prefs.getBool('is_first_launch') == false;
    final bool isFirstLaunch = !onboardingDone;

    if (isFirstLaunch) {
      if (mounted) context.go(AppRoutes.onboarding);
      return;
    }

    // Check if security PIN is enabled (optional additional step)
    final hasPin = await SecurityHelper.hasPin();
    if (hasPin) {
      // In this setup, we go to Dashboard which might be wrapped by PIN screen in main.dart
      // or we can add a specific PIN route.
      // For now, let's keep it simple and route to Dashboard.
      if (mounted) context.go(AppRoutes.dashboard);
    } else {
      if (mounted) context.go(AppRoutes.dashboard);
    }
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
            Text("Initializing PocketTrack Lite...", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key, required this.navigationShell});
  final Widget navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.contains(AppRoutes.dashboard)) return 0;
    if (location.contains(AppRoutes.transactions)) return 1;
    if (location.contains(AppRoutes.budget)) return 2;
    if (location.contains(AppRoutes.analytics)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.transactions);
        break;
      case 2:
        context.go(AppRoutes.budget);
        break;
      case 3:
        context.go(AppRoutes.analytics);
        break;
    }
  }
}
