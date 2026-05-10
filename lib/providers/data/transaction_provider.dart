import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/expense_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../database/database_helper.dart';

part 'transaction_provider.g.dart';

/// Provides an instance of [TransactionRepository] initialized with [DatabaseHelper].
@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  return TransactionRepository(DatabaseHelper());
}

/// A notifier that manages the state of financial transactions.
/// 
/// This class handles fetching transactions from the repository and provides 
/// methods for adding, updating, and deleting transactions.
@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  /// Loads the initial list of transactions from the repository.
  @override
  Future<List<Expense>> build() async {
    return _fetchTransactions();
  }

  /// Internal method to fetch all transactions from the repository.
  Future<List<Expense>> _fetchTransactions() async {
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.getTransactions();
  }

  /// Adds a new [expense] and refreshes the transaction list.
  Future<void> addTransaction(Expense expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.addTransaction(expense);
      return _fetchTransactions();
    });
  }

  /// Updates an existing transaction and refreshes the transaction list.
  Future<void> updateTransaction(Expense expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.updateTransaction(expense);
      return _fetchTransactions();
    });
  }

  /// Deletes a transaction by its [id] and refreshes the transaction list.
  Future<void> deleteTransaction(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.deleteTransaction(id);
      return _fetchTransactions();
    });
  }
}
