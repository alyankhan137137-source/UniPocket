import '../database/database_helper.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper;

  CategoryRepository(this._dbHelper);

  Future<List<CategoryModel>> getCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableCategories);
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<int> addCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    return await db.insert(DatabaseHelper.tableCategories, category.toMap());
  }

  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(DatabaseHelper.tableCategories, where: 'id = ?', whereArgs: [id]);
  }
}
