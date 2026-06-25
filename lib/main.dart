import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:namaz_timetable/screens/splash_screen.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/controllers/prayer_controller.dart';
import 'package:namaz_timetable/services/notification_service.dart';
import 'package:namaz_timetable/services/connectivity_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:hijri/hijri_calendar.dart';
import 'package:namaz_timetable/services/prayer_time_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      
      final manualJamaats = await SettingsService.getManualJamaatTimes();
      final location = await SettingsService.getLocation();
      
      String city = location['city'] ?? "Mumbai";
      String country = location['country'] ?? "India";
      
      final prayerService = PrayerTimeService(city: city, country: country);
      prayerService.updateLocation(
        city,
        country,
        newLat: location['latitude'] as double?,
        newLng: location['longitude'] as double?,
      );
      prayerService.calculationMethod = location['calculationMethod'];
      prayerService.asrMethod = location['asrMethod'];
      prayerService.hijriOffset = location['hijriOffset'] ?? 0;
      
      final apiModel = await prayerService.getPrayerTimes();
      
      final finalJamaats = Map<String, String>.from(apiModel.jamaatTimes);
      manualJamaats.forEach((key, value) {
        if (value.isNotEmpty && value != 'N/A') finalJamaats[key] = value;
      });
      
      final now = DateTime.now();
      const order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
      String nextPrayer = 'Fajr';
      
      for (final prayer in order) {
        final jTimeStr = finalJamaats[prayer];
        if (jTimeStr == null || jTimeStr == 'N/A' || jTimeStr.isEmpty) continue;
        
        final cleanTime = jTimeStr.split(' ')[0];
        final parts = cleanTime.split(':');
        if (parts.length < 2) continue;
        
        final jamaatTime = DateTime(
          now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]),
        );
        final displayBuffer = jamaatTime.add(const Duration(minutes: 2));
        
        if (now.isBefore(displayBuffer)) {
          nextPrayer = prayer;
          break;
        }
      }
      
      final nextJamaatTime = finalJamaats[nextPrayer] ?? "N/A";
      
      String formattedTime = nextJamaatTime;
      String amPm = "";
      if (formattedTime != "N/A" && formattedTime.isNotEmpty) {
        final cleanTime = formattedTime.split(' ')[0];
        final parts = cleanTime.split(':');
        final dt = DateTime(
          now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]),
        );
        final full12h = DateFormat.jm().format(dt); 
        final timeParts = full12h.split(' ');
        formattedTime = timeParts[0];
        if (timeParts.length > 1) amPm = timeParts[1];
      }
      
      int offset = prayerService.hijriOffset;
      final adjustedDate = DateTime.now().add(Duration(days: offset));
      final hNow = HijriCalendar.fromDate(adjustedDate);
      String hijriDate = "${hNow.hDay} ${hNow.longMonthName} (${hNow.hMonth}) ${hNow.hYear}";
      if (hNow.hMonth == 9) hijriDate = "${hNow.hDay} Ramzan (9) ${hNow.hYear}";
      
      await HomeWidget.saveWidgetData<String>('prayer_name', nextPrayer);
      await HomeWidget.saveWidgetData<String>('prayer_time', formattedTime);
      await HomeWidget.saveWidgetData<String>('prayer_am_pm', amPm);
      await HomeWidget.saveWidgetData<String>('hijri_date', hijriDate);
      
      await HomeWidget.updateWidget(name: 'PrayerWidgetProvider', iOSName: 'PrayerWidgetProvider');
      await HomeWidget.updateWidget(name: 'PrayerWidgetProviderLight');
      await HomeWidget.updateWidget(name: 'PrayerWidgetProviderGlass');
      
    } catch (e) {
      debugPrint("Workmanager error: $e");
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await initializeDateFormatting();
  await SettingsService.loadThemeMode();
  await SettingsService.loadLanguage();

  // Initialize Controllers and Services
  Get.put(PrayerController());
  Get.put(ConnectivityService());

  // Initialize WorkManager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  
  Workmanager().registerPeriodicTask(
    "salatukWidgetUpdate",
    "widgetUpdateTask",
    frequency: const Duration(minutes: 15),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: SettingsService.themeNotifier,
          builder: (context, currentThemeMode, _) {
            return GetMaterialApp(
              title: 'Salatuk',
              debugShowCheckedModeBanner: false,
              translations: AppTranslations(),
              locale: _getLocale(),
              fallbackLocale: const Locale('en'),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ur'),
                Locale('ar'),
                Locale('hi'),
              ],
              themeMode: currentThemeMode,
              darkTheme: AppTheme.darkTheme,
              theme: AppTheme.lightTheme,
              defaultTransition: Transition.cupertino,
              transitionDuration: const Duration(milliseconds: 400),
              builder: (context, widget) {
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: widget!,
                );
              },
              home: child,
            );
          },
        );
      },
      child: const SplashScreen(),
    );
  }

  Locale _getLocale() {
    final lang = SettingsService.languageNotifier.value;
    if (lang == 'Urdu') return const Locale('ur');
    if (lang == 'Hindi') return const Locale('hi');
    if (lang == 'Arabic') return const Locale('ar');
    return const Locale('en');
  }
}
