import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/services/localization_service.dart';

class TimetableHeader extends StatelessWidget {
  const TimetableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h, top: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDark
              ? [primary.withOpacity(0.8), primary.withOpacity(0.4)]
              : [primary, primary.withBlue(200)],
        ),
        borderRadius: BorderRadius.circular(30.r), // Distinct pill shape
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3), blurRadius: 12.r, offset: Offset(0, 6.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      child: Row(
        children: [
          _HeaderCell(
            'PRAYER'.tr,
            flex: 4,
            color: Colors.white,
            alignLeft: true,
            icon: Icons.mosque_rounded,
          ),
          _VerticalDivider(),
          _HeaderCell(
            'AZAN'.tr,
            flex: 2,
            color: Colors.white,
            icon: Icons.notifications_active_rounded,
          ),
          _VerticalDivider(),
          _HeaderCell(
            'JAMAAT'.tr,
            flex: 3, color: Colors.white, icon: Icons.groups_rounded,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18.h,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: Colors.white24,
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final Color color;
  final bool alignLeft;
  final IconData icon;

  const _HeaderCell(
    this.text, {
    this.flex = 2,
    required this.color,
    this.alignLeft = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: alignLeft ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14.sp, color: color.withOpacity(0.9)),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 10.sp,
                letterSpacing: 1.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
