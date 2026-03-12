import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:namaz_timetable/screens/prayer_settings_screen.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/controllers/prayer_controller.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:namaz_timetable/widgets/settings_modal.dart';
import 'package:namaz_timetable/widgets/tr_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, bool> _notifications = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  String currentCity = 'Mumbai';
  String currentCountry = 'India';
  int calculationMethod = 1; // 1 = Karachi
  int asrMethod = 1; // 1 = Hanafi
  int hijriOffset = 0;

  bool showPrayerNotifications = false;
  bool showAdvancedCalculation = false;
  bool isRingAtAdhan = true;
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications.forEach((prayer, _) {
        _notifications[prayer] = prefs.getBool(prayer) ?? true;
      });
    });

    final location = await SettingsService.getLocation();
    final loadedShowAdvanced = await SettingsService.isShowAdvancedCalculationEnabled();
    final loadedRingAtAdhan = await SettingsService.isRingAtAdhanEnabled();
    final loadedIsDarkMode = await SettingsService.isDarkModeEnabled();

    setState(() {
      showAdvancedCalculation = loadedShowAdvanced;
      isRingAtAdhan = loadedRingAtAdhan;
      isDarkMode = loadedIsDarkMode;
      currentCity = location['city'];
      currentCountry = location['country'];
      calculationMethod = location['calculationMethod'] ?? 1;
      asrMethod = location['asrMethod'] ?? 1;
      hijriOffset = location['hijriOffset'] ?? 0;
      showPrayerNotifications = prefs.getBool('show_prayer_notifications') ?? false;
    });
  }

  void _saveNotification(String prayer, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prayer, value);
    SettingsService.onSettingsChanged.value++;
    setState(() {
      _notifications[prayer] = value;
    });
    // Reschedule immediately
    Get.find<PrayerController>().refreshPrayerTimes();
  }

  void _changeLocation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SettingsModal(currentCity: currentCity, currentCountry: currentCountry),
      ),
    ).then((result) async {
      if (result != null) {
        final city = result['city'] as String;
        final country = result['country'] as String;
        final lat = result['latitude'] as double?;
        final lng = result['longitude'] as double?;
        final area = result['area'] as String?;
        final state = result['state'] as String?;
        final pincode = result['pincode'] as String?;

        await SettingsService.saveLocation(
          city,
          country,
          latitude: lat,
          longitude: lng,
          area: area,
          state: state,
          pincode: pincode,
        );
        if (!mounted) return;
        setState(() {
          currentCity = city;
          currentCountry = country;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location updated'.tr)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Settings".tr),
      body: ValueListenableBuilder<String>(
        valueListenable: SettingsService.languageNotifier,
        builder: (context, lang, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text("$currentCity, $currentCountry"),
                trailing: const Icon(Icons.edit),
                onTap: _changeLocation,
              ),
              const Divider(),
              TrText(
                "Appearance",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: TrText("Dark Mode"),
                value: isDarkMode,
                onChanged: (val) async {
                  await SettingsService.setThemeMode(val);
                  setState(() => isDarkMode = val);
                },
              ),
              const Divider(),
              TrText(
                "Alarm & Times",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: TrText("Master Sound Toggle"),
                subtitle: TrText("Enable or disable all Azan/Jamat sounds"),
                value: isRingAtAdhan,
                onChanged: (val) async {
                  await SettingsService.setRingAtAdhan(val);
                  setState(() => isRingAtAdhan = val);
                  Get.find<PrayerController>().refreshPrayerTimes();
                },
              ),
              SwitchListTile(
                title: TrText("Prayer Notifications"),
                subtitle: TrText("Show/Hide individual prayer settings"),
                value: showPrayerNotifications,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('show_prayer_notifications', val);
                  SettingsService.onSettingsChanged.value++;
                  setState(() => showPrayerNotifications = val);
                  Get.find<PrayerController>().refreshPrayerTimes();
                },
              ),
              if (showPrayerNotifications)
                ..._notifications.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: SwitchListTile(
                      dense: true,
                      title: Text(entry.key.tr, style: TextStyle(fontSize: 14.sp)),
                      value: entry.value,
                      onChanged: (val) => _saveNotification(entry.key, val),
                    ),
                  );
                }),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: TrText("Azan & Jamaat Time"),
                subtitle: TrText("Override default times"),
                onTap: () => Get.to(() => const PrayerSettingsScreen()),
              ),
              const Divider(),
              SwitchListTile(
                title: TrText("Prayer Calculation"),
                subtitle: TrText("Show advanced settings"),
                value: showAdvancedCalculation,
                onChanged: (val) async {
                  await SettingsService.setShowAdvancedCalculation(val);
                  setState(() => showAdvancedCalculation = val);
                },
              ),
              if (showAdvancedCalculation) ...[
                ListTile(
                  title: TrText("Calculation Method"),
                  subtitle: DropdownButton<int>(
                    isExpanded: true,
                    value: calculationMethod,
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Text(
                          "University of Islamic Sciences, Karachi",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text(
                          "Islamic Society of North America (ISNA)",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text("Muslim World League", style: TextStyle(fontSize: 12.sp)),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text(
                          "Umm Al-Qura University, Makkah",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 5,
                        child: Text(
                          "Egyptian General Authority of Survey",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 8,
                        child: Text("Gulf Region", style: TextStyle(fontSize: 12.sp)),
                      ),
                      DropdownMenuItem(
                        value: 9,
                        child: Text("Kuwait", style: TextStyle(fontSize: 12.sp)),
                      ),
                      DropdownMenuItem(
                        value: 10,
                        child: Text("Qatar", style: TextStyle(fontSize: 12.sp)),
                      ),
                      DropdownMenuItem(
                        value: 11,
                        child: Text(
                          "Majlis Ugama Islam Singapura, Singapore",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await SettingsService.saveApiSettings(calculationMethod: val);
                        setState(() => calculationMethod = val);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: TrText("Asr Method (Juristic)"),
                  subtitle: DropdownButton<int>(
                    isExpanded: true,
                    value: asrMethod,
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text(
                          "Standard (Shafi'i, Maliki, Hanbali)",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text("Hanafi", style: TextStyle(fontSize: 12.sp)),
                      ),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await SettingsService.saveApiSettings(asrMethod: val);
                        setState(() => asrMethod = val);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: TrText("Hijri Date Adjustment"),
                  subtitle: DropdownButton<int>(
                    isExpanded: true,
                    value: hijriOffset,
                    items: [
                      DropdownMenuItem(
                        value: -2,
                        child: TrText("-2 Days", style: TextStyle(fontSize: 12.sp)),
                      ),
                      DropdownMenuItem(
                        value: -1,
                        child: TrText("-1 Day", style: TextStyle(fontSize: 12.sp)),
                      ),
                      DropdownMenuItem(
                        value: 0,
                        child: TrText("0 Days (No offset)", style: TextStyle(fontSize: 12.sp)),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: TrText("+1 Day", style: TextStyle(fontSize: 12.sp)),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: TrText("+2 Days", style: TextStyle(fontSize: 12.sp)),
                      ),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await SettingsService.saveApiSettings(hijriOffset: val);
                        setState(() => hijriOffset = val);
                      }
                    },
                  ),
                ),
              ],
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
