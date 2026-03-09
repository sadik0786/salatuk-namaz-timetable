import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/screens/dua_screen.dart';
import 'package:namaz_timetable/screens/prayer_screen.dart';
import 'package:namaz_timetable/screens/dashboard_screen.dart';
import 'package:namaz_timetable/screens/tasbih_screen.dart';
import 'package:namaz_timetable/widgets/app_drawer.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/widgets/tr_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> get _pages => [DashboardScreen(), PrayerScreen(), TasbihScreen(), DuaScreen()];

  void _onItemTapped(int index) {
    if (index == 4) {
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ValueListenableBuilder<String>(
      valueListenable: SettingsService.languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: const AppDrawer(),
          body: SafeArea(
            child: Stack(
              children: [
                IndexedStack(index: _selectedIndex, children: _pages),
                if (_selectedIndex == 0)
                  Positioned(top: 8.h, right: 12.w, child: _buildLanguageDropdown()),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            elevation: 4,
            backgroundColor: theme.colorScheme.surface,
            shape: const CircleBorder(),
            child: Icon(Icons.settings, color: primaryColor, size: 28.sp),
          ),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            color: theme.colorScheme.surface,
            elevation: 20,
            clipBehavior: Clip.antiAlias,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0, theme, primaryColor),
                  _buildNavItem(
                    Icons.mosque_outlined,
                    Icons.mosque,
                    'Prayer',
                    1,
                    theme,
                    primaryColor,
                  ),
                  _buildNavItem(
                    Icons.touch_app_outlined,
                    Icons.touch_app,
                    'Tasbih',
                    2,
                    theme,
                    primaryColor,
                  ),
                  _buildNavItem(
                    Icons.menu_book_outlined,
                    Icons.book,
                    'Dua',
                    3,
                    theme,
                    primaryColor,
                  ),
                  SizedBox(width: 48.w), // Space for the FAB cutout
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    IconData outlineIcon,
    IconData solidIcon,
    String label,
    int index,
    ThemeData theme,
    Color primaryColor,
  ) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? primaryColor : theme.iconTheme.color?.withOpacity(0.5);

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? solidIcon : outlineIcon, color: color, size: 24.sp),
              SizedBox(height: 2.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TrText(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: ValueListenableBuilder<String>(
        valueListenable: SettingsService.languageNotifier,
        builder: (context, currentLang, _) {
          return DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentLang,
              icon: Icon(
                Icons.arrow_drop_down,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              isDense: true,
              style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  SettingsService.setLanguage(newValue);
                }
              },
              items: <String>['English', 'Urdu', 'Hindi'].map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
