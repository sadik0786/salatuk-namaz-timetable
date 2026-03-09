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
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : primary.withOpacity(0.08),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
        border: Border.all(color: isDark ? Colors.transparent : primary.withOpacity(0.1)),
      ),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      child: Row(
        children: [
          _HeaderCell(
            'PRAYER'.tr,
            flex: 3,
            color: isDark ? Colors.white70 : theme.colorScheme.onSurface.withOpacity(0.7),
            alignLeft: true,
            icon: Icons.mosque_outlined,
          ),
          _HeaderCell(
            'AZAN'.tr,
            color: isDark ? Colors.white70 : theme.colorScheme.onSurface.withOpacity(0.7),
            icon: Icons.volume_up_outlined,
          ),
          _HeaderCell(
            'JAMAAT'.tr,
            color: isDark ? Colors.white70 : theme.colorScheme.onSurface.withOpacity(0.7),
            icon: Icons.people_outline,
          ),
        ],
      ),
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
      child: Padding(
        padding: alignLeft ? EdgeInsets.only(left: 4.w) : EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: alignLeft ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                text.toUpperCase(),
                textAlign: alignLeft ? TextAlign.left : TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                  letterSpacing: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
