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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await initializeDateFormatting();
  await SettingsService.loadThemeMode();
  await SettingsService.loadLanguage();

  // Initialize Controllers and Services
  Get.put(PrayerController());
  Get.put(ConnectivityService());

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
              supportedLocales: const [Locale('en'), Locale('ur'), Locale('ar'), Locale('hi')],
              themeMode: currentThemeMode,
              darkTheme: AppTheme.darkTheme,
              theme: AppTheme.lightTheme,
              builder: (context, widget) {
                return Directionality(textDirection: TextDirection.ltr, child: widget!);
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
