import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/expense_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../database/database_helper.dart';

part 'transaction_provider.g.dart';

@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  return TransactionRepository(DatabaseHelper());
}

@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  @override
  Future<List<Expense>> build() async {
    return _fetchTransactions();
  }

  Future<List<Expense>> _fetchTransactions() async {
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.getTransactions();
  }

  Future<void> addTransaction(Expense expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.addTransaction(expense);
      return _fetchTransactions();
    });
  }

  Future<void> updateTransaction(Expense expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.updateTransaction(expense);
      return _fetchTransactions();
    });
  }

  Future<void> deleteTransaction(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.deleteTransaction(id);
      return _fetchTransactions();
    });
  }
}
