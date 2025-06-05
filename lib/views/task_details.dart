import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../controllers/task.dart';
import '../controllers/comment.dart';
import '../models/comment.dart';
import 'package:uuid/uuid.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  TaskDetailScreenState createState() => TaskDetailScreenState();
}

class TaskDetailScreenState extends State<TaskDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load comments for this task
    final commentController = Provider.of<CommentController>(context, listen: false);
    commentController.loadCommentsForTask(widget.task.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: const Uuid().v4(),
      taskId: widget.task.id,
      content: _commentController.text.trim(),
      imagePath: null, // Optionally add photo support
      authorId: 'local-device', // Replace with actual device/user id
      timestamp: DateTime.now(),
    );

    final commentController = Provider.of<CommentController>(context, listen: false);
    await commentController.addComment(newComment);

    _commentController.clear();
  }

  void _toggleTaskDone() async {
    final taskController = Provider.of<TaskController>(context, listen: false);
    final updatedTask = widget.task.copyWith(isDone: !widget.task.isDone);

    await taskController.updateTask(updatedTask);

    if (!mounted) return;
    Navigator.pop(context); // After update, go back to task list
  }

  void _deleteTask() async {
    final taskController = Provider.of<TaskController>(context, listen: false);
    await taskController.deleteTask(widget.task.id);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final commentController = Provider.of<CommentController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteTask,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (widget.task.scheduledStart != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16),
                  SizedBox(width: 6),
                  Text('${widget.task.scheduledStart!.toLocal()}'),
                ],
              ),
            ],
            if (widget.task.scheduledDuration != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16),
                  SizedBox(width: 6),
                  Text('${widget.task.scheduledDuration!.inMinutes} mins'),
                ],
              ),
            ],
            SizedBox(height: 8),
            Chip(
              label: Text(widget.task.categoryId), // Later, map category ID to name
              backgroundColor: Colors.blue.shade100,
            ),
            SizedBox(height: 16),
            if (widget.task.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(widget.task.imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            if (widget.task.description != null)
              Text(
                widget.task.description!,
                style: TextStyle(fontSize: 16),
              ),
            Divider(height: 40),
            Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            commentController.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: commentController.comments.length,
              itemBuilder: (context, index) {
                final comment = commentController.comments[index];
                return ListTile(
                  title: Text(comment.content),
                  subtitle: Text(
                    '${comment.timestamp.toLocal()}',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _toggleTaskDone,
                child: Text(widget.task.isDone ? 'Mark as Undone' : 'Mark as Done'),
              ),
            )
          ],
        ),
      ),
    );
  }
}