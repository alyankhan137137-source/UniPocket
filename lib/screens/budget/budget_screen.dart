import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/budget_model.dart';
import '../../models/category_model.dart';
import '../../models/expense_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final expenses = context.read<ExpenseProvider>().expenses;
      await context.read<BudgetProvider>().loadBudgets(expenses);
      if (!mounted) return;
      await context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Budgets', style: AppStyles.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: budgetProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await budgetProvider.loadBudgets(expenseProvider.expenses);
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildOverviewSection(budgetProvider),
                          const SizedBox(height: 30),
                          _buildBudgetListHeader(),
                        ],
                      ),
                    ),
                  ),
                  if (budgetProvider.budgets.isEmpty)
                    _buildEmptyState()
                  else
                    _buildBudgetList(budgetProvider, expenseProvider.expenses),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_budget',
        onPressed: () => _showAddBudgetSheet(context, categoryProvider),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("New Budget"),
      ),
    );
  }

  Widget _buildOverviewSection(BudgetProvider provider) {
    final double percent = provider.totalBudget > 0 ? (provider.totalSpent / provider.totalBudget) : 0.0;
    final color = percent > 0.9 ? Colors.red : (percent > 0.7 ? Colors.orange : Colors.green);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Budget", style: AppStyles.body2),
                  const SizedBox(height: 4),
                  Text("\$${provider.totalBudget.toStringAsFixed(0)}", style: AppStyles.heading2),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Total Spent", style: AppStyles.body2),
                  const SizedBox(height: 4),
                  Text("\$${provider.totalSpent.toStringAsFixed(0)}", style: AppStyles.heading2.copyWith(color: color)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  value: percent > 1.0 ? 1.0 : percent,
                  strokeWidth: 12,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${(percent * 100).toStringAsFixed(0)}%", style: AppStyles.heading1),
                  Text("Used", style: AppStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            provider.budgetRemaining >= 0 
                ? "\$${provider.budgetRemaining.toStringAsFixed(0)} Remaining"
                : "\$${(provider.budgetRemaining * -1).toStringAsFixed(0)} Overspent",
            style: AppStyles.body1.copyWith(fontWeight: FontWeight.bold, color: provider.budgetRemaining >= 0 ? Colors.green : Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Category Budgets", style: AppStyles.heading3),
        const Icon(Icons.filter_list_rounded, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildBudgetList(BudgetProvider budgetProvider, List<Expense> expenses) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final budget = budgetProvider.budgets[index];
            final percent = budget.percentSpent / 100;
            final color = percent > 1.0 ? Colors.red : (percent > 0.8 ? Colors.orange : Colors.green);

            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Slidable(
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        await budgetProvider.deleteBudget(budget.id!, expenses);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Text("📦", style: TextStyle(fontSize: 20)), // Placeholder icon
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Category ${budget.categoryId}", style: AppStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                                Text(budget.period.toUpperCase(), style: AppStyles.caption),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("\$${(budget.amount / 100).toStringAsFixed(0)}", style: AppStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                              Text("Budget", style: AppStyles.caption),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percent > 1.0 ? 1.0 : percent,
                          minHeight: 8,
                          backgroundColor: color.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("\$${(budget.spent / 100).toStringAsFixed(0)} spent", style: AppStyles.body2),
                          Text(
                            percent > 1.0 
                                ? "\$${((budget.amount - budget.spent).abs() / 100).toStringAsFixed(0)} over" 
                                : "\$${((budget.amount - budget.spent) / 100).toStringAsFixed(0)} left",
                            style: AppStyles.body2.copyWith(color: color, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: budgetProvider.budgets.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text("Set your first budget", style: AppStyles.heading3.copyWith(color: Colors.grey)),
            const SizedBox(height: 10),
            const Text("Track your spending by setting limits.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context, CategoryProvider catProvider) {
    final amountController = TextEditingController();
    CategoryModel? selectedCategory;
    String selectedPeriod = 'monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Category Budget", style: AppStyles.heading3),
              const SizedBox(height: 20),
              DropdownButtonFormField<CategoryModel>(
                decoration: AppStyles.inputDecoration(labelText: "Select Category"),
                items: catProvider.expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text("${c.icon} ${c.name}"))).toList(),
                onChanged: (val) => setModalState(() => selectedCategory = val),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: AppStyles.inputDecoration(labelText: "Budget Amount", prefixIcon: const Icon(Icons.attach_money)),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: selectedPeriod,
                decoration: AppStyles.inputDecoration(labelText: "Period"),
                items: ['daily', 'weekly', 'monthly', 'yearly'].map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase()))).toList(),
                onChanged: (val) => setModalState(() => selectedPeriod = val!),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  if (selectedCategory != null && amountController.text.isNotEmpty) {
                    final budget = Budget(
                      categoryId: selectedCategory!.id,
                      amount: (double.parse(amountController.text) * 100).toInt(),
                      period: selectedPeriod,
                      startDate: DateTime.now(),
                      endDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    await context.read<BudgetProvider>().addBudget(budget, context.read<ExpenseProvider>().expenses);
                    if (!mounted) return;
                    Navigator.pop(context);
                  }
                },
                style: AppStyles.primaryButton,
                child: const Text("Save Budget"),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
