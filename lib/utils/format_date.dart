String formatDateTime(DateTime dt) {
  return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours > 0) {
    if (minutes > 0) {
      return '$hours hr $minutes min';
    } else {
      return '$hours hr';
    }
  } else {
    return '$minutes min';
  }
}
