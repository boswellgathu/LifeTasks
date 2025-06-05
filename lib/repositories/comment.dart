import 'package:sqflite/sqflite.dart';
import '../services/database.dart';
import '../models/comment.dart';

class CommentRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> insertComment(Comment comment) async {
    final db = await _databaseService.database;
    await db.insert('comments', comment.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Comment>> getCommentsForTask(String taskId) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'comments',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => Comment.fromMap(map)).toList();
  }

  Future<void> updateComment(Comment comment) async {
    final db = await _databaseService.database;
    await db.update(
      'comments',
      comment.toMap(),
      where: 'id = ?',
      whereArgs: [comment.id],
    );
  }

  Future<void> deleteComment(String id) async {
    final db = await _databaseService.database;
    await db.delete('comments', where: 'id = ?', whereArgs: [id]);
  }
}