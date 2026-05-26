import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/budget_model.dart';
import '../../models/category_model.dart';
import '../../repositories/budget_repository.dart';
import '../../database/database_helper.dart';
import 'transaction_provider.dart';
import 'category_provider.dart';

part 'budget_provider.g.dart';

/// Provides an instance of [BudgetRepository] initialized with [DatabaseHelper].
@riverpod
BudgetRepository budgetRepository(BudgetRepositoryRef ref) {
  final dbHelper = DatabaseHelper.instance;
  return BudgetRepository(dbHelper);
}

/// A notifier that manages the state of the user's budgets.
/// 
/// This class handles fetching budgets from the repository, calculating current
/// spending against each budget by aggregating transactions, and providing
/// CRUD operations for budget management.
@riverpod
class BudgetNotifier extends _$BudgetNotifier {
  /// Initializes the budget list by watching related transaction and category providers.
  @override
  Future<List<Budget>> build() async {
    // We watch other providers to ensure this list updates when they change
    ref.watch(transactionNotifierProvider);
    ref.watch(categoryNotifierProvider);
    
    return _fetchBudgets();
  }

  /// Internal method to fetch budgets and calculate their current spending status.
  Future<List<Budget>> _fetchBudgets() async {
    final repo = ref.read(budgetRepositoryProvider);
    final budgets = await repo.getBudgets();
    
    final transactionsAsync = ref.read(transactionNotifierProvider);
    final categoriesAsync = ref.read(categoryNotifierProvider);
    
    // Check if both dependencies have data using the value property safely
    if (transactionsAsync.hasValue && categoriesAsync.hasValue) {
      final transactions = transactionsAsync.value!;
      final categories = categoriesAsync.value!;
      
      return budgets.map((budget) {
        // 1. Find the name of the category this budget belongs to
        final category = categories.firstWhere(
          (c) => c.id == budget.categoryId,
          orElse: () => CategoryModel(
            id: 'unknown',
            name: 'Unknown', 
            icon: '❓', 
            color: 0xFF000000, 
            type: CategoryType.expense,
          ),
        );
        
        // 2. Calculate spent amount from transactions
        final spent = transactions.where((t) {
          final isSameCategory = t.category == category.name;
          // Inclusive date check: includes start and end dates
          final isWithinDate = !t.date.isBefore(budget.startDate) && !t.date.isAfter(budget.endDate);
          return t.isExpense && isSameCategory && isWithinDate;
        }).fold(0, (sum, t) => sum + t.amount);
        
        return budget.copyWith(spent: spent);
      }).toList();
    }
    
    return budgets;
  }

  /// Adds a new [budget] and refreshes the budget list.
  Future<void> addBudget(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.addBudget(budget);
      return _fetchBudgets();
    });
  }

  /// Updates an existing [budget] and refreshes the budget list.
  Future<void> updateBudget(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.updateBudget(budget);
      return _fetchBudgets();
    });
  }

  /// Deletes a budget by its [id] and refreshes the budget list.
  Future<void> deleteBudget(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.deleteBudget(id);
      return _fetchBudgets();
    });
  }
}
