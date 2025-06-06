import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/task.dart';
import '../controllers/category.dart';
import '../models/task.dart';
import '../utils/format_date.dart';
import 'create_task.dart';
import 'task_details.dart';
import '../models/category.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  int _selectedIndex = 0; // 0: In Progress, 1: Scheduled, 2: Backlog, 3: Done

  @override
  void initState() {
    super.initState();
    final taskController = Provider.of<TaskController>(context, listen: false);
    taskController.loadTasks();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List _filterTasks(List tasks) {
    DateTime now = DateTime.now();

    switch (_selectedIndex) {
      case 0: // In Progress
        return tasks.where((task) => !task.isDone && task.scheduledStart != null && task.scheduledStart!.isBefore(now)).toList();
      case 1: // Scheduled
        return tasks.where((task) => !task.isDone && task.scheduledStart != null && task.scheduledStart!.isAfter(now)).toList();
      case 2: // Backlog
        return tasks.where((task) => !task.isDone && task.scheduledStart == null).toList();
      case 3: // Done
        return tasks.where((task) => task.isDone).toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context);
    final categoryController = Provider.of<CategoryController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TaskCreationScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Settings and Add Category will be wired here
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'add_category',
                child: Row(
                  children: [
                    Icon(Icons.category, size: 20),
                    SizedBox(width: 8),
                    Text('Add Category'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: taskController.isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildTaskList(taskController.tasks, categoryController),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.timelapse), label: 'In Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Scheduled'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Backlog'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Done'),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, categoryController) {
    final filteredTasks = _filterTasks(tasks);

    if (filteredTasks.isEmpty) {
      String emptyMessage;
      switch (_selectedIndex) {
        case 0:
          emptyMessage = 'No task in progress';
          break;
        case 1:
          emptyMessage = 'No scheduled tasks';
          break;
        case 2:
          emptyMessage = 'No tasks in backlog';
          break;
        case 3:
          emptyMessage = 'No completed tasks';
          break;
        default:
          emptyMessage = 'No tasks found.';
      }

      return Center(child: Text(
        emptyMessage,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        final category = categoryController.categories.firstWhere(
              (c) => c.id == task.categoryId,
          orElse: () => Category(
            id: 'default',
            name: 'Unknown',
            colorHex: '#9E9E9E',
            iconCode: Icons.help_outline.codePoint,
            iconFontFamily: Icons.help_outline.fontFamily!,
          ),
        );
        return _buildTaskCard(task, category);
      },
    );
  }

  Widget _buildTaskCard(task, category) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task image
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
              // Task details
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
                    Row(
                      children: [
                        // Scheduled Date
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
      ),
    );
  }
}