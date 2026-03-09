import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _selectedDate = DateTime.now();
  late HijriCalendar _hijriDate;
  int _hijriOffset = 0;
  bool _isLoadingOffset = true;

  @override
  void initState() {
    super.initState();
    _loadOffset();
  }

  Future<void> _loadOffset() async {
    final location = await SettingsService.getLocation();
    setState(() {
      _hijriOffset = location['hijriOffset'] ?? 0;
      _hijriDate = HijriCalendar.fromDate(_selectedDate.add(Duration(days: _hijriOffset)));
      _isLoadingOffset = false;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _hijriDate = HijriCalendar.fromDate(date.add(Duration(days: _hijriOffset)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    if (_isLoadingOffset) {
      return Container(
        height: 300.h,
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(theme, isDark),
          SizedBox(height: 16.h),
          _buildCalendarGrid(theme, isDark),
          SizedBox(height: 16.h),
          _buildDetailsSection(theme, isDark, primaryColor),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final monthName = DateFormat('MMMM yyyy').format(_selectedDate);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _onDateSelected(DateTime(_selectedDate.year, _selectedDate.month - 1)),
          icon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
        ),
        Text(
          monthName,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () => _onDateSelected(DateTime(_selectedDate.year, _selectedDate.month + 1)),
          icon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(ThemeData theme, bool isDark) {
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1).weekday;

    // Adjust for Monday start or Sunday start. Flutter weekday 1 is Monday.
    // Let's assume Sunday start (7) -> 0 index.
    final offset = firstDayOfMonth % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) {
            return SizedBox(
              width: 40.w,
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daysInMonth + offset,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemBuilder: (context, index) {
            if (index < offset) return const SizedBox.shrink();

            final day = index - offset + 1;
            final date = DateTime(_selectedDate.year, _selectedDate.month, day);
            final hDate = HijriCalendar.fromDate(date.add(Duration(days: _hijriOffset)));
            final isToday =
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day;
            final isSelected =
                date.year == _selectedDate.year &&
                date.month == _selectedDate.month &&
                date.day == _selectedDate.day;

            return GestureDetector(
              onTap: () => _onDateSelected(date),
              child: Container(
                margin: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isToday ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    Text(
                      '${hDate.hDay}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : theme.colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailsSection(ThemeData theme, bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDateColumn("English", DateFormat('dd MMM yyyy').format(_selectedDate), isDark),
          Container(width: 1.w, height: 30.h, color: primaryColor.withOpacity(0.2)),
          _buildDateColumn(
            "Hijri",
            "${_hijriDate.hDay} ${_hijriDate.longMonthName} ${_hijriDate.hYear}",
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label.tr,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
