import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

class AttendanceRecord {
  final int? id;
  final String sessionId;
  final String subject;
  final String studentId;
  final int timestamp;
  final int isSynced;

  AttendanceRecord({
    this.id,
    required this.sessionId,
    required this.subject,
    required this.studentId,
    required this.timestamp,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'subject': subject,
      'studentId': studentId,
      'timestamp': timestamp,
      'isSynced': isSynced,
    };
  }
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'attendance_db.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId TEXT,
        subject TEXT,
        studentId TEXT,
        timestamp INTEGER,
        isSynced INTEGER
      )
    ''');
  }

  Future<int> insertRecord(AttendanceRecord record) async {
    final db = await database;
    return await db.insert('attendance', record.toMap());
  }

  Future<List<AttendanceRecord>> getPendingSyncRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return AttendanceRecord(
        id: maps[i]['id'],
        sessionId: maps[i]['sessionId'],
        subject: maps[i]['subject'],
        studentId: maps[i]['studentId'],
        timestamp: maps[i]['timestamp'],
        isSynced: maps[i]['isSynced'],
      );
    });
  }

  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      'attendance',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getPresentCount() async {
    final db = await database;
    int? count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM attendance'));
    return count ?? 0;
  }
}
