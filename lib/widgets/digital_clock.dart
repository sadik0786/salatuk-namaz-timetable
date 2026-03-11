import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/utils/time_utils.dart';

class DigitalClock extends StatefulWidget {
  final int hijriOffset;
  final String nextPrayer;
  final String nextJamaatTime;
  final String sunrise;
  final String sunset;
  final double? temperature;
  final String? hijriDateString;

  const DigitalClock({
    super.key,
    this.hijriOffset = 0,
    this.nextPrayer = "",
    this.nextJamaatTime = "",
    this.sunrise = "",
    this.sunset = "",
    this.temperature,
    this.hijriDateString,
  });

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> with TickerProviderStateMixin {
  late Timer _timer;
  late DateTime _now;
  bool _showColon = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
          _showColon = !_showColon;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateFormat('hh').format(_now);
    final minute = DateFormat('mm').format(_now);
    final second = DateFormat('ss').format(_now);
    final amPm = DateFormat('a').format(_now).toUpperCase();

    final dayFull = DateFormat('EEEE').format(_now);
    final dayAndMonth = DateFormat('dd MMM yyyy').format(_now);

    final adjustedDate = _now.add(Duration(days: widget.hijriOffset));
    final hNow = HijriCalendar.fromDate(adjustedDate);

    // Use local calculation with offset for maximum reliability and synchronization with settings
    String displayHijriDate = "${hNow.hDay} ${hNow.longMonthName.tr} ${hNow.hYear}";

    // Improve formatting if it's Ramadan
    if (hNow.hMonth == 9) {
      displayHijriDate = "${hNow.hDay} ${'Ramzan'.tr} ${hNow.hYear}";
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    final isShowingHijri = (_now.second % 20) >= 10;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(2.w), // Outer border padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.r),
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.5),
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(33.r)),
        child: Column(
          children: [
            // Top Header: Date & Location/Temp
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayFull.tr.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: <Widget>[...previousChildren, ?currentChild],
                          );
                        },
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Text(
                          isShowingHijri ? displayHijriDate : dayAndMonth,
                          key: ValueKey(isShowingHijri),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.temperature != null)
                  _buildTemperatureChip(widget.temperature!, isDark, primaryColor),
              ],
            ),

            // Main Time Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTimeDigit(hour, isDark),
                _buildTimeSeparator(primaryColor),
                _buildTimeDigit(minute, isDark),
                SizedBox(width: 10.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSeconds(second, primaryColor),
                    Text(
                      amPm,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Next Prayer & Sun Info Row
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Next Prayer
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Next Prayer".tr.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            widget.nextPrayer.isNotEmpty ? widget.nextPrayer.tr : "--",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (widget.nextJamaatTime.isNotEmpty)
                            Text(
                              formatAmPm(widget.nextJamaatTime),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    VerticalDivider(color: primaryColor.withOpacity(0.2), thickness: 1),
                    // Sun Info
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSunInfoRow(
                            Icons.wb_twilight_rounded,
                            "Sunrise".tr,
                            formatAmPm(widget.sunrise),
                            isDark,
                          ),
                          SizedBox(height: 4.h),
                          _buildSunInfoRow(
                            Icons.nights_stay_rounded,
                            "Sunset".tr,
                            formatAmPm(widget.sunset),
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDigit(String digit, bool isDark) {
    final styleBase = TextStyle(
      fontSize: 62.sp,
      fontWeight: FontWeight.w900,
      fontFamily: 'Digital7',
      height: 1,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: digit.split('').map((char) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Text(
                "8",
                style: styleBase.copyWith(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                ),
              ),
              Text(char, style: styleBase.copyWith(color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSeparator(Color color) {
    return Stack(
      children: [
        // Background placeholder
        Text(
          ":",
          style: TextStyle(
            fontSize: 62.sp,
            fontWeight: FontWeight.w900,
            color: color.withOpacity(0.1),
            fontFamily: 'Digital7',
            height: 1,
          ),
        ),
        // Blinking colon
        FadeTransition(
          opacity: _fadeController,
          child: Text(
            ":",
            style: TextStyle(
              fontSize: 62.sp,
              fontWeight: FontWeight.w900,
              color: color,
              fontFamily: 'Digital7',
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeconds(String second, Color color) {
    final styleBase = TextStyle(
      fontSize: 25.sp,
      fontWeight: FontWeight.w700,
      fontFamily: 'Digital7',
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: second.split('').map((char) {
        return Stack(
          alignment: Alignment.centerRight,
          children: [
            Text("8", style: styleBase.copyWith(color: color.withOpacity(0.1))),
            Text(char, style: styleBase.copyWith(color: color.withOpacity(0.8))),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTemperatureChip(double temp, bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.thermostat_rounded, size: 14.sp, color: Colors.orangeAccent),
          SizedBox(width: 4.w),
          Text(
            "${temp.toStringAsFixed(1)}°c",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunInfoRow(IconData icon, String label, String time, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
        SizedBox(width: 8.w),
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        const Spacer(),
        Text(
          time.isEmpty ? "--" : time,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
