import 'package:dedo/db/db_helper.dart';
import 'package:dedo/models/task_model.dart';

class TaskRepository {
  final DBHelper dbHelper;

  TaskRepository(this.dbHelper);

  Future<int> insertTask(TaskModel task) async {
    final db = await dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await dbHelper.database;
    final results = await db.query('tasks');
    return results.map((result) => TaskModel.fromMap(result)).toList();
  }

  Future<List<TaskModel>> getTasksByCategory(String categoryId) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'tasks',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return results.map((result) => TaskModel.fromMap(result)).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await dbHelper.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<TaskModel?> getTaskById(int id) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) return TaskModel.fromMap(results.first);
    return null;
  }

  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    final db = await dbHelper.database;
    return await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
