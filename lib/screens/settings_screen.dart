import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:namaz_timetable/screens/prayer_settings_screen.dart';
import 'package:namaz_timetable/services/notification_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/controllers/prayer_controller.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:namaz_timetable/widgets/settings_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namaz_timetable/screens/how_to_use_screen.dart';
import 'package:namaz_timetable/screens/about_screen.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: CommonAppBar(title: "Settings".tr),
      body: ValueListenableBuilder<String>(
        valueListenable: SettingsService.languageNotifier,
        builder: (context, lang, _) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            children: [
              // Header / Location Section
              _buildSectionTitle("Current Location".tr),
              _buildLocationCard(isDark, theme),

              SizedBox(height: 24.h),

              // Appearance Section
              _buildSectionTitle("General".tr),
              _buildGroupCard(isDark, [
                _SettingToggle(
                  icon: Icons.dark_mode_outlined,
                  title: "Dark Mode".tr,
                  value: isDarkMode,
                  onChanged: (val) async {
                    await SettingsService.setThemeMode(val);
                    setState(() => isDarkMode = val);
                  },
                ),
                _SettingAction(
                  icon: Icons.language_outlined,
                  title: "Language".tr,
                  subtitle: lang,
                  onTap: () => _showLanguageDialog(context),
                ),
              ]),

              SizedBox(height: 24.h),

              // Sounds & Fixes Section
              _buildSectionTitle("Sounds & Fixes".tr),
              _buildGroupCard(isDark, [
                _SettingToggle(
                  icon: Icons.volume_up_outlined,
                  title: "Master Sound Toggle".tr,
                  subtitle: "Enable all Azan & Jamaat sounds".tr,
                  value: isRingAtAdhan,
                  onChanged: (val) async {
                    await SettingsService.setRingAtAdhan(val);
                    setState(() => isRingAtAdhan = val);
                    Get.find<PrayerController>().refreshPrayerTimes();
                  },
                ),
                _SettingAction(
                  icon: Icons.notifications_active_outlined,
                  title: "Fix Background Sound".tr,
                  subtitle: "Allow app to run in background for Azan alerts".tr,
                  onTap: () => NotificationService.requestBatteryOptimization(),
                ),
                // _SettingAction(
                //   icon: Icons.bug_report_outlined,
                //   title: "Test Azan Notification".tr,
                //   subtitle: "Click to test sound in 5 seconds".tr,
                //   onTap: () => NotificationService.testNotification(),
                // ),
                _SettingAction(
                  icon: Icons.alarm_on_outlined,
                  iconColor: Colors.redAccent,
                  title: "Alarms & Reminders".tr,
                  subtitle: "Required for exact timing".tr,
                  trailing: FutureBuilder<bool>(
                    future: NotificationService.isExactAlarmPermissionGranted(),
                    builder: (context, snapshot) {
                      final isGranted = snapshot.data ?? false;
                      return Icon(
                        isGranted ? Icons.check_circle : Icons.error_outline,
                        color: isGranted ? Colors.green : Colors.redAccent,
                        size: 20.sp,
                      );
                    },
                  ),
                  onTap: () => NotificationService.requestExactAlarmPermission(),
                ),
                _SettingAction(
                  icon: Icons.timer_outlined,
                  title: "Adjust Prayer Times".tr,
                  subtitle: "Override Azan & Jamaat".tr,
                  onTap: () => Get.to(() => const PrayerSettingsScreen()),
                ),
              ]),

              SizedBox(height: 24.h),

              // Notifications Section
              _buildSectionTitle("Notifications".tr),
              _buildGroupCard(isDark, [
                _SettingToggle(
                  icon: Icons.notifications_none_outlined,
                  title: "Prayer Alerts".tr,
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
                    return _SettingToggle(
                      isDense: true,
                      title: entry.key.tr,
                      value: entry.value,
                      onChanged: (val) => _saveNotification(entry.key, val),
                    );
                  }),
              ]),

              SizedBox(height: 24.h),

              // Advanced Section
              _buildSectionTitle("Advanced Configuration".tr),
              _buildGroupCard(isDark, [
                _SettingToggle(
                  icon: Icons.settings_suggest_outlined,
                  title: "Prayer Calculation".tr,
                  subtitle: "Advanced parameters".tr,
                  value: showAdvancedCalculation,
                  onChanged: (val) async {
                    await SettingsService.setShowAdvancedCalculation(val);
                    setState(() => showAdvancedCalculation = val);
                  },
                ),
                if (showAdvancedCalculation) ...[
                  _SettingDropdown<int>(
                    title: "Calculation Method".tr,
                    value: calculationMethod,
                    items: [
                      _dropdownItem(1, "Univ. of Islamic Sciences, Karachi"),
                      _dropdownItem(2, "ISNA (North America)"),
                      _dropdownItem(3, "Muslim World League"),
                      _dropdownItem(4, "Umm Al-Qura, Makkah"),
                      _dropdownItem(5, "Egyptian Gen. Authority"),
                      _dropdownItem(8, "Gulf Region"),
                      _dropdownItem(9, "Kuwait"),
                      _dropdownItem(10, "Qatar"),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await SettingsService.saveApiSettings(calculationMethod: val);
                        setState(() => calculationMethod = val);
                      }
                    },
                  ),
                  _SettingDropdown<int>(
                    title: "Asr Method".tr,
                    value: asrMethod,
                    items: [
                      _dropdownItem(0, "Standard (Shafi'i, Maliki, Hanbali)"),
                      _dropdownItem(1, "Hanafi (Recommended)"),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await SettingsService.saveApiSettings(asrMethod: val);
                        setState(() => asrMethod = val);
                      }
                    },
                  ),
                  _SettingDropdown<int>(
                    title: "Hijri Adjustment".tr,
                    value: hijriOffset,
                    items: [
                      _dropdownItem(-2, "-2 Days"),
                      _dropdownItem(-1, "-1 Day"),
                      _dropdownItem(0, "Default"),
                      _dropdownItem(1, "+1 Day"),
                      _dropdownItem(2, "+2 Days"),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await SettingsService.saveApiSettings(hijriOffset: val);
                        setState(() => hijriOffset = val);
                      }
                    },
                  ),
                ],
              ]),

              SizedBox(height: 24.h),

              // Help & Guide Section
              _buildSectionTitle("Help & Support".tr),
              _buildGroupCard(isDark, [
                _SettingAction(
                  icon: Icons.help_outline,
                  title: "How to Use App".tr,
                  subtitle: "Instructions for Azan settings".tr,
                  onTap: () => Get.to(() => const HowToUseScreen()),
                ),
                _SettingAction(
                  icon: Icons.info_outline,
                  title: "About Salatuk".tr,
                  onTap: () => Get.to(() => const AboutScreen()),
                ),
              ]),

              SizedBox(height: 40.h),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Select Language".tr,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            _buildLanguageItem("English", "English"),
            _buildLanguageItem("Hindi", "हिंदी"),
            _buildLanguageItem("Urdu", "اردو"),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(String langKey, String displayName) {
    final currentLang = SettingsService.languageNotifier.value;
    final isSelected = currentLang == langKey;

    return ListTile(
      onTap: () async {
        await SettingsService.setLanguage(langKey);
        Get.back();
      },
      title: Text(
        displayName,
        style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.withOpacity(0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLocationCard(bool isDark, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on, color: theme.primaryColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$currentCity, $currentCountry",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  "Tap to update location".tr,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _changeLocation,
            icon: const Icon(Icons.edit_location_alt_outlined, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final idx = entry.key;
          final widget = entry.value;
          return Column(
            children: [
              widget,
              if (idx < children.length - 1)
                Divider(
                  height: 1,
                  indent: 55.w,
                  endIndent: 16.w,
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  DropdownMenuItem<int> _dropdownItem(int val, String text) {
    return DropdownMenuItem(
      value: val,
      child: Text(text, style: TextStyle(fontSize: 13.sp)),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDense;

  const _SettingToggle({
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: isDense,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: isDense ? 0 : 4.h),
      secondary: icon != null
          ? Icon(icon, color: Theme.of(context).primaryColor, size: 22.sp)
          : null,
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }
}

class _SettingAction extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingAction({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor, size: 22.sp),
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            )
          : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp),
    );
  }
}

class _SettingDropdown<T> extends StatelessWidget {
  final String title;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _SettingDropdown({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                value: value,
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
