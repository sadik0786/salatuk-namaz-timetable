import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:namaz_timetable/utils/time_utils.dart';
import 'package:namaz_timetable/config/api_config.dart';
import 'package:namaz_timetable/models/prayer_times_model.dart';

class PrayerTimeService {
  String city;
  String country;
  double? latitude;
  double? longitude;
  int calculationMethod;
  int asrMethod; // 0 = Shafi'i, 1 = Hanafi
  int hijriOffset;

  PrayerTimeService({
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
    this.calculationMethod = 1, // Default to Karachi
    this.asrMethod = 1, // Default to Hanafi
    this.hijriOffset = 0,
  });

  void updateLocation(String newCity, String newCountry, {double? newLat, double? newLng}) {
    city = newCity;
    country = newCountry;
    if (newLat != null) latitude = newLat;
    if (newLng != null) longitude = newLng;
  }

  Future<PrayerTimesModel> getPrayerTimes() async {
    return _getApiPrayerTimes();
  }

  /// MANUAL END TIMES
  Map<String, String> _calculateEndTimes(Map<String, String> timings) {
    return {
      'Fajr': timings['Sunrise'] ?? timings['Dhuhr'] ?? 'N/A',
      'Dhuhr': timings['Asr'] ?? 'N/A',
      'Asr': timings['Maghrib'] ?? 'N/A',
      'Maghrib': timings['Isha'] ?? 'N/A',
      'Isha': timings['Midnight'] ?? timings['Fajr'] ?? 'N/A',
    };
  }

  /// API MODE
  Future<PrayerTimesModel> _getApiPrayerTimes() async {
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    Uri url;

    // Use precise location (lat, lon) for highest accuracy, same as "We Muslim" app
    if (latitude != null && longitude != null) {
      url = Uri.parse(
        ApiConfig.timingsByLocation(
          today,
          latitude!,
          longitude!,
          calculationMethod,
          asrMethod,
          hijriOffset,
        ),
      );
    } else {
      url = Uri.parse(
        ApiConfig.timingsByCity(today, city, country, calculationMethod, asrMethod, hijriOffset),
      );
    }

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch prayer times');
    }

    final data = json.decode(response.body)['data'];
    final timings = Map<String, String>.from(data['timings']);

    final jamaatTimes = _calculateJamaatTimes(timings);
    final endTimes = _calculateEndTimes(timings);

    final hijriData = data['date']['hijri'];
    final formattedHijri =
        "${hijriData['day']} ${hijriData['month']['en']} ${hijriData['month']['number']} ${hijriData['year']}";

    return PrayerTimesModel(
      timings: timings,
      jamaatTimes: jamaatTimes,
      endTimes: endTimes,
      hijri: formattedHijri,
    );
  }

  /// JAMAT TIME LOGIC
  Map<String, String> _calculateJamaatTimes(Map<String, String> timings) {
    const delays = {'Fajr': 10, 'Dhuhr': 10, 'Asr': 10, 'Maghrib': 5, 'Isha': 10};

    final result = <String, String>{};

    for (final prayer in delays.keys) {
      final time = timings[prayer];
      if (time != null) {
        result[prayer] = addMinutes(time, delays[prayer]!);
      }
    }

    result['Jumah'] = result['Dhuhr'] ?? 'N/A';
    return result;
  }

  /// NEXT PRAYER
  String getNextPrayer(Map<String, String> timings) {
    final now = DateTime.now();
    const order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (final prayer in order) {
      final t = timings[prayer];
      if (t == null) continue;

      final parsed = DateFormat('HH:mm').parse(t);
      final prayerTime = DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);

      if (now.isBefore(prayerTime)) return prayer;
    }

    return 'Fajr (Next Day)';
  }
}
