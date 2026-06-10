import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:namaz_timetable/controllers/prayer_tracker_controller.dart';

class PrayerTrackerScreen extends StatelessWidget {
  const PrayerTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerTrackerController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text("Prayer Tracker".tr),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            tabs: [
              Tab(text: "Daily Progress".tr),
              Tab(text: "Qaza Tracker".tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Daily Progress
            Column(
              children: [
                _buildDateHeader(controller, theme, isDark),
                Expanded(
                  child: Obx(
                    () => ListView(
                      padding: EdgeInsets.all(16.w),
                      children: [
                        _buildProgressCard(controller, theme, isDark),
                        SizedBox(height: 20.h),
                        _buildPrayerStepper(controller, theme, isDark),
                        if (controller.prayerStatus.values.isNotEmpty &&
                            controller.prayerStatus.values.every(
                              (isDone) => isDone,
                            )) ...[
                          SizedBox(height: 24.h),
                          _buildCompletionMessage(theme, isDark),
                        ],
                        SizedBox(height: 20.h),
                        _buildQuoteCard(controller, isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Tab 2: Qaza Namaz
            _buildQazaTab(controller, theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildQazaTab(
    PrayerTrackerController controller,
    ThemeData theme,
    bool isDark,
  ) {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Witr'];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: prayers.length,
      itemBuilder: (context, index) {
        final prayer = prayers[index];

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_filled,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Obx(() {
                      final count = controller.qazaStatus[prayer] ?? 0;
                      return Text(
                        "Missed: $count",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: count > 0 ? Colors.redAccent : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Obx(() {
                final count = controller.qazaStatus[prayer] ?? 0;
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        controller.decrementQaza(prayer);
                      },
                    ),
                    Text(
                      "$count",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        controller.incrementQaza(prayer);
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(
    PrayerTrackerController controller,
    ThemeData theme,
    bool isDark,
  ) {
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
                  Icon(
                    Icons.calendar_month,
                    size: 18.sp,
                    color: theme.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Obx(
                    () => Text(
                      DateFormat(
                        'EEEE, d MMM',
                      ).format(controller.selectedDate.value),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              final next = controller.selectedDate.value.add(
                const Duration(days: 1),
              );
              if (next.isBefore(
                DateTime.now().add(const Duration(seconds: 1)),
              )) {
                controller.changeDate(next);
              }
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    PrayerTrackerController controller,
    ThemeData theme,
    bool isDark,
  ) {
    final doneCount = controller.prayerStatus.values.where((v) => v).length;
    final total = controller.prayerStatus.length;
    final percentage = doneCount / total;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10.w,
            top: -10.w,
            child: Icon(
              Icons.mosque,
              size: 140.w,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daily Progress".tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "prayers_completed_count".trParams({
                          'done': doneCount.toString(),
                          'total': total.toString(),
                        }),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: percentage),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70.w,
                          height: 70.w,
                          child: CircularProgressIndicator(
                            value: value,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          "${(value * 100).toInt()}%",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerStepper(
    PrayerTrackerController controller,
    ThemeData theme,
    bool isDark,
  ) {
    final prayers = controller.prayerStatus.keys.toList();
    final color = const Color(0xFF6366F1);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(prayers.length * 2 - 1, (index) {
          if (index.isOdd) {
            final prayerIndex = index ~/ 2;
            final isDone =
                controller.prayerStatus[prayers[prayerIndex]] ?? false;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(top: 18.w),
                height: 3.h,
                color: isDone
                    ? color
                    : (isDark ? Colors.white10 : Colors.grey.shade300),
              ),
            );
          }

          final prayerIndex = index ~/ 2;
          final prayer = prayers[prayerIndex];
          final isDone = controller.prayerStatus[prayer] ?? false;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              controller.togglePrayer(prayer);
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: isDone
                        ? color
                        : (isDark
                              ? const Color(0xFF0F172A)
                              : Colors.grey.shade100),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? color
                          : (isDark ? Colors.white24 : Colors.grey.shade300),
                      width: 2,
                    ),
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isDone
                        ? Icon(Icons.check, color: Colors.white, size: 18.sp)
                        : Text(
                            "${prayerIndex + 1}",
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  prayer.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                    color: isDone
                        ? color
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCompletionMessage(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.stars, color: Colors.green, size: 40.sp),
          SizedBox(height: 8.h),
          Text(
            "Masha'Allah!".tr,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "You have completed all your prayers for today. May Allah accept your prayers and grant you success in this life and the hereafter."
                .tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(PrayerTrackerController controller, bool isDark) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.blue.withOpacity(0.05), Colors.blue.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.blue.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Icon(
              Icons.format_quote,
              size: 100.sp,
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.blue.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Obx(() {
              final quoteData =
                  controller.prayerQuotes[controller.currentQuoteIndex.value];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.amber,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Did you know?".tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                    child: Text(
                      quoteData["quote"]!.tr,
                      key: ValueKey<String>(quoteData["quote"]!),
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: Align(
                      key: ValueKey<String>(quoteData["reference"]!),
                      alignment: Alignment.centerRight,
                      child: Text(
                        quoteData["reference"]!.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
