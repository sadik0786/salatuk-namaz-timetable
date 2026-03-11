import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:namaz_timetable/config/api_config.dart';

class RamzanScreen extends StatefulWidget {
  const RamzanScreen({super.key});

  @override
  State<RamzanScreen> createState() => _RamzanScreenState();
}

class _RamzanScreenState extends State<RamzanScreen> {
  String currentCity = 'Mumbai';
  String currentCountry = 'India';
  double? latitude;
  double? longitude;
  int calculationMethod = 1;
  int hijriOffset = 0;
  bool isLoading = true;
  List<dynamic> ramzanData = [];
  String errorMessage = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeApp();
    SettingsService.onLocationChanged.addListener(_onLocationUpdated);
  }

  void _onLocationUpdated() {
    if (mounted) {
      _initializeApp();
    }
  }

  @override
  void dispose() {
    SettingsService.onLocationChanged.removeListener(_onLocationUpdated);
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(String timeStr) {
    try {
      final cleanTime = timeStr.split(' ')[0];
      final parsed = DateFormat('HH:mm').parse(cleanTime);
      return DateFormat('hh:mm a').format(parsed).toLowerCase();
    } catch (e) {
      return timeStr;
    }
  }

  Future<void> _initializeApp() async {
    final location = await SettingsService.getLocation();
    currentCity = location['city']!;
    currentCountry = location['country']!;
    latitude = location['latitude'] as double?;
    longitude = location['longitude'] as double?;
    calculationMethod = location['calculationMethod'] as int? ?? 1;
    hijriOffset = location['hijriOffset'] as int? ?? 0;
    await _fetchRamzanData();
  }

  Future<void> _fetchRamzanData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      Uri url;
      if (latitude != null && longitude != null) {
        url = Uri.parse(
          ApiConfig.hijriCalendarByLocation(
            _getHijriYear(),
            9,
            latitude!,
            longitude!,
            calculationMethod,
            hijriOffset,
          ),
        );
      } else {
        url = Uri.parse(
          ApiConfig.hijriCalendarByCity(
            _getHijriYear(),
            9,
            currentCity,
            currentCountry,
            calculationMethod,
            hijriOffset,
          ),
        );
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'] as List<dynamic>;

        if (hijriOffset != 0 && data.isNotEmpty) {
          if (hijriOffset < 0) {
            final dropCount = hijriOffset.abs();
            if (dropCount < data.length) {
              data = data.sublist(dropCount);
            }
            final lastDateStr = data.last['date']['gregorian']['date'];
            final baseDate = DateFormat('dd-MM-yyyy').parse(lastDateStr);

            final futures = <Future>[];
            for (int i = 1; i <= dropCount; i++) {
              final nextDate = baseDate.add(Duration(days: i));
              final nextDateStr = DateFormat('dd-MM-yyyy').format(nextDate);
              futures.add(_fetchSingleDay(nextDateStr));
            }

            final extraDays = await Future.wait(futures);
            for (var day in extraDays) {
              if (day != null) data.add(day);
            }
          } else {
            final dropCount = hijriOffset;
            if (dropCount < data.length) {
              data = data.sublist(0, data.length - dropCount);
            }
            final firstDateStr = data.first['date']['gregorian']['date'];
            final baseDate = DateFormat('dd-MM-yyyy').parse(firstDateStr);

            final futures = <Future>[];
            for (int i = dropCount; i >= 1; i--) {
              final prevDate = baseDate.subtract(Duration(days: i));
              final prevDateStr = DateFormat('dd-MM-yyyy').format(prevDate);
              futures.add(_fetchSingleDay(prevDateStr));
            }

            final extraDays = await Future.wait(futures);
            for (int i = extraDays.length - 1; i >= 0; i--) {
              if (extraDays[i] != null) data.insert(0, extraDays[i]);
            }
          }
        }

        if (mounted) {
          setState(() {
            ramzanData = data;
            isLoading = false;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToToday();
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Could not fetch Ramzan timetable. Please check your connection.'.tr;
        });
      }
    }
  }

  Future<dynamic> _fetchSingleDay(String dateStr) async {
    try {
      Uri url;
      if (latitude != null && longitude != null) {
        url = Uri.parse(
          ApiConfig.timingsSingleDayLocation(dateStr, latitude!, longitude!, calculationMethod),
        );
      } else {
        url = Uri.parse(
          ApiConfig.timingsSingleDayCity(dateStr, currentCity, currentCountry, calculationMethod),
        );
      }
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      }
    } catch (_) {}
    return null;
  }

  int _getHijriYear() {
    final nowWithOffset = DateTime.now().add(Duration(days: hijriOffset));
    return HijriCalendar.fromDate(nowWithOffset).hYear;
  }

  void _scrollToToday() {
    if (!_scrollController.hasClients || ramzanData.isEmpty) return;

    final todayString = DateFormat('dd-MM-yyyy').format(DateTime.now());
    int todayIndex = ramzanData.indexWhere((dayData) {
      final date = dayData['date'];
      final gregorianDate = date['gregorian']['date'];
      return gregorianDate == todayString;
    });

    if (todayIndex != -1) {
      final estimatedPosition = todayIndex * 110.0;
      _scrollController.animateTo(
        estimatedPosition,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(centerTitle: false, title: "Ramzan Timetable".tr),
      body: ValueListenableBuilder<String>(
        valueListenable: SettingsService.languageNotifier,
        builder: (context, lang, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/ramzan_banner.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage.isNotEmpty
                      ? Center(
                          child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: ramzanData.length,
                          itemBuilder: (context, index) {
                            final dayData = ramzanData[index];
                            final timings = dayData['timings'];
                            final date = dayData['date'];

                            final rozaNo = index + 1;
                            final suhoor = _formatTime(timings['Imsak'] ?? timings['Fajr']);
                            final iftar = _formatTime(timings['Maghrib']);
                            final gregorianDate = date['gregorian']['date'];
                            final isToday =
                                gregorianDate == DateFormat('dd-MM-yyyy').format(DateTime.now());

                            return Card(
                              elevation: isToday ? 8 : 2,
                              shadowColor: isToday
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                                  : null,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: isToday
                                    ? BorderSide(
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 2.w,
                                      )
                                    : BorderSide.none,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40.w,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.secondaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "$rozaNo",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.sp,
                                            color: isToday
                                                ? Theme.of(context).colorScheme.onPrimary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSecondaryContainer,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${date['gregorian']['weekday']['en'].toString().tr}, $gregorianDate",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              _TimeColumn(
                                                label: "SEHR".tr,
                                                time: suhoor,
                                                icon: Icons.nightlight_round,
                                              ),
                                              _TimeColumn(
                                                label: "IFTAR".tr,
                                                time: iftar,
                                                icon: Icons.wb_sunny_rounded,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;

  const _TimeColumn({required this.label, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          time,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
