import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';
import '../../database/database_helper.dart';

part 'category_provider.g.dart';

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepository(DatabaseHelper());
}

@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  Future<List<CategoryModel>> build() async {
    return _fetchCategories();
  }

  Future<List<CategoryModel>> _fetchCategories() async {
    final repo = ref.watch(categoryRepositoryProvider);
    return repo.getCategories();
  }

  Future<void> addCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.addCategory(category);
      return _fetchCategories();
    });
  }

  Future<void> deleteCategory(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.deleteCategory(id);
      return _fetchCategories();
    });
  }
}
