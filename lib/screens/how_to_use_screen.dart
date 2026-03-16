import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:namaz_timetable/screens/about_screen.dart';
import 'package:namaz_timetable/services/notification_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: CommonAppBar(title: "Help & Guide".tr),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildHeroSection(isDark),
          SizedBox(height: 24.h),

          _buildGuideSection(
            title: "1. Basic Setup".tr,
            items: [
              _GuideItem(
                icon: Icons.notifications_active,
                title: "Allow Notifications".tr,
                description:
                    "Ensure you grant notification permission when prompted to hear the Azan.".tr,
              ),
              _GuideItem(
                icon: Icons.timer,
                title: "Alarms Permission".tr,
                description:
                    "This app needs 'Exact Alarm' permission to play Azan precisely at the right time."
                        .tr,
                action: TextButton(
                  onPressed: () => NotificationService.requestExactAlarmPermission(),
                  child: Text("Grant Now".tr, style: const TextStyle(color: Colors.blueAccent)),
                ),
              ),
            ],
          ),

          _buildGuideSection(
            title: "2. Fixing Missed Azan (Crucial)".tr,
            items: [
              _GuideItem(
                icon: Icons.battery_saver,
                title: "Battery Optimization".tr,
                description:
                    "Android often kills background apps to save battery. To ensure Azan always plays:"
                        .tr,
              ),
              _GuideBullet("Open 'App Info' (Long press app icon)".tr),
              _GuideBullet("Go to 'Battery Usage' or 'Battery Saver'".tr),
              _GuideBullet("Select 'No Restrictions' or 'Don't Optimize'".tr),
              SizedBox(height: 10.h),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => NotificationService.requestBatteryOptimization(),
                  icon: const Icon(Icons.settings_applications),
                  label: Text("Open Battery Settings".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          _buildGuideSection(
            title: "3. Xiaomi, Oppo, Vivo & Realme".tr,
            items: [
              _GuideItem(
                icon: Icons.phone_android,
                title: "Special Permissions".tr,
                description: "On these phones, you MUST enable these manually:".tr,
              ),
              _GuideBullet("Auto-start: Enable this in App Settings.".tr),
              _GuideBullet(
                "Lock Screen: Enable 'Show on Lock Screen' in Notification categories.".tr,
              ),
              _GuideBullet("Floating Windows: Enable 'Display pop-up windows'.".tr),
            ],
          ),

          _buildGuideSection(
            title: "4. Adjusting Times".tr,
            items: [
              _GuideItem(
                icon: Icons.edit_calendar,
                title: "Manual Overrides".tr,
                description:
                    "If the calculated time is off by a few minutes, you can manually fix it:".tr,
              ),
              _GuideBullet("Go to 'Settings' > 'Adjust Prayer Times'.".tr),
              _GuideBullet("Select the prayer and pick your preferred time.".tr),
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
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8.h),
          Text(
            "Follow these steps for 100% reliable Azan alerts.".tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection({required String title, required List<Widget> items}) {
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
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
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
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
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
            if (action != null) action!,
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
