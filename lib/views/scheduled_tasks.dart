import 'dart:io';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/category.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../utils/format_date.dart';

class ScheduledTabScreen extends StatefulWidget {
  final List<Task> tasks;
  final CategoryController categoryController;

  const ScheduledTabScreen({
    super.key,
    required this.tasks,
    required this.categoryController,
  });

  @override
  ScheduledTabScreenState createState() => ScheduledTabScreenState();
}

class ScheduledTabScreenState extends State<ScheduledTabScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Task>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _prepareTasksByDate();
  }

  void _prepareTasksByDate() {
    _tasksByDate.clear();
    for (var task in widget.tasks) {
      if (task.scheduledStart != null) {
        final day = DateTime(
          task.scheduledStart!.year,
          task.scheduledStart!.month,
          task.scheduledStart!.day,
        );
        _tasksByDate.putIfAbsent(day, () => []).add(task);
      }
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return _tasksByDate[dayKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Tasks'),
              Tab(text: 'Calendar View'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTaskList(tasks),
                _buildCalendarView(tasks),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(ScheduledTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      _prepareTasksByDate();
    }
  }

  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildCalendarView(List<Task> tasks) {
    return Column(
      children: [
        TableCalendar<Task>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) {
            final dayKey = DateTime(day.year, day.month, day.day);
            return _tasksByDate[dayKey] ?? [];
          },
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
              _selectedDay = null; // 🛠️ Clear selected day when month changes
            });
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        Expanded(
          child: _buildSelectedDayTasks(),
        ),
      ],
    );
  }

  Widget _buildSelectedDayTasks() {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          'Select a day to view tasks',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    final tasksForSelectedDay = _getTasksForDay(_selectedDay!);

    if (tasksForSelectedDay.isEmpty) {
      return Center(
        child: Text(
          'No tasks for this day',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tasksForSelectedDay.length,
      itemBuilder: (context, index) {
        final task = tasksForSelectedDay[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    final category = widget.categoryController.categories.firstWhere(
          (c) => c.id == task.categoryId,
      orElse: () => Category(
        id: 'default',
        name: 'Unknown',
        colorHex: '#9E9E9E',
        iconCode: Icons.help_outline.codePoint,
        iconFontFamily: Icons.help_outline.fontFamily!,
      ),
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (task.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(task.imagePath!),
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              ),
            SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Category Chip
                  Chip(
                    avatar: Icon(category.iconData, size: 16, color: Colors.white),
                    label: Text(category.name),
                    backgroundColor: Color(
                      int.parse(category.colorHex.replaceFirst('#', '0xff')),
                    ),
                    labelStyle: TextStyle(color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    shape: StadiumBorder(),
                  ),
                  if (task.description != null && task.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  SizedBox(height: 12),
                  // Date and Duration
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Text(
                        task.scheduledStart != null
                            ? formatDateTime(task.scheduledStart!)
                            : 'No Due Date',
                        style: TextStyle(
                          fontSize: 14,
                          color: task.scheduledStart != null ? Colors.grey[800] : Colors.grey[500],
                          fontStyle: task.scheduledStart != null ? FontStyle.normal : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  if (task.scheduledStart != null && task.scheduledDuration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 6),
                          Text(
                            formatDuration(task.scheduledDuration!),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}