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
      version: 2, // ⬆️ Incremented version to ensure DB upgrade
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');

        // ✅ Create 'devices' table
        await db.execute('''
          CREATE TABLE devices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT UNIQUE,
            ssid TEXT,
            password TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS devices (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              device_id TEXT UNIQUE,
              ssid TEXT,
              password TEXT
            )
          ''');
        }
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

  // ✅ Insert a New Device (Add Device in Background)
  Future<void> insertDevice(String deviceId, String ssid, String password) async {
    final db = await database;
    await db.insert(
      'devices',
      {'device_id': deviceId, 'ssid': ssid, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ✅ Fetch All Devices
  Future<List<Map<String, dynamic>>> getAllDevices() async {
    final db = await database;
    return await db.query('devices');
  }

  // ✅ Delete a Device
  Future<void> deleteDevice(String deviceId) async {
    final db = await database;
    await db.delete(
      'devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }
}
