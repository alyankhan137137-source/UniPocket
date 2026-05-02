import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class ExpenseTile extends StatelessWidget {
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
        '-\$${expense.amount.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
