import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<void> updateProfilePhoto(String uid, String newPhotoURL) async {
    final db = await DBHelper.initDB();

    await db.update(
      'users',
      {'photoURL': newPhotoURL},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }
  static Future<bool> userExists(String uid) async {
    final db = await DBHelper.initDB();
    final result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    return result.isNotEmpty;
  }
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await DBHelper.initDB();
    return await db.query('users');
  }
  Future<void> insertUser(Map<String, dynamic> userData) async {
    final db = await DBHelper.initDB();
    await db.insert('users', userData);
  }
  Future<void> updateUser(Map<String, dynamic> userData) async {
    final db = await DBHelper.initDB();
    await db.update(
      'users',
      userData,
      where: 'uid = ?',
      whereArgs: [userData['uid']],
    );
  }
  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            uid TEXT PRIMARY KEY,
            email TEXT,
            name TEXT,
            firstName TEXT,
            lastName TEXT,
            photoURL TEXT,
            dogumYeri TEXT,
            dogumTarihi TEXT,
            yasadigiIl TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }
}