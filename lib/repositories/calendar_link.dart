import 'package:sqflite/sqflite.dart';
import '../services/database.dart';
import '../models/calendar_link.dart';

class CalendarLinkRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> insertCalendarLink(CalendarLink link) async {
    final db = await _databaseService.database;
    await db.insert('calendar_links', link.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<CalendarLink?> getCalendarLinkForTask(String taskId) async {
    final db = await _databaseService.database;
    final maps = await db.query('calendar_links', where: 'task_id = ?', whereArgs: [taskId]);

    if (maps.isNotEmpty) {
      return CalendarLink.fromMap(maps.first);
    }
    return null;
  }

  Future<void> deleteCalendarLink(String taskId) async {
    final db = await _databaseService.database;
    await db.delete('calendar_links', where: 'task_id = ?', whereArgs: [taskId]);
  }
}