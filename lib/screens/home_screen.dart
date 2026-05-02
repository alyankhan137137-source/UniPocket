import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_tile.dart';
import '../models/expense_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/app_icon.png', errorBuilder: (context, error, stackTrace) {
            // Fallback if image is not yet added
            return const Icon(Icons.account_balance_wallet);
          }),
        ),
        title: const Text('PocketTrack Lite'),
      ),
      body: Column(
        children: [
          _buildSummaryCard(expenseProvider.totalExpense),
          Expanded(
            child: expenseProvider.expenses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: expenseProvider.expenses.length,
                    itemBuilder: (context, index) {
                      return ExpenseTile(expense: expenseProvider.expenses[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_home",
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Using Lottie locally
          Lottie.asset(
            'assets/animations/empty_state.json',
            width: 200,
            repeat: true,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.hourglass_empty, size: 80, color: Colors.grey);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'No expenses yet. Add one!',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double total) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            const Text('Total Expenses', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final doubleAmount = double.tryParse(amountController.text) ?? 0.0;
              if (title.isNotEmpty && doubleAmount > 0) {
                // FIX: Convert double amount to integer cents (e.g. 10.50 -> 1050)
                final int amountInCents = (doubleAmount * 100).toInt();
                
                context.read<ExpenseProvider>().addExpense(
                  Expense(
                    title: title,
                    amount: amountInCents,
                    date: DateTime.now(),
                    category: 'General',
                    type: 'expense',
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
