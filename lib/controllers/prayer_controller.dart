import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namaz_timetable/models/prayer_times_model.dart';
import 'package:namaz_timetable/services/prayer_time_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/services/notification_service.dart';
import 'package:audioplayers/audioplayers.dart';

class PrayerController extends GetxController {
  final _prayerService = PrayerTimeService(city: "Mumbai", country: "India");
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _nextPrayerTimer;

  var isLoading = true.obs;
  var prayerTimes = Rxn<PrayerTimesModel>();
  var nextPrayer = "".obs;
  var nextJamaatTime = "".obs;
  var hijriOffset = 0.obs;

  // Cache for manual overrides
  var manualAzans = <String, String>{}.obs;
  var manualJamaats = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // Configure audio context once at startup
    AudioPlayer.global.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.duckOthers, AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );

    // Initial load
    refreshPrayerTimes();

    // Listen to location changes
    SettingsService.onLocationChanged.addListener(_onLocationChanged);

    // Periodic timer to update next prayer status every minute
    _nextPrayerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateNextPrayer();
    });
  }

  @override
  void onClose() {
    SettingsService.onLocationChanged.removeListener(_onLocationChanged);
    _nextPrayerTimer?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }

  void _onLocationChanged() {
    refreshPrayerTimes();
  }

  Future<void> refreshPrayerTimes() async {
    try {
      isLoading(true);

      // Load manual overrides from SharedPreferences
      manualAzans.value = await SettingsService.getManualPrayerTimes();
      manualJamaats.value = await SettingsService.getManualJamaatTimes();

      // Get latest location
      final location = await SettingsService.getLocation();
      _prayerService.updateLocation(
        location['city'],
        location['country'],
        newLat: location['latitude'] as double?,
        newLng: location['longitude'] as double?,
      );
      _prayerService.calculationMethod = location['calculationMethod'];
      _prayerService.asrMethod = location['asrMethod'];
      _prayerService.hijriOffset = location['hijriOffset'];
      hijriOffset.value = location['hijriOffset'];

      // Fetch API times
      final apiModel = await _prayerService.getPrayerTimes();

      // Merge overrides
      final finalTimings = Map<String, String>.from(apiModel.timings);
      manualAzans.forEach((key, value) {
        if (value.isNotEmpty && value != 'N/A') finalTimings[key] = value;
      });

      final finalJamaats = Map<String, String>.from(apiModel.jamaatTimes);
      manualJamaats.forEach((key, value) {
        if (value.isNotEmpty && value != 'N/A') finalJamaats[key] = value;
      });

      prayerTimes.value = PrayerTimesModel(
        timings: finalTimings,
        jamaatTimes: finalJamaats,
        endTimes: apiModel.endTimes,
        hijri: apiModel.hijri,
      );

      // Re-schedule notifications
      NotificationService.schedulePrayerNotifications(
        azanTimings: finalTimings,
        jamaatTimings: finalJamaats,
      );

      _updateNextPrayer();
    } catch (e) {
      debugPrint("Error in PrayerController refresh: $e");
    } finally {
      isLoading(false);
    }
  }

  void _updateNextPrayer() {
    if (prayerTimes.value == null) return;

    final now = DateTime.now();
    final jamaatTimes = prayerTimes.value!.jamaatTimes;
    const order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    String? foundNext;

    for (final prayer in order) {
      final jTimeStr = jamaatTimes[prayer];
      if (jTimeStr == null || jTimeStr == 'N/A' || jTimeStr.isEmpty) continue;

      try {
        final cleanTime = jTimeStr.split(' ')[0];
        final parts = cleanTime.split(':');
        if (parts.length < 2) continue;

        final jamaatTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        // Buffer: show current prayer until 2 minutes after Jamaat
        final displayBuffer = jamaatTime.add(const Duration(minutes: 2));

        if (now.isBefore(displayBuffer)) {
          foundNext = prayer;
          break;
        }
      } catch (e) {
        debugPrint("Error parsing $prayer time: $e");
      }
    }

    // Update observables
    final newNext = foundNext ?? 'Fajr';
    if (nextPrayer.value != newNext) {
      nextPrayer.value = newNext;
    }

    final cleanName = nextPrayer.value.split(' ')[0];
    nextJamaatTime.value = jamaatTimes[cleanName] ?? "N/A";
  }

  Future<void> saveOverride(String prayer, String? azan, String? jamaat) async {
    if (azan != null) await SettingsService.saveManualPrayerTime(prayer, azan);
    if (jamaat != null) await SettingsService.saveManualJamaatTime(prayer, jamaat);

    await refreshPrayerTimes();

    Get.snackbar(
      "Updated".tr,
      "Times saved and notifications rescheduled.".tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> resetToDefault() async {
    await SettingsService.clearManualOverrides();
    await refreshPrayerTimes();
  }

  Future<void> playTestSound(String assetPath) async {
    try {
      final fileName = assetPath.contains('azan') ? "Azan" : "Beep";
      Get.snackbar(
        "Testing".tr,
        "Playing $fileName...".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 15), // Long enough to allow stopping
        mainButton: TextButton(
          onPressed: () {
            stopTestSound();
            if (Get.isSnackbarOpen) Get.back();
          },
          child: Text(
            "STOP".tr,
            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
        ),
      );

      final cleanPath = assetPath.startsWith('assets/')
          ? assetPath.replaceFirst('assets/', '')
          : assetPath;

      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(cleanPath));
    } catch (e) {
      debugPrint("Playback error: $e");
    }
  }

  Future<void> stopTestSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Error stopping sound: $e");
    }
  }
}
