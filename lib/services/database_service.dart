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
      version: 4,
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
          id            INTEGER PRIMARY KEY AUTOINCREMENT,
          device_id     TEXT UNIQUE,
          ssid          TEXT,
          password      TEXT,
          ip            TEXT,
          type          TEXT,
          device_name   TEXT,      -- NEW
          status        INTEGER    -- NEW: 1=online, 0=offline
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
        if (oldVersion < 4) {
          // add the two new columns to existing installs
          await db.execute('ALTER TABLE devices ADD COLUMN device_name TEXT');
          await db.execute(
              'ALTER TABLE devices ADD COLUMN status INTEGER DEFAULT 0');
        }

        // Just in case admin user is lost after upgrade
        final users = await db
            .query('users', where: 'username = ?', whereArgs: ['admin']);
        if (users.isEmpty) {
          await db.insert('users', {'username': 'admin', 'password': '1234'});
        }
      },
    );
  }

  // ✅ Always ensure admin user exists (used in main.dart)
  Future<void> ensureAdminUserExists() async {
    final db = await database;
    final result =
        await db.query('users', where: 'username = ?', whereArgs: ['admin']);
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

  Future<Map<String, dynamic>?> getUser(
      String username, String password) async {
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
  Future<void> insertDevice(
    String deviceId,
    String ssid,
    String password, {
    String? ip,
    String? type,
    String? deviceName, // ← new
    bool online = false, // ← new
  }) async {
    final db = await database;

    // Check if device already exists in the database
  final existingDevice = await db.query(
    'devices',
    where: 'device_id = ?',
    whereArgs: [deviceId],
  );

  if (existingDevice.isNotEmpty) {
    print("⚠️ Device with ID '$deviceId' already exists in the database.");
    return; // Don't insert the device again
  }

  // Insert the device into the database
    
    await db.insert(
      'devices',
      {
        'device_id': deviceId,
        'ssid': ssid,
        'password': password,
        'ip': ip,
        'type': type,
        'device_name': deviceName ?? '', // store the user’s name
        'status': 0, // 1 = online, 0 = offline
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    print("✅ Device Saved!");

    // 🔍 DEBUG: Check contents of the database
  final devices = await db.query('devices');
  print("📦 Devices in DB:");
  for (var device in devices) {
    print(device);
  }
  }

  Future<List<Map<String, dynamic>>> getAllDevices() async {
    final db = await database;
    return await db.query('devices');
  }

  Future<int> updateDeviceName(String deviceId, String newName) async {
    final db = await database;
    return await db.update(
      'devices', // your table name
      {'device_name': newName}, // the column to change
      where: 'device_id = ?', // the row selector
      whereArgs: [deviceId],
    );
  }

  /// Deletes a device row by its device_id.
    Future<int> deleteDevice(String deviceId) async {
    final db = await database;
    try {
    int result = await db.delete(
      'devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );

    if (result > 0) {
      print("🗑️ Device with ID '$deviceId' deleted from database.");
    } else {
      print("⚠️ No device found with ID '$deviceId'. Nothing was deleted.");
    }

    return result;
  } catch (e) {
    print("❌ Error while deleting device: $e");
    return 0;
  }
}

  Future<void> saveWiFiCredentials(String ssid, String password) async {
    final db = await database;
    await db.insert(
      'wifi_credentials',
      {'ssid': ssid, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// UPDATE the on/off flag (1 = online, 0 = offline)
  Future<void> updateDeviceStatus(String deviceId, bool online) async {
    final db = await database;
    await db.update(
      'devices',
      {'status': online ? 1 : 0},
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }
}
