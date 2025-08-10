import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton helper class to manage SQLite database connection and schema for task management.
/// Handles database initialization, table creation, and closing the database.
class DBHelper {
  // Singleton instance to ensure a single database connection throughout the app lifecycle.
  static final DBHelper instance = DBHelper._init();

  // Private field to hold the database instance once opened.
  static Database? _database;

  // Private constructor to enforce singleton pattern.
  DBHelper._init();

  /// Provides access to the open database instance.
  /// If the database is not initialized, it triggers initialization first.
  Future<Database> get database async {
    if (_database != null) return _database!;

    // Lazily initialize the database on first access.
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database by setting its path and opening the connection.
  /// If the database doesn't exist, it triggers the [_createDatabase] callback.
  Future<Database> _initDatabase() async {
    final dbPath =
        await getDatabasesPath(); // Platform-specific default database directory.
    final path = join(
      dbPath,
      'task_manager.db',
    ); // Database filename with full path.

    // Open the database and create tables if necessary.
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  /// Callback to create database schema on first database creation.
  /// Defines two tables: `categories` and `tasks`, with appropriate fields and constraints.
  Future _createDatabase(Database db, int version) async {
    // Categories table holds user-defined task categories with unique text IDs and color.
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    // Tasks table holds detailed task information with foreign key relation to categories.
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        note TEXT NOT NULL,
        date TEXT,
        startTime TEXT,
        endTime TEXT,
        remind INTEGER,
        color INTEGER,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        categoryId TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');
  }

  /// Closes the database connection safely.
  /// Should be called when the app or feature using the database shuts down.
  Future close() async {
    final db = await database;
    await db.close();
  }
}
