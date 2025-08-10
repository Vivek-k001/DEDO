import 'package:dedo/db/db_helper.dart';
import 'package:dedo/models/category_model.dart';

/// A repository class to handle all database operations related to categories.
/// Acts as an abstraction layer between the UI and the database.
class CategoryRepository {
  final DBHelper dbHelper; // Reference to the database helper for accessing SQLite.

  /// Initializes the repository with a given [DBHelper] instance.
  CategoryRepository(this.dbHelper);

  /// Inserts a new category into the 'categories' table.
  /// Returns the ID of the inserted row.
  Future<int> insertCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    return await db.insert('categories', category.toMap());
  }

  /// Retrieves all categories from the database.
  /// Converts each row into a [CategoryModel] instance.
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await dbHelper.database;
    final results = await db.query('categories');
    return results.map((result) => CategoryModel.fromMap(result)).toList();
  }

  /// Updates an existing category in the database based on its ID.
  /// Returns the number of rows affected (should be 1 on success).
  Future<int> updateCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Deletes a category from the database using its ID.
  /// Returns the number of rows removed (should be 1 if deletion was successful).
  Future<int> deleteCategory(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves a single category by its ID.
  /// Returns a [CategoryModel] if found, otherwise returns null.
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
