class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? scheduledStart;
  final Duration? scheduledDuration;
  final String categoryId;
  final bool isDone;
  final bool isArchived;
  final String? imagePath; // optional image
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final String modifiedBy; // device/user id for sync
  final int version;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.scheduledStart,
    this.scheduledDuration,
    required this.categoryId,
    this.isDone = false,
    this.isArchived = false,
    this.imagePath,
    required this.createdAt,
    required this.lastModifiedAt,
    required this.modifiedBy,
    this.version = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduled_start': scheduledStart?.millisecondsSinceEpoch,
      'scheduled_duration': scheduledDuration?.inMinutes,
      'category_id': categoryId,
      'is_done': isDone ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'image_path': imagePath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_modified_at': lastModifiedAt.millisecondsSinceEpoch,
      'modified_by': modifiedBy,
      'version': version,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      scheduledStart: map['scheduled_start'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduled_start'])
          : null,
      scheduledDuration: map['scheduled_duration'] != null
          ? Duration(minutes: map['scheduled_duration'])
          : null,
      categoryId: map['category_id'],
      isDone: map['is_done'] == 1,
      isArchived: map['is_archived'] == 1,
      imagePath: map['image_path'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      lastModifiedAt: DateTime.fromMillisecondsSinceEpoch(map['last_modified_at']),
      modifiedBy: map['modified_by'],
      version: map['version'],
    );
  }
}