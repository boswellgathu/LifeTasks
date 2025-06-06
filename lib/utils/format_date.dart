import 'package:intl/intl.dart';

String formatDateTime(DateTime dt) {
  return DateFormat('MMM d, yyyy — h:mm a').format(dt);
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  String hoursPart = '';
  String minutesPart = '';

  if (hours > 0) {
    hoursPart = '$hours ${hours == 1 ? 'hour' : 'hours'}';
  }

  if (minutes > 0) {
    minutesPart = '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
  }

  if (hours > 0 && minutes > 0) {
    return '$hoursPart $minutesPart'; // e.g., 1 hour 30 minutes
  } else if (hours > 0) {
    return hoursPart; // e.g., 2 hours
  } else if (minutes > 0) {
    return minutesPart; // e.g., 45 minutes
  } else {
    return '0 minutes'; // Fallback
  }
}
