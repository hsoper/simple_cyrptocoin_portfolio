import 'package:shared_preferences/shared_preferences.dart';

// Reusing the SessionManager class from the Webservices lecture.
class SessionManager {
  static const String _lastUpdate = 'lastUpdate';

  static Future<bool> isLate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdate);
    return lastUpdate == null;
  }

  static bool isOutdated(int microseconds) {
    return DateTime.fromMicrosecondsSinceEpoch(microseconds, isUtc: false)
            .difference(DateTime.now())
            .inMinutes >
        5;
  }

  static String formatDateTime(DateTime time) {
    return "${time.month}/${time.day}/${time.year} - ${formatTime(time.hour, time.minute, time.second)}";
  }

  static String formatTime(int hour, int minute, int seconds) {
    if (hour == 0) {
      return "12:${minute < 10 ? '0$minute' : '$minute'}:${seconds < 10 ? '0$seconds' : '$seconds'} AM";
    } else if (hour > 11) {
      return "${hour == 12 ? 12 : hour - 12}:${minute < 10 ? '0$minute' : '$minute'}:${seconds < 10 ? '0$seconds' : '$seconds'} PM";
    }
    return "$hour:${minute < 10 ? '0$minute' : '$minute'}:${seconds < 10 ? '0$seconds' : '$seconds'} AM";
  }

  static Future<DateTime> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    int? lu = prefs.getInt(_lastUpdate);
    return DateTime.fromMicrosecondsSinceEpoch(lu!, isUtc: false);
  }

  static Future<void> setLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastUpdate, DateTime.now().microsecondsSinceEpoch);
  }
}
