import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:namaz_timetable/controllers/prayer_tracker_controller.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';

class PrayerTrackerScreen extends StatelessWidget {
  const PrayerTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerTrackerController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: CommonAppBar(title: "Prayer Tracker".tr),
      body: Column(
        children: [
          _buildDateHeader(controller, theme, isDark),
          Expanded(
            child: Obx(() => ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    _buildProgressCard(controller, theme),
                    SizedBox(height: 20.h),
                    ...controller.prayerStatus.keys.map((prayer) {
                      return _buildPrayerItem(
                        prayer: prayer,
                        isDone: controller.prayerStatus[prayer] ?? false,
                        onToggle: () => controller.togglePrayer(prayer),
                        theme: theme,
                        isDark: isDark,
                      );
                    }),
                    SizedBox(height: 20.h),
                    _buildQuoteCard(isDark),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(PrayerTrackerController controller, ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => controller.changeDate(
              controller.selectedDate.value.subtract(const Duration(days: 1)),
            ),
            icon: const Icon(Icons.chevron_left),
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (picked != null) controller.changeDate(picked);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, size: 18.sp, color: theme.primaryColor),
                  SizedBox(width: 8.w),
                  Obx(() => Text(
                        DateFormat('EEEE, d MMM').format(controller.selectedDate.value),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                      )),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              final next = controller.selectedDate.value.add(const Duration(days: 1));
              if (next.isBefore(DateTime.now().add(const Duration(seconds: 1)))) {
                controller.changeDate(next);
              }
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(PrayerTrackerController controller, ThemeData theme) {
    final doneCount = controller.prayerStatus.values.where((v) => v).length;
    final total = controller.prayerStatus.length;
    final percentage = doneCount / total;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withBlue(255)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daily Progress".tr,
                  style:
                      TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  "$doneCount of $total prayers completed".tr,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percentage,
                backgroundColor: Colors.white.withOpacity(0.2),
                color: Colors.white,
                strokeWidth: 6,
              ),
              Text(
                "${(percentage * 100).toInt()}%",
                style:
                    TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerItem({
    required String prayer,
    required bool isDone,
    required VoidCallback onToggle,
    required ThemeData theme,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDone ? theme.primaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDone ? theme.primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? theme.primaryColor : Colors.grey,
          ),
        ),
        title: Text(
          prayer.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        trailing: Switch(
          value: isDone,
          onChanged: (_) => onToggle(),
          activeColor: theme.primaryColor,
        ),
        onTap: onToggle,
      ),
    );
  }

  Widget _buildQuoteCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.format_quote, color: Colors.blue, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            "Verily, prayer restrains from shameful and unjust deeds.".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "(Quran 29:45)",
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
