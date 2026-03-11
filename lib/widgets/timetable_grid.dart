import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/utils/time_utils.dart';
import 'package:namaz_timetable/widgets/timetable_header.dart';

class TimetableGrid extends StatefulWidget {
  final Map<String, String> timings;
  final Map<String, String> jamaatTimes;
  final Map<String, String> endTimes;
  final String nextPrayer;

  const TimetableGrid({
    super.key,
    required this.timings,
    required this.jamaatTimes,
    required this.endTimes,
    required this.nextPrayer,
  });

  @override
  State<TimetableGrid> createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  Map<String, bool> _notifications = {};

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    SettingsService.onSettingsChanged.addListener(_loadNotifications);
  }

  @override
  void dispose() {
    SettingsService.onSettingsChanged.removeListener(_loadNotifications);
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final notifs = await SettingsService.getPrayerNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Jumah', 'Sehr', 'Iftar'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          const TimetableHeader(),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 40.h),
              itemCount: prayerOrder.length,
              itemBuilder: (context, index) {
                final prayer = prayerOrder[index];
                final isNext = widget.nextPrayer.startsWith(prayer);

                String azan = 'N/A';
                String jamaat = 'N/A';
                String end = 'N/A';

                if (prayer == 'Sehr') {
                  azan = widget.timings['Imsak'] ?? widget.timings['Fajr'] ?? 'N/A';
                  jamaat = '-';
                  end = '-';
                } else if (prayer == 'Iftar') {
                  azan = widget.timings['Maghrib'] ?? 'N/A';
                  jamaat = '-';
                  end = '-';
                } else if (prayer == 'Jumah') {
                  azan = widget.timings['Dhuhr'] ?? 'N/A';
                  jamaat = widget.jamaatTimes['Jumah'] ?? 'N/A';
                  end = widget.endTimes['Dhuhr'] ?? 'N/A';
                } else {
                  azan = widget.timings[prayer] ?? 'N/A';
                  jamaat = widget.jamaatTimes[prayer] ?? 'N/A';
                  end = widget.endTimes[prayer] ?? 'N/A';
                }

                IconData prayerIcon;
                switch (prayer) {
                  case 'Fajr':
                    prayerIcon = Icons.wb_twilight;
                    break;
                  case 'Dhuhr':
                    prayerIcon = Icons.wb_sunny;
                    break;
                  case 'Asr':
                    prayerIcon = Icons.wb_sunny_outlined;
                    break;
                  case 'Maghrib':
                    prayerIcon = Icons.brightness_3;
                    break;
                  case 'Isha':
                    prayerIcon = Icons.nights_stay;
                    break;
                  case 'Jumah':
                    prayerIcon = Icons.diversity_3;
                    break;
                  case 'Sehr':
                    prayerIcon = Icons.brightness_4;
                    break;
                  case 'Iftar':
                    prayerIcon = Icons.local_dining;
                    break;
                  default:
                    prayerIcon = Icons.access_time;
                }

                return _buildRow(
                  context,
                  prayer: prayer,
                  icon: prayerIcon,
                  azan: formatAmPm(azan),
                  jamaat: formatAmPm(jamaat),
                  end: formatAmPm(end),
                  isNext: isNext,
                  isNotificationEnabled: _notifications[prayer],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String prayer,
    required IconData icon,
    required String azan,
    required String jamaat,
    required String end,
    required bool isNext,
    bool? isNotificationEnabled,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isNext
            ? null
            : (isDark ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5) : Colors.white),
        gradient: isNext
            ? LinearGradient(
                colors: [primaryColor.withOpacity(0.9), primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isNext ? Colors.transparent : theme.dividerColor.withOpacity(0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isNext ? primaryColor.withOpacity(0.5) : Colors.black.withOpacity(0.03),
            blurRadius: isNext ? 15.r : 8.r,
            offset: Offset(0, isNext ? 6.h : 3.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: isNext ? onPrimary.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18.sp, color: isNext ? onPrimary : primaryColor),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              prayer.tr,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isNext ? FontWeight.w800 : FontWeight.w700,
                                color: isNext ? onPrimary : theme.colorScheme.onSurface,
                                fontSize: 16.sp,
                                letterSpacing: 0.3.w,
                              ),
                            ),
                          ),
                          if (isNotificationEnabled != null) ...[
                            SizedBox(width: 4.w),
                            Icon(
                              isNotificationEnabled
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              size: 14.sp,
                              color: isNext
                                  ? onPrimary.withOpacity(0.9)
                                  : (isNotificationEnabled
                                        ? primaryColor
                                        : theme.colorScheme.onSurface.withOpacity(0.3)),
                            ),
                          ],
                        ],
                      ),
                      if (end != 'N/A' && end != '-' && end != '') ...[
                        SizedBox(height: 4.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "End - $end",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: isNext
                                  ? onPrimary.withOpacity(0.8)
                                  : theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Cell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  azan,
                  style: TextStyle(
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                    color: isNext ? onPrimary : theme.colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          _Cell(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: isNext ? onPrimary.withOpacity(0.15) : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isNext ? Colors.transparent : theme.dividerColor.withOpacity(0.1),
                ),
              ),
              child: Text(
                jamaat,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isNext ? onPrimary : theme.colorScheme.primary,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final Widget child;
  const _Cell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: 2, child: child);
  }
}
