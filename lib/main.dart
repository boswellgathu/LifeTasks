import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/comment.dart';
import 'controllers/task.dart';
import 'controllers/category.dart';
import 'views/create_task.dart';
import 'views/tasks_list.dart';

void main() {
  runApp(LifeTaskerApp());
}

class LifeTaskerApp extends StatelessWidget {
  const LifeTaskerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskController()),
        ChangeNotifierProvider(create: (_) => CategoryController()..loadCategories()),
        ChangeNotifierProvider(create: (_) => CommentController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LifeTasker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TaskListScreen(), // 👈 Show Task List Screen
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LifeTasker')),
      body: Center(
        child: Text('Welcome to LifeTasker! Start by creating a task.'),
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