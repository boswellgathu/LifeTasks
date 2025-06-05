import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../controllers/task.dart';
import '../controllers/category.dart';
import '../models/task.dart';

class TaskCreationScreen extends StatefulWidget {
  const TaskCreationScreen({super.key});

  @override
  TaskCreationScreenState createState() => TaskCreationScreenState();
}

class TaskCreationScreenState extends State<TaskCreationScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  Duration? _selectedDuration;
  String? _selectedCategoryId;
  File? _selectedImage;
  bool _scheduleTask = false;

  final picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (date == null) return;

    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveTask() async {
    if (_titleController.text.isEmpty || _selectedCategoryId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and Category are required')),
      );
      return;
    }

    final taskId = const Uuid().v4();
    final now = DateTime.now();
    final newTask = Task(
      id: taskId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      scheduledStart: _scheduleTask ? _selectedDateTime : null,
      scheduledDuration: _scheduleTask ? _selectedDuration : null,
      categoryId: _selectedCategoryId!,
      imagePath: _selectedImage?.path,
      isDone: false,
      isArchived: false,
      createdAt: now,
      lastModifiedAt: now,
      modifiedBy: 'local-device', // Replace with real device/user ID
      version: 1,
    );

    final taskController = Provider.of<TaskController>(context, listen: false);
    await taskController.addTask(newTask);

    if (!mounted) return;
    Navigator.pop(context); // <-- Only use context if still mounted
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Provider.of<CategoryController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Create Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description (optional)'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: categoryController.categories.map((category) {
                final color = Color(int.parse(category.colorHex.replaceFirst('#', '0xff'))); // convert hex to Color
                return ChoiceChip(
                  avatar: Icon(category.iconData, color: Colors.white, size: 20),
                  label: Text(category.name),
                  selected: _selectedCategoryId == category.id,
                  selectedColor: color,
                  backgroundColor: color.withOpacity(0.6),
                  labelStyle: TextStyle(color: Colors.white),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Schedule Task'),
              value: _scheduleTask,
              onChanged: (value) {
                setState(() {
                  _scheduleTask = value;
                });
              },
            ),
            if (_scheduleTask) ...[
              ElevatedButton(
                onPressed: _pickDateTime,
                child: Text(
                  _selectedDateTime == null
                      ? 'Pick Date & Time'
                      : '${_selectedDateTime!.toLocal()}',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Duration (minutes)'),
                onChanged: (value) {
                  final minutes = int.tryParse(value);
                  if (minutes != null) {
                    _selectedDuration = Duration(minutes: minutes);
                  }
                },
              ),
            ],
            SizedBox(height: 20),
            Text('Attach Image', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 150)
                : OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.photo),
                    label: Text('Pick Image'),
                  ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveTask,
                child: Text('Save Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
