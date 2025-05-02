import 'package:dedo/db/db_helper.dart';
import 'package:dedo/models/category_model.dart';

class CategoryRepository {
  final DBHelper dbHelper;

  CategoryRepository(this.dbHelper);

  Future<int> insertCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await dbHelper.database;
    final results = await db.query('categories');
    return results.map((result) => CategoryModel.fromMap(result)).toList();
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await dbHelper.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) return CategoryModel.fromMap(results.first);
    return null;
  }
}
