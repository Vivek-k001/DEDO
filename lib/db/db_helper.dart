import 'package:dedo/models/task_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  static final int _version = 1;

  static final String _tableName = 'tasks';

  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }

    try {
      String path = '${await getDatabasesPath()}/tasks.db';
      _db = await openDatabase(
        path,
        version: _version,
        onCreate: (db, version) {
          if (kDebugMode) {
            print("Creating a new one");
          }
          return db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title STRING, note TEXT, date STRING, "
            "startTime STRING, endTime STRING, "
            "remind INTEGER, repeat STRING, "
            "color INTEGER, isCompleted BOOLEAN)",
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  static Future<List<Map<String, dynamic>>> query() async {
    return await _db!.query(_tableName);
  }

  static Future<int> insert(TaskModel task) async {
    return await _db!.insert(_tableName, task.toJson());
  }

  static Future<int> delete(int taskId) async {
    return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [taskId]);
  }

  static Future<int> update(TaskModel task) async {
    return await _db!.update(
      _tableName,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> updateSingleField(
    int taskId,
    String field,
    dynamic value,
  ) async {
    return await _db!.update(
      _tableName,
      {field: value},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }
}
