import 'package:intl/intl.dart';

class DateConverter {
  static String getTimeAgo(int timestamp) {
    final DateTime dateTime = timestamp.toString().length == 13
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} m';
    } else {
      return 'now';
    }
  }

  static String formatDate(int timestamp) {
    // Se il timestamp è in millisecondi (13 cifre), lo convertiamo in secondi
    final DateTime dateTime = timestamp.toString().length == 13
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    return DateFormat('MMM d, y HH:mm').format(dateTime);
  }
}
