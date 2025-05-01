import 'package:dedo/db/database_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category_model.dart';

class CategoryRepository {
  final DatabaseProvider databaseProvider;

  CategoryRepository(this.databaseProvider);

  Future<List<Category>> getAllCategories() async {
    final db = await databaseProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        color: maps[i]['color'],
      );
    });
  }

  Future<void> addCategory(Category category) async {
    final db = await databaseProvider.database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await databaseProvider.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}

extension CategoryExtensions on Category {
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'color': color};
  }
}
