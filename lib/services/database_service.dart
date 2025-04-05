import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
    String path = join(documentsDirectory.path, 'app_database.db');

    

      return await openDatabase(
        path,
        version: 3,
        onCreate: (db, version) async {
          // ✅ Create 'users' table
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
              password TEXT,
              ip TEXT,
              type TEXT
            )
          ''');

          // ✅ Create 'wifi_credentials' table
          await db.execute('''
            CREATE TABLE wifi_credentials (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              ssid TEXT,
              password TEXT
            )
          ''');

          // ✅ Insert default admin user
          await db.insert('users', {
            'username': 'admin',
            'password': '1234',
          });

        },

        onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE devices ADD COLUMN ip TEXT");
          await db.execute("ALTER TABLE devices ADD COLUMN type TEXT");
        }

        // Just in case admin user is lost after upgrade
        final users = await db.query('users', where: 'username = ?', whereArgs: ['admin']);
        if (users.isEmpty) {
          await db.insert('users', {'username': 'admin', 'password': '1234'});
        }
      },
    );

  }

    // ✅ Always ensure admin user exists (used in main.dart)
  Future<void> ensureAdminUserExists() async {
    final db = await database;
    final result = await db.query('users', where: 'username = ?', whereArgs: ['admin']);
    if (result.isEmpty) {
      await db.insert('users', {'username': 'admin', 'password': '1234'});
    }
  }
  // USER Methods
  Future<void> insertUser(String username, String password) async {
    final db = await database;
    await db.insert(
      'users',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    final users = await db.query(
      'users',
      where: "username = ? AND password = ?",
      whereArgs: [username, password],
    );

    print("🔍 Login attempt for: $username / $password");
    print("Query result: $users");
    return users.isNotEmpty ? users.first : null;
  }

  // DEVICE Methods
  Future<void> insertDevice(String deviceId, String ssid, String password, {String? ip, String? type}) async {
    final db = await database;
    await db.insert(
      'devices',
      {
        'device_id': deviceId,
        'ssid': ssid,
        'password': password,
        'ip': ip,
        'type': type,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("✅ Device Saved!");
  }

  Future<List<Map<String, dynamic>>> getAllDevices() async {
    final db = await database;
    return await db.query('devices');
  }

  Future<void> deleteDevice(String deviceId) async {
    final db = await database;
    await db.delete(
      'devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  Future<void> saveWiFiCredentials(String ssid, String password) async {
  final db = await database;
  await db.insert(
    'wifi_credentials',
    {'ssid': ssid, 'password': password},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
}