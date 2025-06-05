class Comment {
  final String id;
  final String taskId;
  final String content;          // Text content (can be empty if only a photo)
  final String? imagePath;       // Optional image (local file path or cloud URL)
  final String authorId;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.taskId,
    required this.content,
    this.imagePath,
    required this.authorId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'content': content,
      'image_path': imagePath,
      'author_id': authorId,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      taskId: map['task_id'],
      content: map['content'],
      imagePath: map['image_path'],
      authorId: map['author_id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}