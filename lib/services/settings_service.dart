import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _cityKey = 'city';
  static const String _countryKey = 'country';
  static const String _areaKey = 'area';
  static const String _stateKey = 'state';
  static const String _pincodeKey = 'pincode';
  static const String _latKey = 'latitude';
  static const String _lngKey = 'longitude';
  static const String _calcMethodKey = 'calculation_method';
  static const String _asrMethodKey = 'asr_method';
  static const String _hijriOffsetKey = 'hijri_offset';

  static const _manualTimesKey = 'manual_prayer_times';
  static const _manualJamaatKey = 'manual_jamaat_times';
  static const _ringAtAdhanKey = 'ring_at_adhan';
  static const _isDarkModeKey = 'is_dark_mode';
  static const _languageKey = 'app_language';
  static const _tasbihTotalKey = 'tasbih_total_count';
  static const _showAdvancedCalcKey = 'show_advanced_calc';

  static final ValueNotifier<String> onLocationChanged = ValueNotifier<String>("");
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('English');
  static final ValueNotifier<int> onSettingsChanged = ValueNotifier<int>(0);

  static Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_isDarkModeKey) ?? true;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDark);
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    languageNotifier.value = prefs.getString(_languageKey) ?? 'English';
  }

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    languageNotifier.value = language;

    // Update GetX Locale instantly
    Locale locale = const Locale('en');
    if (language == 'Urdu') locale = const Locale('ur');
    if (language == 'Hindi') locale = const Locale('hi');
    if (language == 'Arabic') locale = const Locale('ar');

    Get.updateLocale(locale);
  }

  static Future<bool> isDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkModeKey) ?? true;
  }

  /// LOCATION & API PARAMS
  static Future<void> saveLocation(
    String city,
    String country, {
    double? latitude,
    double? longitude,
    String? area,
    String? state,
    String? pincode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, city);
    await prefs.setString(_countryKey, country);

    if (area != null) {
      await prefs.setString(_areaKey, area);
    } else {
      await prefs.remove(_areaKey);
    }
    if (state != null) {
      await prefs.setString(_stateKey, state);
    } else {
      await prefs.remove(_stateKey);
    }
    if (pincode != null) {
      await prefs.setString(_pincodeKey, pincode);
    } else {
      await prefs.remove(_pincodeKey);
    }

    if (latitude != null) {
      await prefs.setDouble(_latKey, latitude);
    } else {
      await prefs.remove(_latKey);
    }

    if (longitude != null) {
      await prefs.setDouble(_lngKey, longitude);
    } else {
      await prefs.remove(_lngKey);
    }

    onLocationChanged.value = "$city|$country|${DateTime.now().millisecondsSinceEpoch}";
  }

  static Future<Map<String, dynamic>> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'area': prefs.getString(_areaKey) ?? '',
      'city': prefs.getString(_cityKey) ?? 'Mumbai',
      'state': prefs.getString(_stateKey) ?? '',
      'country': prefs.getString(_countryKey) ?? 'India',
      'pincode': prefs.getString(_pincodeKey) ?? '',
      'latitude': prefs.getDouble(_latKey),
      'longitude': prefs.getDouble(_lngKey),
      'calculationMethod': prefs.getInt(_calcMethodKey) ?? 1, // 1 = Karachi
      'asrMethod': prefs.getInt(_asrMethodKey) ?? 1, // 1 = Hanafi
      'hijriOffset': prefs.getInt(_hijriOffsetKey) ?? -1,
    };
  }

  static Future<void> saveApiSettings({
    int? calculationMethod,
    int? asrMethod,
    int? hijriOffset,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (calculationMethod != null) await prefs.setInt(_calcMethodKey, calculationMethod);
    if (asrMethod != null) await prefs.setInt(_asrMethodKey, asrMethod);
    if (hijriOffset != null) await prefs.setInt(_hijriOffsetKey, hijriOffset);
    onLocationChanged.value = "api_settings_changed|${DateTime.now().millisecondsSinceEpoch}";
  }

  /// ADVANCED CALCULATION
  static Future<void> setShowAdvancedCalculation(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showAdvancedCalcKey, enabled);
  }

  static Future<bool> isShowAdvancedCalculationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showAdvancedCalcKey) ?? false;
  }

  /// NOTIFICATION SETTINGS
  static Future<void> setRingAtAdhan(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ringAtAdhanKey, enabled);
  }

  static Future<bool> isRingAtAdhanEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ringAtAdhanKey) ?? true;
  }

  static Future<Map<String, bool>> getPrayerNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final master = prefs.getBool('show_prayer_notifications') ?? false;
    return {
      'Fajr': master && (prefs.getBool('Fajr') ?? true),
      'Dhuhr': master && (prefs.getBool('Dhuhr') ?? true),
      'Asr': master && (prefs.getBool('Asr') ?? true),
      'Maghrib': master && (prefs.getBool('Maghrib') ?? true),
      'Isha': master && (prefs.getBool('Isha') ?? true),
      'Jumah': master && (prefs.getBool('Dhuhr') ?? true), // Maps to Dhuhr naturally
    };
  }

  /// MANUAL PRAYER TIMES
  static Future<void> saveManualPrayerTime(String prayer, String time) async {
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getStringList(_manualTimesKey) ?? [];

    final updated = {for (var e in map) e.split('|')[0]: e.split('|')[1], prayer: time};

    await prefs.setStringList(
      _manualTimesKey,
      updated.entries.map((e) => '${e.key}|${e.value}').toList(),
    );
  }

  static Future<Map<String, String>> getManualPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_manualTimesKey) ?? [];
    return {for (var e in list) e.split('|')[0]: e.split('|')[1]};
  }

  static Future<void> saveManualJamaatTime(String prayer, String time) async {
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getStringList(_manualJamaatKey) ?? [];
    final updated = {for (var e in map) e.split('|')[0]: e.split('|')[1], prayer: time};
    await prefs.setStringList(
      _manualJamaatKey,
      updated.entries.map((e) => '${e.key}|${e.value}').toList(),
    );
  }

  static Future<Map<String, String>> getManualJamaatTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_manualJamaatKey) ?? [];
    return {for (var e in list) e.split('|')[0]: e.split('|')[1]};
  }

  static Future<void> clearManualOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_manualTimesKey);
    await prefs.remove(_manualJamaatKey);
  }

  static Future<void> saveTasbihTotalCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tasbihTotalKey, count);
  }

  static Future<int> getTasbihTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tasbihTotalKey) ?? 0;
  }
}
