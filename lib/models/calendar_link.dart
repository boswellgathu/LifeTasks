class CalendarLink {
  final String taskId;
  final String googleEventId;
  final DateTime syncedAt;

  CalendarLink({
    required this.taskId,
    required this.googleEventId,
    required this.syncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'google_event_id': googleEventId,
      'synced_at': syncedAt.millisecondsSinceEpoch,
    };
  }

  factory CalendarLink.fromMap(Map<String, dynamic> map) {
    return CalendarLink(
      taskId: map['task_id'],
      googleEventId: map['google_event_id'],
      syncedAt: DateTime.fromMillisecondsSinceEpoch(map['synced_at']),
    );
  }
}