import 'dart:async';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class UndoAction {
  final String id;
  final String tableName;
  final String title;
  final DateTime timestamp;

  UndoAction({required this.id, required this.tableName, required this.title})
      : timestamp = DateTime.now();
}

class UndoService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<UndoAction> _undoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;

  void pushAction(UndoAction action) {
    if (_undoStack.length >= 20) _undoStack.removeAt(0); // Keep last 20
    _undoStack.add(action);
    notifyListeners();
  }

  Future<void> undo(BuildContext context) async {
    if (_undoStack.isEmpty) return;

    final action = _undoStack.removeLast();
    notifyListeners();

    try {
      if (action.tableName == DatabaseHelper.tableExpenses) {
        await _dbHelper.restoreExpense(int.parse(action.id));
      }
      // Add more tables as needed

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restored "${action.title}"')),
      );
    } catch (e) {
      debugPrint("Undo failed: $e");
    }
  }
}
