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
import '../../widgets/skeleton.dart';

/// A screen for managing and tracking budgets by category and monthly allowance.
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

    final allowanceBudget = budgetProvider.budgets.where((b) => b.isAllowance).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financial Targets', style: AppStyles.heading3),
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
          ? _buildLoadingState()
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
                          _buildAllowanceCard(context, budgetProvider, allowanceBudget),
                          const SizedBox(height: 20),
                          _buildOverviewSection(budgetProvider),
                          const SizedBox(height: 30),
                          _buildBudgetListHeader(),
                        ],
                      ),
                    ),
                  ),
                  if (budgetProvider.budgets.where((b) => !b.isAllowance).isEmpty)
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

  /// Builds the top Monthly Allowance card.
  Widget _buildAllowanceCard(BuildContext context, BudgetProvider provider, Budget? allowance) {
    if (allowance == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 40, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text("No Monthly Allowance Set", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text("Set an allowance to track your total monthly spending.", textAlign: TextAlign.center, style: AppStyles.caption),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAllowanceDialog(context),
              style: AppStyles.primaryButton,
              child: const Text("Set Monthly Allowance"),
            ),
          ],
        ),
      );
    }

    final allowanceAmount = allowance.amount / 100.0;
    final spent = provider.totalMonthlySpent;
    final remaining = allowanceAmount - spent;
    final percent = allowanceAmount > 0 ? (spent / allowanceAmount) : 0.0;
    
    Color progressColor = Colors.green;
    if (percent >= 1.0) {
      progressColor = Colors.red;
    } else if (percent >= 0.75) {
      progressColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Monthly Spending Limit", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () => _showAllowanceDialog(context, currentAllowance: allowanceAmount),
                child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("\$${allowanceAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAllowanceStat("Utilized", "\$${spent.toStringAsFixed(2)}"),
              _buildAllowanceStat("Available", "\$${remaining.toStringAsFixed(2)}", isRight: true),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor == Colors.green ? Colors.white : progressColor),
            ),
          ),
          if (percent >= 1.0) ...[
            const SizedBox(height: 8),
            const Text("Allowance exceeded!", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ]
        ],
      ),
    );
  }

  Widget _buildAllowanceStat(String label, String value, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  void _showAllowanceDialog(BuildContext context, {double? currentAllowance}) {
    final controller = TextEditingController(text: currentAllowance?.toString() ?? "");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Set Monthly Allowance"),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: AppStyles.inputDecoration(
            labelText: "Allowance Amount",
            prefixIcon: const Icon(Icons.attach_money),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(controller.text);
                  if (amount != null) {
                    final now = DateTime.now();
                    final budget = Budget(
                      categoryId: 'allowance',
                      amount: (amount * 100).toInt(),
                      period: 'monthly',
                      startDate: DateTime(now.year, now.month, 1),
                      endDate: DateTime(now.year, now.month + 1, 0),
                      isAllowance: true,
                    );
                    
                    final budgetProvider = context.read<BudgetProvider>();
                    final expenseProvider = context.read<ExpenseProvider>();
                    final navigator = Navigator.of(ctx);
                    final existing = budgetProvider.budgets.where((b) => b.isAllowance).firstOrNull;
                    
                    if (existing != null) {
                      await budgetProvider.updateBudget(budget.copyWith(id: existing.id), expenseProvider.expenses);
                    } else {
                      await budgetProvider.addBudget(budget, expenseProvider.expenses);
                    }
                    
                    if (mounted) navigator.pop();
                  }
                },
            style: AppStyles.primaryButton,
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Skeleton(height: 180, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 20),
          const Skeleton(height: 200, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Skeleton(height: 24, width: 150),
              Skeleton(height: 24, width: 24),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 15),
              itemBuilder: (_, __) => const Skeleton(height: 120, width: double.infinity, borderRadius: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the top overview card showing total budget performance.
  Widget _buildOverviewSection(BudgetProvider provider) {
    final budgets = provider.budgets.where((b) => !b.isAllowance).toList();
    if (budgets.isEmpty) return const SizedBox.shrink();

    final double totalBudget = budgets.fold(0.0, (s, b) => s + (b.amount / 100.0));
    final double totalSpent = budgets.fold(0.0, (s, b) => s + (b.spent / 100.0));
    final double percent = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;
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
                  Text("Cumulative Target", style: AppStyles.body2),
                  const SizedBox(height: 4),
                  Text("\$${totalBudget.toStringAsFixed(0)}", style: AppStyles.heading2),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Total Outflow", style: AppStyles.body2),
                  const SizedBox(height: 4),
                  Text("\$${totalSpent.toStringAsFixed(0)}", style: AppStyles.heading2.copyWith(color: color)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  value: percent.clamp(0.0, 1.0),
                  strokeWidth: 10,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${(percent * 100).toStringAsFixed(0)}%", style: AppStyles.heading3),
                  Text("Utilized", style: AppStyles.caption),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the header for the category-specific budget list.
  Widget _buildBudgetListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Category Budgets", style: AppStyles.heading3),
        const Icon(Icons.filter_list_rounded, color: AppColors.textSecondary),
      ],
    );
  }

  /// Builds the list of category budgets using [Slidable] for delete actions.
  Widget _buildBudgetList(BudgetProvider budgetProvider, List<Expense> expenses) {
    final budgets = budgetProvider.budgets.where((b) => !b.isAllowance).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final budget = budgets[index];
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
                            child: const Text("📦", style: TextStyle(fontSize: 20)), 
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
                          value: percent.clamp(0.0, 1.0),
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
          childCount: budgets.length,
        ),
      ),
    );
  }

  /// Builds the empty state UI when no budgets are defined.
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

  /// Shows a modal bottom sheet to add a new category budget.
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
                    final budgetProvider = context.read<BudgetProvider>();
                    final expenseProvider = context.read<ExpenseProvider>();
                    final navigator = Navigator.of(context);
                    await budgetProvider.addBudget(budget, expenseProvider.expenses);
                    if (!mounted) return;
                    navigator.pop();
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
