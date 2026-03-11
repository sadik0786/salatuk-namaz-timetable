import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_latest;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:get/get.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/controllers/prayer_controller.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (Platform.isWindows) return;

    // Initialize timezones
    tz_latest.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
      debugPrint("NotificationService local timezone set to: $timeZoneName");
    } catch (e) {
      debugPrint("Error setting local timezone: $e");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload == 'stop_sound') {
          // Attempting to stop player sound if it was test sound
          Get.find<PrayerController>().stopTestSound();
          // Canceling all stops the notification-based sound on many Android versions
          await stopAllSounds();
        }
      },
    );

    // Permissions
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  static Future<void> schedulePrayerNotifications({
    required Map<String, String> azanTimings,
    required Map<String, String> jamaatTimings,
  }) async {
    if (Platform.isWindows) return;

    // Clear existing notifications
    await _notificationsPlugin.cancelAll();

    final isRingEnabled = await SettingsService.isRingAtAdhanEnabled();
    if (!isRingEnabled) {
      debugPrint("Ring at adhan disabled, skipping notification scheduling.");
      return;
    }

    final prayerNotifications = await SettingsService.getPrayerNotifications();

    // Channel creation (v6)
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'salatuk_azan_v6',
          'Azan Alerts',
          description: 'Loud azan alerts at prayer times',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound('azan'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'salatuk_beep_v6',
          'Jamaat Alerts',
          description: 'Beep alerts for jamaat times',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound('beep'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );
    }

    // List of prayers to schedule
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (var prayer in prayers) {
      if (prayerNotifications[prayer] == true) {
        // Schedule Azan
        final azanTime = azanTimings[prayer];
        if (azanTime != null && azanTime != 'N/A' && azanTime.isNotEmpty) {
          await _scheduleNotification(
            id: _getPrayerId(prayer, isAzan: true),
            title: "Azan: $prayer".tr,
            body: "It's time for $prayer prayer".tr,
            timeStr: azanTime,
            soundFile: 'azan',
            channelId: 'salatuk_azan_v6',
          );
        }

        // Schedule Jamaat
        final jamaatTime = jamaatTimings[prayer];
        if (jamaatTime != null && jamaatTime != 'N/A' && jamaatTime.isNotEmpty) {
          await _scheduleNotification(
            id: _getPrayerId(prayer, isAzan: false),
            title: "Jamaat: $prayer".tr,
            body: "Jamaat for $prayer is starting soon".tr,
            timeStr: jamaatTime,
            soundFile: 'beep',
            channelId: 'salatuk_beep_v6',
          );
        }
      }
    }
  }

  static Future<void> stopAllSounds() async {
    // This cancels notifications which stops the associated sound on many Android versions
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String timeStr,
    required String soundFile,
    required String channelId,
  }) async {
    try {
      final now = DateTime.now();
      // Parse time more robustly
      final cleanTime = timeStr.trim().split(' ')[0];
      final timeParts = cleanTime.split(':');
      if (timeParts.length < 2) return;

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      // Handle AM/PM if present
      if (timeStr.toLowerCase().contains('pm') && hour < 12) hour += 12;
      if (timeStr.toLowerCase().contains('am') && hour == 12) hour = 0;

      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      // If already passed today, set to tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelId.contains('azan') ? 'Azan' : 'Jamaat',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound(soundFile),
        playSound: true,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        fullScreenIntent: true,
        ongoing: true, // This helps keep it visible for the user to tap
        autoCancel: true,
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'stop_sound',
      );
      debugPrint("Schedule successful: $title at $scheduledDate");
    } catch (e) {
      debugPrint("Scheduling failed for $title: $e");
    }
  }

  static int _getPrayerId(String prayer, {required bool isAzan}) {
    int base = isAzan ? 1000 : 2000;
    switch (prayer) {
      case 'Fajr':
        return base + 1;
      case 'Dhuhr':
        return base + 2;
      case 'Asr':
        return base + 3;
      case 'Maghrib':
        return base + 4;
      case 'Isha':
        return base + 5;
      default:
        return base;
    }
  }
}
