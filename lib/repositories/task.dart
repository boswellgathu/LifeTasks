import 'package:sqflite/sqflite.dart';
import '../services/database.dart';
import '../models/task.dart';

class TaskRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> insertTask(Task task) async {
    final db = await _databaseService.database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await _databaseService.database;
    final maps = await db.query('tasks', orderBy: 'scheduled_start ASC');

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final db = await _databaseService.database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateTask(Task task) async {
    final db = await _databaseService.database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await _databaseService.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}