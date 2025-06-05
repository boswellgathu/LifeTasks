import 'package:sqflite/sqflite.dart';
import '../services/database.dart';
import '../models/category.dart';

class CategoryRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> insertCategory(Category category) async {
    final db = await _databaseService.database;
    await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getAllCategories() async {
    final db = await _databaseService.database;
    final maps = await db.query('categories', orderBy: 'name ASC');

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<void> deleteCategory(String id) async {
    final db = await _databaseService.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}