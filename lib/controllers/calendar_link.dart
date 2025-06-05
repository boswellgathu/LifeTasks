import 'package:flutter/material.dart';
import '../models/calendar_link.dart';
import '../repositories/calendar_link.dart';

class CalendarLinkController with ChangeNotifier {
  final CalendarLinkRepository _calendarLinkRepository = CalendarLinkRepository();

  CalendarLink? _calendarLink;
  bool _isLoading = false;
  String? _error;

  CalendarLink? get calendarLink => _calendarLink;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load calendar link for a task
  Future<void> loadCalendarLink(String taskId) async {
    _setLoading(true);
    try {
      _calendarLink = await _calendarLinkRepository.getCalendarLinkForTask(taskId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load calendar link';
    } finally {
      _setLoading(false);
    }
  }

  // Add a new calendar link
  Future<void> addCalendarLink(CalendarLink link) async {
    try {
      await _calendarLinkRepository.insertCalendarLink(link);
      _calendarLink = link;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add calendar link';
    }
  }

  // Delete a calendar link
  Future<void> deleteCalendarLink(String taskId) async {
    try {
      await _calendarLinkRepository.deleteCalendarLink(taskId);
      _calendarLink = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete calendar link';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}