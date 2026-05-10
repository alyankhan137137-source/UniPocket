import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

/// A list tile widget that displays summary information for an [Expense] item.
/// 
/// This widget is used in simple transaction lists to show the title, date,
/// and amount of an expense. It uses a red color for amounts to signify 
/// a deduction.
class ExpenseTile extends StatelessWidget {
  /// The expense data to display in the tile.
  final Expense expense;

  const ExpenseTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.shopping_cart),
      ),
      title: Text(expense.title),
      subtitle: Text(DateFormat.yMMMd().format(expense.date)),
      trailing: Text(
        '-\$${(expense.amount / 100).toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
