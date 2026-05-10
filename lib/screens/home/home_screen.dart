import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../router/app_routes.dart';
import 'widgets/balance_card.dart';
import 'widgets/recent_transactions.dart';

/// The primary dashboard screen for the application.
///
/// This screen provides a high-level overview of the user's finances,
/// including current balance, quick actions for adding transactions,
/// spending progress, and recent activity. It uses [ConsumerStatefulWidget]
/// to react to profile and financial data changes.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data loading on first frame
    Future.microtask(() async {
      if (!mounted) return;
      final ep = context.read<ExpenseProvider>();
      await ep.fetchExpenses();
      if (!mounted) return;
      await context.read<CategoryProvider>().loadCategories();
      if (!mounted) return;
      await context.read<BudgetProvider>().loadBudgets(ep.expenses);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch profile state to display personalized greeting
    final profileAsync = ref.watch(profileNotifierProvider);
    final userName = (profileAsync.value?.name.isNotEmpty == true) ? profileAsync.value!.name : 'there';
    final initials = userName.isNotEmpty
        ? userName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome back!", style: AppStyles.body2),
                Text(userName, style: AppStyles.heading3),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                onPressed: () => context.push(AppRoutes.settings),
              ),
              const SizedBox(width: 10),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const BalanceCard(),
                  const SizedBox(height: 30),
                  _buildQuickActions(context),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, "Spending Overview", () => context.go(AppRoutes.analytics)),
                  const SizedBox(height: 15),
                  _buildSpendingOverview(context),
                  const SizedBox(height: 30),
                  const RecentTransactions(),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, "Budget Status", () => context.go(AppRoutes.budget)),
                  const SizedBox(height: 15),
                  _buildBudgetStatus(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the horizontal row of quick action buttons.
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickAction("Add Income", Icons.add_circle_outline, Colors.green, () =>
            context.push(AppRoutes.addTransaction)),
        _quickAction("Add Expense", Icons.remove_circle_outline, Colors.orange, () =>
            context.push(AppRoutes.addTransaction)),
        _quickAction("Analytics", Icons.pie_chart_outline, Colors.blue, () => context.go(AppRoutes.analytics)),
        _quickAction("Budgets", Icons.grid_view, Colors.purple, () => context.go(AppRoutes.budget)),
      ],
    );
  }

  /// Builds a single quick action item with an icon and label.
  Widget _quickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppStyles.cardShadow,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 11)),
        ],
      ),
    );
  }

  /// Builds a section header with a title and a "See All" action.
  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppStyles.heading3),
        TextButton(onPressed: onTap, child: const Text("See All")),
      ],
    );
  }

  /// Builds the spending overview horizontal list.
  Widget _buildSpendingOverview(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _overviewCard("Today", provider.todayExpenses, provider.totalExpense > 0 ? provider.todayExpenses / provider.totalExpense : 0),
          _overviewCard("This Month", provider.totalExpense, 1.0),
          _overviewCard("Income", provider.totalIncome, 1.0),
        ],
      ),
    );
  }

  /// Builds a card for the spending overview.
  Widget _overviewCard(String label, double amount, double progress) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppStyles.body2),
          const SizedBox(height: 8),
          Text("\$${amount.toStringAsFixed(2)}", style: AppStyles.heading3.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the budget status section showing progress for the top 3 budgets.
  Widget _buildBudgetStatus(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    if (budgetProvider.budgets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppStyles.cardShadow,
        ),
        child: const Center(child: Text("Set up a budget to track your goals!")),
      );
    }
    return Column(
      children: budgetProvider.budgets.take(3).map((budget) {
        final progress = budget.percentSpent / 100;
        final color = progress > 1.0 ? Colors.red : (progress > 0.8 ? Colors.orange : Colors.green);
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppStyles.cardShadow,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(budget.categoryId, style: AppStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                  Text("${(progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
