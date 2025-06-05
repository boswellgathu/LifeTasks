import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'lifetasker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        scheduled_start INTEGER,
        scheduled_duration INTEGER,
        category_id TEXT,
        is_done INTEGER DEFAULT 0,
        is_archived INTEGER DEFAULT 0,
        image_path TEXT,
        created_at INTEGER NOT NULL,
        last_modified_at INTEGER NOT NULL,
        modified_by TEXT NOT NULL,
        version INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        icon_font_family TEXT NOT NULL,
        is_user_defined INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        content TEXT NOT NULL,
        image_path TEXT,
        author_id TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE calendar_links (
        task_id TEXT PRIMARY KEY,
        google_event_id TEXT NOT NULL,
        synced_at INTEGER NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}