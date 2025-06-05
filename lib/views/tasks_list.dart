import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/category.dart';
import '../controllers/task.dart';
import '../models/category.dart';
import 'create_task.dart';
import 'task_details.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when screen opens
    final taskController = Provider.of<TaskController>(context, listen: false);
    taskController.loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context);
    final categoryController = Provider.of<CategoryController>(context); // <-- Access categories

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
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
              colorHex: '#9E9E9E', // Grey color
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
                  if (category.id != 'default')
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TaskCreationScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}