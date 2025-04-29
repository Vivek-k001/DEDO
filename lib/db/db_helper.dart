import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  static final int _version = 1;

  static final String _tableName = 'tasks';

  static Future<void> initDb() async {
    if (_db != null) return;
    try {
      String _path = '${await getDatabasesPath()}/tasks.db';
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) async {
          print('Creating new DB');
          await db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "title TEXT,"
            "note TEXT,"
            "date TEXT,"
            "startTime TEXT,"
            "endTime TEXT,"
            "remind INTEGER,"
            "repeat TEXT,"
            "color INTEGER,"
            "isCompleted INTEGER)",
          );
        },
      );
    } catch (e) {
      print("DB Init Error: $e");
    }
  }

  static Future<int> insert(Task? task) async {
    print("Insert function called");
    if (_db == null) {
      throw Exception("Database is not initialized");
    }
    return await _db!.insert(_tableName, task!.toJson());
  }
}
