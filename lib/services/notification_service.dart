import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_latest;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:get/get.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/controllers/prayer_controller.dart';
import 'package:app_settings/app_settings.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (Platform.isWindows) return;

    // Initialize timezones
    tz_latest.initializeTimeZones();
    try {
      String timeZoneName = (await FlutterTimezone.getLocalTimezone()).toString();
      
      // If detected as UTC but we are in a typical user's region (India for this app),
      // we can attempt to be smarter or just log it.
      // But first, let's try to set it.
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      // If it's still UTC after detection, it might be a library quirk.
      if (tz.local.name == 'UTC') {
        // We can try to guess or use a very common one like Asia/Kolkata
        // for this specific user's target audience if detection fails.
        try {
           tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
           debugPrint("UTC detected, forced fallback to Asia/Kolkata");
        } catch(_) {}
      }
      
      debugPrint("NotificationService local timezone set to: ${tz.local.name}");
    } catch (e) {
      debugPrint("Error setting local timezone: $e");
      // Fallback to Asia/Kolkata if possible
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      } catch(_) {}
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload == 'stop_sound' || details.actionId == 'stop_azan') {
          // Attempting to stop player sound if it was test sound
          if (Get.isRegistered<PrayerController>()) {
            Get.find<PrayerController>().stopTestSound();
          }
          // Canceling only this specific notification stops its sound
          // without clearing the future schedule for other prayers.
          if (details.id != null) {
            await _notificationsPlugin.cancel(id: details.id!);
          }
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

  static Future<void> requestBatteryOptimization() async {
    if (Platform.isAndroid) {
      try {
        await AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
      } catch (e) {
        debugPrint("Error opening battery settings: $e");
      }
    }
  }

  static Future<bool> isExactAlarmPermissionGranted() async {
    if (Platform.isAndroid) {
      final plugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await plugin?.canScheduleExactNotifications() ?? false;
    }
    return true;
  }

  static Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      try {
        await AppSettings.openAppSettings(type: AppSettingsType.alarm);
      } catch (e) {
        debugPrint("Error opening alarm settings: $e");
      }
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

    // Channel creation (v50 - recreation forced for sound fix)
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      // Delete ALL old channels to clear any stuck sound settings
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_azan_v12');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_beep_v12');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_azan_v20');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_beep_v20');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_azan_v30');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_beep_v30');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_azan_v40');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_beep_v40');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_azan_v50');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_beep_v50');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_azan_final_v1');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_beep_final_v1');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_azan_final_v2');
      await androidPlugin?.deleteNotificationChannel(channelId: 'salatuk_beep_final_v2');

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'salatuk_azan_v51',
          'Azan Notifications',
          description: 'Loud alerts for Azan',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound('azan'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          enableVibration: true,
          showBadge: true,
        ),
      );

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'salatuk_beep_v51',
          'Jamaat Notifications',
          description: 'Beep alerts for Jamaat',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound('beep'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          enableVibration: true,
          showBadge: true,
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
            channelId: 'salatuk_azan_v51',
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
            channelId: 'salatuk_beep_v51',
          );
        }
      }
    }
  }

  static Future<void> testNotification() async {
    Get.snackbar("Test Started", "Closing app/Locking screen is recommended. Notification in 5s.",
        snackPosition: SnackPosition.BOTTOM);

    // Using a simple Timer + Direct show to verify sound resource
    Future.delayed(const Duration(seconds: 5), () async {
      final androidDetails = AndroidNotificationDetails(
        'salatuk_azan_v51',
        'Azan Notifications',
        channelDescription: 'Loud alerts for Azan',
        importance: Importance.max,
        priority: Priority.max,
        sound: const RawResourceAndroidNotificationSound('azan'),
        playSound: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );

      await _notificationsPlugin.show(
        id: 9999,
        title: "Test Azan Result",
        body: "If you hear this, sound is working perfectly.",
        notificationDetails: NotificationDetails(android: androidDetails),
      );
    });
  }

  static Future<void> stopAllSounds() async {
    // This is now primarily for forced stops. 
    // We avoid cancelAll() to preserve future prayer schedules.
    // Instead, we just cancel the standard prayer IDs.
    for (int i = 1001; i <= 1005; i++) {
      await _notificationsPlugin.cancel(id: i);
    }
    for (int i = 2001; i <= 2005; i++) {
      await _notificationsPlugin.cancel(id: i);
    }
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

      // Buffer: If the time is within the current minute or the future, fire today.
      // If it's more than 1 minute in the past, schedule for tomorrow.
      if (scheduledDate.isBefore(now.subtract(const Duration(minutes: 1)))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelId.contains('azan') ? 'Azan' : 'Jamaat',
        channelDescription: 'Prayer alerts',
        importance: Importance.max,
        priority: Priority.max,
        sound: RawResourceAndroidNotificationSound(soundFile),
        playSound: true,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        ticker: title,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        ongoing: false,
        autoCancel: true,
        timeoutAfter: 180000,
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
      debugPrint("Schedule successful: $title at $scheduledDate (TZ: ${tz.local.name})");
    } catch (e) {
      debugPrint("Scheduling failed for $title: $e");
    }
  }

  static Future<Map<String, bool>> checkPermissionStatus() async {
    bool exact = await isExactAlarmPermissionGranted();
    // For general notification permission, we'd need another call, 
    // but usually exact is the tricky one.
    return {'exact_alarm': exact};
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
