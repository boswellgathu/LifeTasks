import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task.dart';
import '../controllers/category.dart';
import '../models/category.dart';
import 'create_category.dart';
import 'create_task.dart';
import 'task_details.dart';
// Future screens:
// import 'settings_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    final taskController = Provider.of<TaskController>(context, listen: false);
    taskController.loadTasks();
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
            tooltip: 'New Task',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TaskCreationScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                // TODO: Navigate to Settings Screen
              } else if (value == 'add_category') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CategoryCreationScreen()),
                );
              }
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
          : taskController.tasks.isEmpty
          ? Center(child: Text('No tasks found. Create one!'))
          : ListView.builder(
        itemCount: taskController.tasks.length,
        itemBuilder: (context, index) {
          final task = taskController.tasks[index];
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

          return Card(
            child: ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.scheduledStart != null)
                    Text(
                      'Scheduled: ${task.scheduledStart!.toLocal()}',
                      style: TextStyle(fontSize: 12),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Chip(
                      avatar: Icon(category.iconData, color: Colors.white, size: 16),
                      label: Text(category.name),
                      backgroundColor: Color(
                        int.parse(category.colorHex.replaceFirst('#', '0xff')),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              trailing: task.isDone
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Icon(Icons.radio_button_unchecked, color: Colors.grey),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(task: task),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}