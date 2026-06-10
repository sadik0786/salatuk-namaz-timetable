import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:namaz_timetable/data/quran_surahs_data.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surahs = QuranSurahsData.surahs;

    return Scaffold(
      appBar: const CommonAppBar(title: "Selected Surahs"),
      body: Stack(
        children: [
          Positioned(
            right: -50.w,
            top: -50.w,
            child: Icon(
              Icons.menu_book_rounded,
              size: 250.w,
              color: theme.primaryColor.withOpacity(isDark ? 0.03 : 0.05),
            ),
          ),
          ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final key = surahs.keys.elementAt(index);
              final surah = surahs[key]!;
              return _buildSurahCard(context, surah, key, theme, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(
    BuildContext context,
    Map<String, dynamic> surah,
    int num,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Get.to(() => QuranReaderScreen(surah: surah));
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  num.toString(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah['name'],
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${surah['verses'].length} Verses",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                surah['arabicName'],
                style: TextStyle(
                  fontSize: 24.sp,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuranReaderScreen extends StatelessWidget {
  final Map<String, dynamic> surah;

  const QuranReaderScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final verses = surah['verses'] as List;

    return Scaffold(
      appBar: CommonAppBar(title: surah['name']),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: verses.length,
        separatorBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Divider(color: theme.dividerColor.withOpacity(0.1)),
        ),
        itemBuilder: (context, index) {
          final verse = verses[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  verse['arabic'],
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontFamily: 'Amiri',
                    height: 1.8,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "${index + 1}. ${verse['translation']}",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
