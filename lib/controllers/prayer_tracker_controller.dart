import 'dart:async';
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

  final RxInt currentQuoteIndex = 0.obs;
  Timer? _quoteTimer;

  final List<Map<String, String>> prayerQuotes = [
    {
      "quote": "Whoever performs Fajr prayer is under the protection of Allah.",
      "reference": "- Benefit of Fajr (Sahih Muslim)",
    },
    {
      "quote":
          "Dhuhr is an hour when the gates of heaven are opened, and I love that a good deed of mine should ascend then.",
      "reference": "- Benefit of Dhuhr (Tirmidhi)",
    },
    {
      "quote": "He who performs the Asr prayer will enter Paradise.",
      "reference": "- Benefit of Asr (Sahih Bukhari)",
    },
    {
      "quote": "He who hastens to pray Maghrib is forgiven by Allah.",
      "reference": "- Benefit of Maghrib",
    },
    {
      "quote":
          "Whoever offers Isha in congregation, it is as if he spent half the night in worship.",
      "reference": "- Benefit of Isha (Sahih Muslim)",
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadDayData(selectedDate.value);
    _startQuoteTimer();
  }

  void _startQuoteTimer() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      currentQuoteIndex.value =
          (currentQuoteIndex.value + 1) % prayerQuotes.length;
    });
  }

  @override
  void onClose() {
    _quoteTimer?.cancel();
    super.onClose();
  }

  String _getDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> loadDayData(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDateKey(date);
    final jsonStr = prefs.getString('prayer_log_$key');

    if (jsonStr != null) {
      final Map<String, dynamic> data = json.decode(jsonStr);
      prayerStatus.value = data.map(
        (key, value) => MapEntry(key, value as bool),
      );
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
