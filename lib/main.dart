import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/comment.dart';
import 'models/category.dart';
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
    final categoryController = Provider.of<CategoryController>(context, listen: false);

    // Temporary seed
    if (categoryController.categories.isEmpty) {
      categoryController.addCategory(
        Category(id: '1', name: 'Home', colorHex: '#FF5733'),
      );
      categoryController.addCategory(
        Category(id: '2', name: 'Work', colorHex: '#33B5FF'),
      );
      categoryController.addCategory(
        Category(id: '3', name: 'Personal', colorHex: '#33FFB5'),
      );
    }

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