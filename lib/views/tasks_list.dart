import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/task.dart';
import 'create_task.dart';

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
              subtitle: task.scheduledStart != null
                  ? Text(
                  'Scheduled: ${task.scheduledStart!.toLocal()}')
                  : null,
              trailing: task.isDone
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Icon(Icons.radio_button_unchecked, color: Colors.grey),
              onTap: () {
                // TODO: Navigate to task detail/edit screen
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