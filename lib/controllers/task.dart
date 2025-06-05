import 'package:flutter/material.dart';
import '../models/task.dart';
import '../repositories/task.dart';

class TaskController with ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all tasks from database
  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _tasks = await _taskRepository.getAllTasks();
      _error = null;
    } catch (e) {
      _error = 'Failed to load tasks';
    } finally {
      _setLoading(false);
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    try {
      await _taskRepository.insertTask(task);
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add task';
    }
  }

  // Update an existing task
  Future<void> updateTask(Task updatedTask) async {
    try {
      await _taskRepository.updateTask(updatedTask);
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update task';
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete task';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}