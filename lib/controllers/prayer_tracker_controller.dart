import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class PrayerTrackerController extends GetxController {
  var selectedDate = DateTime.now().obs;
  var prayerStatus = <String, bool>{
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadDayData(selectedDate.value);
  }

  String _getDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> loadDayData(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDateKey(date);
    final jsonStr = prefs.getString('prayer_log_$key');

    if (jsonStr != null) {
      final Map<String, dynamic> data = json.decode(jsonStr);
      prayerStatus.value = data.map((key, value) => MapEntry(key, value as bool));
    } else {
      prayerStatus.value = {
        'Fajr': false,
        'Dhuhr': false,
        'Asr': false,
        'Maghrib': false,
        'Isha': false,
      };
    }
  }

  Future<void> togglePrayer(String prayer) async {
    prayerStatus[prayer] = !(prayerStatus[prayer] ?? false);
    await _saveCurrentDay();
  }

  Future<void> _saveCurrentDay() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDateKey(selectedDate.value);
    await prefs.setString('prayer_log_$key', json.encode(prayerStatus));
  }

  void changeDate(DateTime date) {
    selectedDate.value = date;
    loadDayData(date);
  }
}
