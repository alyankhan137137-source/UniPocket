import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:currency_picker/currency_picker.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../constants/app_colors.dart';

/// A card widget that displays the user's total balance, allowance, and expenses.
/// 
/// This widget features a gradient background, animated balance numbers,
/// and a privacy toggle to hide or show sensitive monetary values.
class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});
  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true;

  /// Formats the monetary [amount] based on the [currencyCode].
  String _formatAmount(double amount, String currencyCode) {
    try {
      final currency = CurrencyService().findByCode(currencyCode);
      final symbol = currency?.symbol ?? currencyCode;
      return '$symbol${amount.toStringAsFixed(2)}';
    } catch (_) {
      return NumberFormat.simpleCurrency(name: currencyCode).format(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final currency = settings.currency;

    if (provider.isLoading) {
      return Container(
        height: 200, width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Container(
      height: 200, width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(right: -50, top: -50,
              child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withValues(alpha: 0.1))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Balance",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(currency, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                            child: Icon(
                              _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.white.withValues(alpha: 0.9), size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: provider.currentBalance),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.fastOutSlowIn,
                    builder: (_, value, __) => Text(
                      _isBalanceVisible ? _formatAmount(value, currency) : "••••••",
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(child: _infoCol("Allowance/Added",
                        _isBalanceVisible ? _formatAmount(provider.totalIncome, currency) : "••••",
                        Icons.arrow_downward_rounded, Colors.greenAccent)),
                      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.2)),
                      Expanded(child: _infoCol("Expenses",
                        _isBalanceVisible ? _formatAmount(provider.totalExpense, currency) : "••••",
                        Icons.arrow_upward_rounded, Colors.redAccent)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a column showing either allowance or expense details.
  Widget _infoCol(String label, String amount, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                Text(amount, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
