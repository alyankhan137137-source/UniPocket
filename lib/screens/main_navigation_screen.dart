import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home_screen.dart';
import 'analytics/analytics_screen.dart';
import 'budget/budget_screen.dart';
import 'settings/settings_screen.dart';
import 'expenses/add_expense_screen.dart';
import '../constants/app_colors.dart';
import '../utils/animations.dart';
import '../providers/navigation_provider.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    AnalyticsScreen(),
    BudgetScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final selectedIndex = navProvider.selectedIndex;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      floatingActionButton: selectedIndex == 0 || selectedIndex == 2
          ? AppAnimations.scaleOnPress(
              onTap: () {
                Navigator.push(
                  context,
                  AppAnimations.slideRoute(const AddExpenseScreen()),
                );
              },
              child: FloatingActionButton(
                heroTag: 'fab_main_nav',
                onPressed: null, // Handled by scaleOnPress wrapper
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
          onTap: (index) => navProvider.setIndex(index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Analytics"),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Budget"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
