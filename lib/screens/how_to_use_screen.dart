import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:namaz_timetable/screens/about_screen.dart';
import 'package:namaz_timetable/services/notification_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:app_settings/app_settings.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: CommonAppBar(title: "Help & Guide".tr),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildHeroSection(isDark),
          SizedBox(height: 24.h),

          _buildGuideSection(
            title: "Step 1: Turn On Notifications & Alarms".tr,
            items: [
              _GuideItem(
                icon: Icons.notifications_active,
                title: "App Notifications".tr,
                description:
                    "Turn on notifications so you can receive Azan alerts.".tr,
                action: ElevatedButton(
                  onPressed: () => AppSettings.openAppSettings(
                    type: AppSettingsType.notification,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    elevation: 0,
                  ),
                  child: Text(
                    "Turn On".tr,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
              _GuideItem(
                icon: Icons.timer,
                title: "Exact Alarms".tr,
                description:
                    "Allow this so Azan plays exactly on the right time.".tr,
                action: ElevatedButton(
                  onPressed: () =>
                      NotificationService.requestExactAlarmPermission(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    elevation: 0,
                  ),
                  child: Text(
                    "Turn On".tr,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),

          _buildGuideSection(
            title: "Step 2: Check Volume & Silent Mode".tr,
            items: [
              _GuideItem(
                icon: Icons.volume_up,
                title: "Increase Alarm Volume".tr,
                description:
                    "Make sure your phone's 'Alarm Volume' is turned up to full."
                        .tr,
                action: ElevatedButton(
                  onPressed: () =>
                      AppSettings.openAppSettings(type: AppSettingsType.sound),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    elevation: 0,
                  ),
                  child: Text(
                    "Check Volume".tr,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
              _GuideItem(
                icon: Icons.do_not_disturb_off,
                title: "Bypass Silent Mode (DND)".tr,
                description:
                    "Allow the app to play Azan even when your phone is silent or in Do Not Disturb mode."
                        .tr,
                action: ElevatedButton(
                  onPressed: () => AppSettings.openAppSettings(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    elevation: 0,
                  ),
                  child: Text(
                    "Fix Silent Mode".tr,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),

          _buildGuideSection(
            title: "Step 3: Stop Phone from Killing App (Crucial)".tr,
            items: [
              _GuideItem(
                icon: Icons.battery_saver,
                title: "Disable Battery Restrictions".tr,
                description:
                    "Phones often stop apps in the background. Change this setting to 'No Restrictions' or 'Unrestricted' to fix missing Azan."
                        .tr,
              ),
              _GuideBullet("Open 'App Info' (Long press the app icon)".tr),
              _GuideBullet("Go to 'Battery' or 'Battery Usage'".tr),
              _GuideBullet("Select 'Unrestricted' or 'No Restrictions'".tr),
              SizedBox(height: 10.h),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      NotificationService.requestBatteryOptimization(),
                  icon: const Icon(Icons.settings_applications),
                  label: Text("Fix Background Setting".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          _buildGuideSection(
            title: "Step 4: Special Phone Settings".tr,
            items: [
              _GuideItem(
                icon: Icons.phone_android,
                title: "Xiaomi, Oppo, Vivo & Realme".tr,
                description:
                    "If you have these phones, you must turn on these settings:"
                        .tr,
              ),
              _GuideBullet("Auto-start: Turn this ON in App Settings.".tr),
              _GuideBullet(
                "Lock Screen: Allow 'Show on Lock Screen' in Notifications.".tr,
              ),
              _GuideBullet(
                "Pop-up Windows: Allow 'Display pop-up windows'.".tr,
              ),
            ],
          ),

          _buildGuideSection(
            title: "Step 5: Fixing Wrong Times".tr,
            items: [
              _GuideItem(
                icon: Icons.edit_calendar,
                title: "Manual Time Correction".tr,
                description:
                    "If the time is slightly wrong, you can manually fix it yourself:"
                        .tr,
              ),
              _GuideBullet("Go to 'Settings' > 'Adjust Prayer Times'.".tr),
              _GuideBullet("Pick the correct time yourself.".tr),
            ],
          ),

          SizedBox(height: 40.h),
          _buildFooter(isDark),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blue.shade900, Colors.indigo.shade900]
              : [Colors.blue.shade500, Colors.blue.shade700],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          const Icon(Icons.help_center_outlined, color: Colors.white, size: 48),
          SizedBox(height: 12.h),
          Text(
            "How to use Salatuk".tr,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Follow these steps for 100% reliable Azan alerts.".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ),
        ...items,
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Center(
      child: Column(
        children: [
          Text(
            "Still having issues?".tr,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: () => Get.to(() => const AboutScreen()),
            child: Text("Contact Support".tr),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const _GuideItem({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.02),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.orange, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            action ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _GuideBullet extends StatelessWidget {
  final String text;
  const _GuideBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 36.w, top: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
