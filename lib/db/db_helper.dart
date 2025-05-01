import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dedo/models/task_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static final int _version = 1;

  static final String _tableNameTasks = 'tasks';
  static final String _tableNameCategories = 'categories';

  static Database? _database;
  DBHelper._init();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB('tasks_and_categories.db');
    return _database!;
  }

  Future<Database> initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: _version, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE $_tableNameCategories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    await db.execute(''' 
      CREATE TABLE $_tableNameTasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title STRING NOT NULL,
        note TEXT,
        date STRING NOT NULL,
        startTime STRING,
        endTime STRING,
        remind INTEGER,
        repeat STRING,
        colorIndex INTEGER,
        isCompleted INTEGER NOT NULL,
        categoryId TEXT,
        FOREIGN KEY (categoryId) REFERENCES $_tableNameCategories (id)
      )
    ''');
  }

  // Insert Task
  Future<int> insert(TaskModel task) async {
    final db = await database;
    return await db.insert(_tableNameTasks, task.toJson());
  }

  // Insert Category
  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert(_tableNameCategories, category);
  }

  // Query Tasks
  Future<List<Map<String, dynamic>>> query() async {
    final db = await database;
    return await db.query(_tableNameTasks);
  }

  // Query Tasks by Category
  Future<List<Map<String, dynamic>>> queryTasksByCategory(
    String categoryId,
  ) async {
    final db = await database;
    return await db.query(
      _tableNameTasks,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
  }

  // Query Categories
  Future<List<Map<String, dynamic>>> queryCategories() async {
    final db = await database;
    return await db.query(_tableNameCategories);
  }

  // Update Task
  Future<int> update(TaskModel task) async {
    final db = await database;
    return await db.update(
      _tableNameTasks,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Update Category
  Future<int> updateCategory(
    Map<String, dynamic> category,
    String categoryId,
  ) async {
    final db = await database;
    return await db.update(
      _tableNameCategories,
      category,
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  // Update Single Field for Task
  Future<int> updateSingleField(int taskId, String field, dynamic value) async {
    final db = await database;
    return await db.update(
      _tableNameTasks,
      {field: value},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Delete Task
  Future<int> delete(int taskId) async {
    final db = await database;
    return await db.delete(
      _tableNameTasks,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Delete Category
  Future<int> deleteCategory(String categoryId) async {
    final db = await database;
    return await db.delete(
      _tableNameCategories,
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  // Close the database
  Future close() async {
    final db = await database;
    db.close();
  }

  Future<Map<String, dynamic>?> queryById(int taskId) async {
    final db = await database;
    final result = await db.query(
      _tableNameTasks,
      where: 'id = ?',
      whereArgs: [taskId],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }
}
