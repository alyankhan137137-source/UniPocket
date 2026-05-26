import 'dart:async';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

/// Represents a specific user action that can be undone.
///
/// Stores the necessary metadata to identify and restore a deleted item.
class UndoAction {
  /// The unique identifier of the deleted record.
  final String id;

  /// The database table name from which the record was deleted.
  final String tableName;

  /// A display title for the action (e.g., the name of the deleted expense).
  final String title;

  /// The point in time when the action was recorded.
  final DateTime timestamp;

  UndoAction({required this.id, required this.tableName, required this.title})
      : timestamp = DateTime.now();
}

/// A service that manages the undo history for soft-deleted items.
///
/// This class tracks recent deletions in a stack and provides the ability
/// to restore them by communicating with the [DatabaseHelper].
class UndoService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// A stack of [UndoAction]s that can be reversed.
  final List<UndoAction> _undoStack = [];

  /// Whether there are any actions currently available to undo.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Pushes a new action onto the undo stack.
  ///
  /// Limits the history to the most recent 20 actions to manage memory.
  void pushAction(UndoAction action) {
    if (_undoStack.length >= 20) _undoStack.removeAt(0); // Keep last 20
    _undoStack.add(action);
    notifyListeners();
  }

  /// Reverses the most recent action on the stack.
  ///
  /// [context] is required to display a [SnackBar] confirming the restoration.
  Future<void> undo(BuildContext context) async {
    if (_undoStack.isEmpty) return;

    final action = _undoStack.removeLast();
    notifyListeners();

    try {
      if (action.tableName == DatabaseHelper.tableExpenses) {
        await _dbHelper.restoreExpense(int.parse(action.id));
      }
      // Add more table restoration logic as needed here

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restored "${action.title}"')),
      );
    } catch (e) {
      debugPrint("Undo failed: $e");
    }
  }
}
