import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';
import '../../database/database_helper.dart';

part 'category_provider.g.dart';

/// Provides an instance of [CategoryRepository] initialized with [DatabaseHelper].
@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepository(DatabaseHelper());
}

/// A notifier that manages the state of transaction categories.
/// 
/// This class handles fetching categories from the repository and provides 
/// methods for adding and deleting custom categories.
@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  /// Loads the initial category list from the repository.
  @override
  Future<List<CategoryModel>> build() async {
    return _fetchCategories();
  }

  /// Internal method to fetch the latest categories from the repository.
  Future<List<CategoryModel>> _fetchCategories() async {
    final repo = ref.watch(categoryRepositoryProvider);
    return repo.getCategories();
  }

  /// Adds a new [category] and refreshes the category list.
  Future<void> addCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.addCategory(category);
      return _fetchCategories();
    });
  }

  /// Deletes a category by its [id] and refreshes the category list.
  Future<void> deleteCategory(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.deleteCategory(id);
      return _fetchCategories();
    });
  }
}
