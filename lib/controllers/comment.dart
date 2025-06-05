import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../repositories/comment.dart';

class CommentController with ChangeNotifier {
  final CommentRepository _commentRepository = CommentRepository();

  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _error;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all comments for a specific task
  Future<void> loadCommentsForTask(String taskId) async {
    _setLoading(true);
    try {
      _comments = await _commentRepository.getCommentsForTask(taskId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load comments';
    } finally {
      _setLoading(false);
    }
  }

  // Add a new comment
  Future<void> addComment(Comment comment) async {
    try {
      await _commentRepository.insertComment(comment);
      _comments.add(comment);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add comment';
    }
  }

  // Update an existing comment
  Future<void> updateComment(Comment updatedComment) async {
    try {
      await _commentRepository.updateComment(updatedComment);
      final index = _comments.indexWhere((c) => c.id == updatedComment.id);
      if (index != -1) {
        _comments[index] = updatedComment;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update comment';
    }
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _commentRepository.deleteComment(commentId);
      _comments.removeWhere((comment) => comment.id == commentId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete comment';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}