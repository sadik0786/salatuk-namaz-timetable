import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:namaz_timetable/controllers/prayer_controller.dart';
import 'package:namaz_timetable/screens/home_screen.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:namaz_timetable/utils/time_utils.dart';

class PrayerSettingsScreen extends StatelessWidget {
  const PrayerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.find<PrayerController>();

    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Sehr', 'Iftar'];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Get.offAll(() => const HomeScreen());
      },
      child: Scaffold(
        appBar: CommonAppBar(
          title: "Prayer Override".tr,
          showBackButton: true,
          onBackPress: () => Get.offAll(() => const HomeScreen()),
          actions: [
            TextButton(
              onPressed: () => _showResetConfirmation(context, controller),
              child: Text("Reset".tr, style: const TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: prayers.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final prayer = prayers[index];
              return _PrayerOverrideCard(
                prayer: prayer,
                azan: controller.manualAzans[prayer] ?? "",
                jamaat: controller.manualJamaats[prayer] ?? "",
                onEdit: (azan, jamaat) => controller.saveOverride(prayer, azan, jamaat),
              );
            },
          );
        }),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, PrayerController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reset to Default?".tr),
        content: Text("This will clear all manual times and use API defaults.".tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel".tr)),
          ElevatedButton(
            onPressed: () async {
              await controller.resetToDefault();
              Get.back();
              Get.snackbar("Success".tr, "All times reset to default".tr);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text("Reset".tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _PrayerOverrideCard extends StatelessWidget {
  final String prayer;
  final String azan;
  final String jamaat;
  final Function(String?, String?) onEdit;
  final PrayerController controller = Get.find<PrayerController>();

  _PrayerOverrideCard({
    required this.prayer,
    required this.azan,
    required this.jamaat,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              prayer.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => controller.playTestSound('sounds/azan.mp3'),
                  icon: const Icon(Icons.play_circle_fill, color: Colors.green),
                  tooltip: "Play Azan".tr,
                ),
                IconButton(
                  onPressed: () => controller.playTestSound('sounds/beep.mp3'),
                  icon: const Icon(Icons.notifications_active, color: Colors.blue),
                  tooltip: "Play Beep".tr,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Expanded(
              child: _TimeBox(
                label: (prayer == 'Sehr' || prayer == 'Iftar') ? "Start Time".tr : "Azan Time".tr,
                time: azan.isEmpty ? "API Default".tr : formatAmPm(azan),
                onTap: () => _pickTime(context, true),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _TimeBox(
                label: (prayer == 'Sehr' || prayer == 'Iftar') ? "End Time".tr : "Jamaat Time".tr,
                time: jamaat.isEmpty ? "API Default".tr : formatAmPm(jamaat),
                onTap: () => _pickTime(context, false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickTime(BuildContext context, bool isAzan) async {
    // ... existing code ...
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Store in 24-hour format (HH:mm) for internal consistency
      final String hour = picked.hour.toString().padLeft(2, '0');
      final String minute = picked.minute.toString().padLeft(2, '0');
      final formatted24h = "$hour:$minute";
      onEdit(isAzan ? formatted24h : null, isAzan ? null : formatted24h);
    }
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeBox({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
            SizedBox(height: 4.h),
            Text(
              time,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: time == "API Default".tr ? Colors.blueGrey : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
