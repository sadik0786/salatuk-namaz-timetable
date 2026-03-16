import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/screens/calendar_screen.dart';
import 'package:namaz_timetable/screens/fatiha_tarika_screen.dart';
import 'package:namaz_timetable/screens/namaz_tarika_screen.dart';
import 'package:namaz_timetable/screens/qibla_screen.dart';
import 'package:namaz_timetable/screens/settings_screen.dart';
import 'package:namaz_timetable/screens/ramzan_screen.dart';
import 'package:namaz_timetable/screens/prayer_tracker_screen.dart';
import 'package:namaz_timetable/screens/zakat_calculator_screen.dart';
import 'package:namaz_timetable/widgets/tr_text.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250.w,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 140.h,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.mosque,
                        size: 30.sp,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      SizedBox(width: 12.w),
                      TrText(
                        'Salatuk',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_month_rounded),
            title: TrText('Calendar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.track_changes_rounded),
            title: TrText('Prayer Tracker'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrayerTrackerScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: TrText('Zakat Calculator'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ZakatCalculatorScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: TrText('Ramzan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RamzanScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.explore_outlined),
            title: TrText('Qibla'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const QiblaScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: TrText('Namaz Tarika'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NamazTarikaScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: TrText('Fatiha Ka Tarika'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FatihaTarikaScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: TrText('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.info),
          //   title: TrText('About App'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
          //   },
          // ),
        ],
      ),
    );
  }
}
