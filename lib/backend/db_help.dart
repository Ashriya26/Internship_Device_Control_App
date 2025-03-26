import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; // ✅ Needed for path operations
import 'package:path_provider/path_provider.dart'; // ✅ Needed for database path
import 'dart:io';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, 'users.db'); // ✅ Construct full path
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT
        )
      ''');
    },
  );
}

   // ✅ Insert a User (Only Used Once)
  Future<void> insertUser(String username, String password) async {
    final db = await database;
    await db.insert(
      'users',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ✅ Fetch User for Login Validation
  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: "username = ? AND password = ?",
      whereArgs: [username, password],
    );

    return users.isNotEmpty ? users.first : null;
  }
}
