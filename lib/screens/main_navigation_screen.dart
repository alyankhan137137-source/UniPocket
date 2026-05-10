import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'expenses/add_expense_screen.dart';
import '../constants/app_colors.dart';
import '../utils/animations.dart';
import '../router/app_routes.dart';

/// The root navigation shell of the application, compatible with GoRouter.
/// 
/// This screen implements a persistent [BottomNavigationBar] and handles the 
/// display of nested routes within a [Scaffold]. It also hosts the global 
/// Floating Action Button, which is intelligently shown or hidden based 
/// on the active route.
class MainNavigationScreen extends StatelessWidget {
  /// Creates a [MainNavigationScreen] that wraps the provided [child].
  const MainNavigationScreen({super.key, required this.child});

  /// The widget representing the current sub-route content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      // The child widget provided by GoRouter's ShellRoute
      body: child,
      
      floatingActionButton: _shouldShowFAB(selectedIndex)
          ? AppAnimations.scaleOnPress(
              onTap: () => context.push(AppRoutes.addTransaction),
              child: FloatingActionButton(
                heroTag: 'fab_main_nav',
                onPressed: null, // Logic handled by scaleOnPress
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), 
              activeIcon: Icon(Icons.home_filled),
              label: "Home"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), 
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: "Analytics"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded), 
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: "Budget"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), 
              activeIcon: Icon(Icons.person),
              label: "Profile"
            ),
          ],
        ),
      ),
    );
  }

  /// Determines the active index of the bottom navigation bar based on the current URI.
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.dashboard)) return 0;
    if (location.startsWith(AppRoutes.analytics)) return 1;
    if (location.startsWith(AppRoutes.budget)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  /// Navigates to the route associated with the tapped bottom navigation item.
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go(AppRoutes.dashboard); break;
      case 1: context.go(AppRoutes.analytics); break;
      case 2: context.go(AppRoutes.budget); break;
      case 3: context.go(AppRoutes.settings); break;
    }
  }

  /// Determines if the Floating Action Button should be visible for the current tab.
  bool _shouldShowFAB(int index) {
    // Show FAB on Home (0) and Budget (2) tabs
    return index == 0 || index == 2;
  }
}
