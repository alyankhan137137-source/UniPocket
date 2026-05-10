import '../database/database_helper.dart';
import '../models/category_model.dart';

/// A repository class that manages the persistence and retrieval of transaction categories.
/// 
/// This class provides an abstraction layer over the database for managing
/// [CategoryModel] objects, allowing for clean data access throughout the app.
class CategoryRepository {
  final DatabaseHelper _dbHelper;

  CategoryRepository(this._dbHelper);

  /// Retrieves all transaction categories from the database.
  /// 
  /// Returns a list of [CategoryModel] objects.
  Future<List<CategoryModel>> getCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableCategories);
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  /// Adds a new custom category to the database.
  /// 
  /// [category] is the category object to be inserted.
  /// Returns the auto-generated ID of the new category.
  Future<int> addCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    return await db.insert(DatabaseHelper.tableCategories, category.toMap());
  }

  /// Removes a custom category from the database.
  /// 
  /// [id] is the unique identifier of the category to be deleted.
  /// Returns the number of rows affected.
  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(DatabaseHelper.tableCategories, where: 'id = ?', whereArgs: [id]);
  }
}
