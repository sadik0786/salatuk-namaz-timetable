import 'package:intl/intl.dart';

String addMinutes(String time, int minutesToAdd) {
  try {
    final cleanTime = time.split(' ')[0];
    final dt = DateFormat("HH:mm").parse(cleanTime);
    return DateFormat("HH:mm").format(dt.add(Duration(minutes: minutesToAdd)));
  } catch (_) {
    return time;
  }
}

String subtractMinutes(String time, int minutesToSubtract) {
  try {
    final cleanTime = time.split(' ')[0];
    final dt = DateFormat("HH:mm").parse(cleanTime);
    return DateFormat("HH:mm").format(dt.subtract(Duration(minutes: minutesToSubtract)));
  } catch (_) {
    return time;
  }
}

String formatAmPm(String time) {
  if (time == '-' || time == 'N/A' || time.isEmpty) return time;

  // If already formatted with am/pm, return as is (normalized to lowercase)
  if (time.toLowerCase().contains('am') || time.toLowerCase().contains('pm')) {
    return time.toLowerCase();
  }

  try {
    // some times come with (IST) e.g., "18:30 (IST)"
    final cleanTime = time.split(' ')[0];
    final dt = DateFormat("HH:mm").parse(cleanTime);
    return DateFormat("hh:mm a").format(dt).toLowerCase();
  } catch (_) {
    return time.toLowerCase();
  }
}
