import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:namaz_timetable/config/api_config.dart';
import 'package:get/get.dart';

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
  int? selectedHijriYear;

  Timer? _countdownTimer;
  String _timeRemaining = "";
  String _remainingLabel = "";
  double _ramadanProgress = 0.0;

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
    _countdownTimer?.cancel();
    SettingsService.onLocationChanged.removeListener(_onLocationUpdated);
    _scrollController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (ramzanData.isEmpty) return;

    final now = DateTime.now();
    final todayStr = DateFormat('dd-MM-yyyy').format(now);

    final todayDataIdx = ramzanData.indexWhere((d) => d['date']['gregorian']['date'] == todayStr);
    if (todayDataIdx == -1) {
      setState(() {
        _timeRemaining = "";
        _ramadanProgress = 0.0;
      });
      return;
    }

    final todayData = ramzanData[todayDataIdx];
    final timings = todayData['timings'];

    final suhoorStr = timings['Imsak'] ?? timings['Fajr'];
    final iftarStr = timings['Maghrib'];

    final suhoorTime = _parseTimeToToday(suhoorStr);
    final iftarTime = _parseTimeToToday(iftarStr);

    String newLabel = "";
    String newRemaining = "";

    if (now.isBefore(suhoorTime)) {
      newLabel = "Suhoor Ends in".tr;
      newRemaining = _formatDuration(suhoorTime.difference(now));
    } else if (now.isBefore(iftarTime)) {
      newLabel = "Iftar Starts in".tr;
      newRemaining = _formatDuration(iftarTime.difference(now));
    } else {
      newLabel = "Iftar Completed".tr;
      newRemaining = "";
    }

    if (mounted) {
      setState(() {
        _remainingLabel = newLabel;
        _timeRemaining = newRemaining;
        _ramadanProgress = (todayDataIdx + 1) / ramzanData.length;
      });
    }
  }

  DateTime _parseTimeToToday(String timeStr) {
    final now = DateTime.now();
    final clean = timeStr.split(' ')[0];
    final parts = clean.split(':');
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatDuration(Duration d) {
    String h = d.inHours.toString().padLeft(2, '0');
    String m = (d.inMinutes % 60).toString().padLeft(2, '0');
    String s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
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

    selectedHijriYear ??= _getHijriYear();

    await _fetchRamzanData();
  }

  Future<void> _fetchRamzanData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      final hYear = selectedHijriYear ?? _getHijriYear();

      // Calculate Gregorian start of Ramadan for the selected Hijri year
      final h = HijriCalendar();
      // standard 1 Ramadan (unadjusted)
      final gStart = h.hijriToGregorian(hYear, 9, 1);

      List<dynamic> combinedData = [];

      Future<List<dynamic>> fetchMonth(int m, int y) async {
        Uri monthUrl;
        if (latitude != null && longitude != null) {
          monthUrl = Uri.parse(
            ApiConfig.calendarByLocation(
              y,
              m,
              latitude!,
              longitude!,
              calculationMethod,
              hijriOffset,
            ),
          );
        } else {
          monthUrl = Uri.parse(
            ApiConfig.calendarByCity(
              y,
              m,
              currentCity,
              currentCountry,
              calculationMethod,
              hijriOffset,
            ),
          );
        }
        final resp = await http.get(monthUrl);
        if (resp.statusCode == 200) {
          return json.decode(resp.body)['data'] as List<dynamic>;
        }
        return [];
      }

      // Fetch overlapping months to ensure we get a full Ramadan
      final month1 = await fetchMonth(gStart.month, gStart.year);
      DateTime nextMonthDate = DateTime(gStart.year, gStart.month + 1, 1);
      final month2 = await fetchMonth(nextMonthDate.month, nextMonthDate.year);
      
      combinedData.addAll(month1);
      combinedData.addAll(month2);

      // FILTER & SYNC: Calculate Hijri dates locally to match digital clock/app settings
      final ramadanDataFiltered = <dynamic>[];
      for (var day in combinedData) {
        try {
          final gDateStr = day['date']['gregorian']['date']; // dd-MM-yyyy
          final parts = gDateStr.split('-');
          final gDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          
          // Apply same offset logic as digital clock/app
          final localH = HijriCalendar.fromDate(gDate.add(Duration(days: hijriOffset)));
          
          if (localH.hMonth == 9) {
            // Override the Hijri data in the map to match our local (correct) calculation
            var hMap = Map<String, dynamic>.from(day['date']['hijri']);
            hMap['day'] = localH.hDay.toString();
            hMap['month'] = {
              'number': 9,
              'en': 'Ramadan', // Standard name used in translations
              'ar': 'رمضان',
            };
            hMap['year'] = localH.hYear.toString();
            
            var newDay = Map<String, dynamic>.from(day);
            newDay['date'] = Map<String, dynamic>.from(day['date']);
            newDay['date']['hijri'] = hMap;
            
            ramadanDataFiltered.add(newDay);
          }
        } catch (e) {
          debugPrint("Sync error for day: $e");
        }
      }

      if (mounted) {
        setState(() {
          ramzanData = ramadanDataFiltered;
          isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToToday();
          _startCountdown();
        });
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

  Widget _buildYearSelection() {
    final hYear = selectedHijriYear ?? _getHijriYear();
    final gYear = _getGregorianYear(hYear);

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                setState(() => selectedHijriYear = hYear - 1);
                _fetchRamzanData();
              },
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
              color: Theme.of(context).colorScheme.primary,
              visualDensity: VisualDensity.compact,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "$gYear, $hYear Hijri",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() => selectedHijriYear = hYear + 1);
                _fetchRamzanData();
              },
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              color: Theme.of(context).colorScheme.primary,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  int _getGregorianYear(int hYear) {
    try {
      final h = HijriCalendar();
      return h.hijriToGregorian(hYear, 9, 1).year;
    } catch (e) {
      return hYear + 579;
    }
  }

  Widget _buildStatusCards() {
    if (_timeRemaining.isEmpty && _ramadanProgress == 0.0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          if (_timeRemaining.isNotEmpty)
            Container(
              width: 270.w,
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 12.w),
                  Text(
                    _remainingLabel,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    _timeRemaining,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Digital7',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _ramadanProgress,
                    minHeight: 10,
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "${(_ramadanProgress * ramzanData.length).toInt()}/${ramzanData.length}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ],
          ),
        ],
      ),
    );
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
                    'assets/images/ramzan_banner.jpg',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildYearSelection(),
                SizedBox(height: 12.h),
                _buildStatusCards(),
                SizedBox(height: 8.h),
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

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Stack(
                                children: [
                                  Card(
                                    elevation: isToday ? 10 : 1.5,
                                    shadowColor: isToday
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: isToday
                                          ? BorderSide(
                                              color: Theme.of(context).colorScheme.primary,
                                              width: 2.w,
                                            )
                                          : BorderSide.none,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: isToday
                                            ? LinearGradient(
                                                colors: [
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary.withOpacity(0.08),
                                                  Theme.of(context).colorScheme.surface,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 12.h,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30.w,
                                            height: 30.h,
                                            decoration: BoxDecoration(
                                              color: isToday
                                                  ? Theme.of(context).colorScheme.primary
                                                  : Theme.of(context).colorScheme.secondaryContainer
                                                        .withOpacity(0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "$rozaNo",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                  color: isToday
                                                      ? Theme.of(context).colorScheme.onPrimary
                                                      : Theme.of(
                                                          context,
                                                        ).colorScheme.onSecondaryContainer,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${date['hijri']['day']} ${date['hijri']['month']['en'].toString().tr}",
                                                      style: TextStyle(
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12.sp,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        " • ${date['gregorian']['weekday']['en'].toString().tr}, $gregorianDate",
                                                        style: TextStyle(
                                                          color: Colors.grey.shade600,
                                                          fontSize: 11.sp,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8.h),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: _TimeColumn(
                                                        label: "SEHRI".tr,
                                                        time: suhoor,
                                                        icon: Icons.nightlight_round,
                                                        isToday: isToday,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Expanded(
                                                      child: _TimeColumn(
                                                        label: "IFTAR".tr,
                                                        time: iftar,
                                                        icon: Icons.wb_sunny_rounded,
                                                        isToday: isToday,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // if (isToday)
                                  //   Positioned(
                                  //     top: 6,
                                  //     right: 16,
                                  //     child: Container(
                                  //       padding: EdgeInsets.symmetric(
                                  //         horizontal: 6.w,
                                  //         vertical: 2.h,
                                  //       ),
                                  //       decoration: BoxDecoration(
                                  //         color: Theme.of(context).colorScheme.primary,
                                  //         borderRadius: BorderRadius.circular(8),
                                  //       ),
                                  //       child: Text(
                                  //         "TODAY".tr,
                                  //         style: TextStyle(
                                  //           color: Colors.white,
                                  //           fontSize: 8.sp,
                                  //           fontWeight: FontWeight.bold,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                ],
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
  final bool isToday;

  const _TimeColumn({
    required this.label,
    required this.time,
    required this.icon,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 12.sp,
              color: isToday ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isToday ? Theme.of(context).colorScheme.primary : Colors.grey.shade600,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          time,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ],
    );
  }
}
