import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/task.dart';
import '../controllers/category.dart';
import 'create_task.dart';
import 'task_details.dart';
import '../models/category.dart';

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
          : taskController.tasks.isEmpty
          ? Center(child: Text('No tasks found. Create one!'))
          : ListView.builder(
        padding: EdgeInsets.all(16),
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

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(task: task),
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          if (task.description != null && task.description!.isNotEmpty)
                            Text(
                              task.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          SizedBox(height: 12),
                          Row(
                            children: [
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
                              Spacer(),
                              Icon(
                                task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: task.isDone ? Colors.green : Colors.grey,
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}