import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../providers/expense_provider.dart';
import '../../../models/expense_model.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/skeleton.dart';
import '../../expenses/add_expense_screen.dart';

/// A widget that displays a list of the most recent financial transactions.
/// 
/// This widget uses a [ListView] to show a scrollable list of [Expense] items.
/// It supports swipe-to-delete and swipe-to-edit actions using the [Slidable] 
/// package. It also displays an empty state animation if no transactions exist.
class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Activity", style: AppStyles.heading3),
            TextButton(
              onPressed: () {
                // TODO: Implement navigation to a full transaction history screen
              },
              child: const Text("View All", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<ExpenseProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => const _TransactionSkeleton(),
              );
            }
            if (provider.expenses.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Lottie.asset('assets/animations/empty_state.json', height: 150,
                      errorBuilder: (_, __, ___) => const Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.textHint)),
                    const SizedBox(height: 16),
                    Text("No transactions yet", style: AppStyles.heading3.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    const Text("Add your first expense or income to see it here.",
                        textAlign: TextAlign.center, style: AppStyles.body2),
                  ],
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.recentTransactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _TransactionItem(expense: provider.recentTransactions[index]);
              },
            );
          },
        ),
      ],
    );
  }
}

class _TransactionSkeleton extends StatelessWidget {
  const _TransactionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Row(
        children: [
          const Skeleton(height: 48, width: 48, borderRadius: 24),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 16, width: 120),
                SizedBox(height: 8),
                Skeleton(height: 12, width: 80),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Skeleton(height: 16, width: 60),
              SizedBox(height: 8),
              Skeleton(height: 10, width: 40),
            ],
          ),
        ],
      ),
    );
  }
}

/// An individual transaction item widget with swipe actions.
class _TransactionItem extends StatelessWidget {
  final Expense expense;
  const _TransactionItem({required this.expense});

  /// Deletes the transaction and shows a [SnackBar] with an undo option.
  void _deleteWithUndo(BuildContext context) {
    if (expense.id == null) return;
    
    final provider = context.read<ExpenseProvider>();
    final id = expense.id!;
    final title = expense.title;

    provider.deleteExpense(id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "$title"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => provider.restoreExpense(id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = expense.type == 'income';
    final list = isIncome ? AppConstants.incomeCategories : AppConstants.expenseCategories;
    final catData = list.firstWhere(
      (e) => e['name'] == expense.category,
      orElse: () => {'name': 'Other', 'emoji': '📦', 'color': Colors.grey},
    );

    return Slidable(
      key: ValueKey(expense.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteWithUndo(context),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AddExpenseScreen(expenseToEdit: expense))),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit_rounded,
            label: 'Edit',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AddExpenseScreen(expenseToEdit: expense))),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppStyles.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: (catData['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(catData['emoji'] ?? '📦', style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title,
                        style: AppStyles.body1.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(expense.category, style: AppStyles.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isIncome ? '+' : '-'}${NumberFormat.simpleCurrency().format(expense.amount / 100.0)}",
                    style: TextStyle(
                      color: isIncome ? AppColors.income : AppColors.expense,
                      fontWeight: FontWeight.bold, fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(DateFormat('MMM d, y').format(expense.date),
                      style: AppStyles.caption.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
