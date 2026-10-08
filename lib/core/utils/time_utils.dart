import 'package:intl/intl.dart';

class TimeUtils {
  TimeUtils._();

  // Cached: DateFormat construction loads locale data and is expensive,
  // so never instantiate one inside build().
  static final _time = DateFormat('hh:mm a');
  static final _date = DateFormat('MMM dd, yyyy');
  static final _dateShort = DateFormat('MMM dd');
  static final _day = DateFormat('EEEE');
  static final _dateTime = DateFormat('MMM dd, hh:mm a');

  static String formatTime(DateTime dt) => _time.format(dt);
  static String formatDate(DateTime dt) => _date.format(dt);
  static String formatDateShort(DateTime dt) => _dateShort.format(dt);
  static String formatDay(DateTime dt) => _day.format(dt);
  static String formatDateTime(DateTime dt) => _dateTime.format(dt);

  static String timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 7) return formatDate(dt);
    if (diff.inDays > 1) return '${diff.inDays} DAYS AGO';
    if (diff.inDays == 1) return 'YESTERDAY';
    if (diff.inHours > 1) return '${diff.inHours} HOURS AGO';
    if (diff.inHours == 1) return '1 HOUR AGO';
    if (diff.inMinutes > 1) return '${diff.inMinutes} MINUTES AGO';
    return 'JUST NOW';
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
