class ApiConfig {
  static const String baseUrl = 'https://api.aladhan.com/v1';

  static String timingsByLocation(
    String date,
    double lat,
    double lng,
    int method,
    int school,
    int adj,
  ) {
    return '$baseUrl/timings/$date?latitude=$lat&longitude=$lng&method=$method&school=$school&adj=$adj';
  }

  static String timingsByCity(
    String date,
    String city,
    String country,
    int method,
    int school,
    int adj,
  ) {
    return '$baseUrl/timingsByCity/$date?city=$city&country=$country&method=$method&school=$school&adj=$adj';
  }

  static String timingsSingleDayLocation(String date, double lat, double lng, int method) {
    return '$baseUrl/timings/$date?latitude=$lat&longitude=$lng&method=$method';
  }

  static String timingsSingleDayCity(String date, String city, String country, int method) {
    return '$baseUrl/timingsByCity/$date?city=$city&country=$country&method=$method';
  }

  static String hijriCalendarByLocation(
    int year,
    int month,
    double lat,
    double lng,
    int method,
    int adj,
  ) {
    return '$baseUrl/hijriCalendar/$year/$month?latitude=$lat&longitude=$lng&method=$method&adj=$adj';
  }

  static String hijriCalendarByCity(
    int year,
    int month,
    String city,
    String country,
    int method,
    int adj,
  ) {
    return '$baseUrl/hijriCalendarByCity/$year/$month?city=$city&country=$country&method=$method&adj=$adj';
  }
}
