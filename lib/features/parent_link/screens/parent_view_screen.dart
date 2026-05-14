import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/expense_provider.dart';
import '../models/student_snapshot_model.dart';
import '../services/parent_link_service.dart';

class ParentViewScreen extends StatefulWidget {
  const ParentViewScreen({super.key});

  @override
  State<ParentViewScreen> createState() => _ParentViewScreenState();
}

class _ParentViewScreenState extends State<ParentViewScreen> {
  final TextEditingController _codeController = TextEditingController();
  final ParentLinkService _linkService = ParentLinkService();
  StudentSnapshot? _snapshot;
  bool _isVerifying = false;

  Future<void> _verifyCode(ExpenseProvider expenseProvider) async {
    final enteredCode = _codeController.text.trim();
    if (enteredCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit code')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final activeLink = await _linkService.getActiveLink();
      if (activeLink != null && activeLink.accessCode == enteredCode) {
        // In a real multi-user app, we'd fetch the student's data by ID.
        // For this local prototype, we build a snapshot of the current local data.
        final snapshot = await _linkService.buildSnapshot(expenseProvider, "Student");
        setState(() {
          _snapshot = snapshot;
          _isVerifying = false;
        });
      } else {
        setState(() => _isVerifying = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code not found or expired')),
          );
        }
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent View'),
        leading: _snapshot != null 
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _snapshot = null))
            : null,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          if (_snapshot == null) {
            return _buildCodeEntryView(expenseProvider);
          }
          return _buildDashboardView();
        },
      ),
    );
  }

  Widget _buildCodeEntryView(ExpenseProvider expenseProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.family_restroom, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Parent View',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enter the 6-digit access code provided by your student to view their spending summary.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
            decoration: InputDecoration(
              counterText: '',
              hintText: '000000',
              hintStyle: TextStyle(color: AppColors.textHint.withOpacity(0.5)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : () => _verifyCode(expenseProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isVerifying 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('View Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    final s = _snapshot!;
    final progress = s.monthlyAllowance > 0 ? (s.spentThisMonth / s.monthlyAllowance).clamp(0.0, 1.0) : 0.0;
    final currencyFormat = NumberFormat.simpleCurrency();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRemainingBudgetCard(s, currencyFormat),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Spent This Month', s.spentThisMonth, currencyFormat, AppColors.expense)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Current Balance', s.currentBalance, currencyFormat, AppColors.primary)),
            ],
          ),
          const SizedBox(height: 24),
          if (s.monthlyAllowance > 0) ...[
            const Text('Monthly Usage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.9 ? AppColors.error : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).toStringAsFixed(0)}% used', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(currencyFormat.format(s.monthlyAllowance), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),
          ],
          const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          ...s.recentTransactions.map((tx) => _buildTransactionItem(tx, currencyFormat)),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Last updated: ${DateFormat('HH:mm, dd MMM yyyy').format(s.lastUpdated)}',
              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRemainingBudgetCard(StudentSnapshot s, NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Remaining Budget', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            fmt.format(s.remainingBudget),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          if (s.monthlyAllowance > 0) ...[
            const SizedBox(height: 4),
            Text('of ${fmt.format(s.monthlyAllowance)} monthly allowance', style: const TextStyle(color: Colors.white60, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, double amount, NumberFormat fmt, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            fmt.format(amount),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx, NumberFormat fmt) {
    final isExpense = tx['type'] == 'expense';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isExpense ? AppColors.expense : AppColors.income).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: isExpense ? AppColors.expense : AppColors.income,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(tx['date'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${fmt.format(tx['amount'])}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpense ? AppColors.expense : AppColors.income,
            ),
          ),
        ],
      ),
    );
  }
}
