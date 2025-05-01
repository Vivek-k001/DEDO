import 'package:dedo/db/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  final DBHelper dbHelper;

  DatabaseProvider(this.dbHelper);

  Future<Database> get database => dbHelper.database;
}
