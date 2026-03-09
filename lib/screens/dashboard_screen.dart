import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:namaz_timetable/controllers/prayer_controller.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:namaz_timetable/widgets/digital_clock.dart';
import 'package:namaz_timetable/widgets/scroll_ticker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:namaz_timetable/services/weather_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PrayerController controller = Get.find<PrayerController>();

  String currentArea = '';
  String currentCity = 'Mumbai';
  String currentState = '';
  String currentCountry = 'India';
  String currentPincode = '';

  double? currentTemp;
  List<Map<String, String>> dailyCards = [];

  @override
  void initState() {
    super.initState();
    _loadLocationAndWeather();
    _fetchBanners();
    SettingsService.onLocationChanged.addListener(_onLocationUpdated);
  }

  void _onLocationUpdated() {
    if (mounted) {
      _loadLocationAndWeather();
    }
  }

  Future<void> _loadLocationAndWeather() async {
    final location = await SettingsService.getLocation();
    setState(() {
      currentArea = location['area'] ?? '';
      currentCity = location['city']!;
      currentState = location['state'] ?? '';
      currentCountry = location['country']!;
      currentPincode = location['pincode'] ?? '';
    });

    double? lat = location['latitude'] as double?;
    double? lon = location['longitude'] as double?;

    if (lat == null || lat == 0.0) {
      lat = 19.0760;
      lon = 72.8777;
    }

    _fetchTemperature(lat, lon);
  }

  Future<void> _fetchBanners() async {
    try {
      final List<Map<String, String>> fetchedCards = [];

      // 1. Fetch Random Ayah from API
      try {
        final resEn = await http.get(Uri.parse('https://api.alquran.cloud/v1/ayah/random/en.asad'));
        if (resEn.statusCode == 200) {
          final dataEn = json.decode(resEn.body)['data'];

          final resAr = await http.get(
            Uri.parse('https://api.alquran.cloud/v1/ayah/${dataEn['number']}'),
          );
          String textAr = '';
          if (resAr.statusCode == 200) {
            textAr = json.decode(resAr.body)['data']['text'];
          }

          fetchedCards.add({
            'type': 'Daily Ayah',
            'arabic': textAr,
            'translation': dataEn['text'],
            'reference': 'Surah ${dataEn['surah']['englishName']}, Ayah ${dataEn['numberInSurah']}',
            'color1': '#00b4db',
            'color2': '#0083b0',
          });
        }
      } catch (e) {
        // Silently ignore API fail for Ayah
      }

      // 2. Add a fallback/static Dua
      fetchedCards.add({
        'type': 'Daily Dua',
        'arabic':
            'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        'translation':
            'Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good and protect us from the punishment of the Fire.',
        'reference': 'Surah Al-Baqarah, 2:201',
        'color1': '#11998e',
        'color2': '#38ef7d',
      });

      // 3. Add a fallback/static Hadith
      fetchedCards.add({
        'type': 'Daily Hadith',
        'arabic': 'مَنْ لَا يَرْحَمُ لَا يُرْحَمُ',
        'translation': 'He who does not show mercy to others, Allah will not show mercy to him.',
        'reference': 'Sahih Al-Bukhari',
        'color1': '#8A2387',
        'color2': '#E94057',
      });

      if (!mounted) return;
      setState(() {
        dailyCards = fetchedCards;
      });
    } catch (e) {
      debugPrint("Failed to fetch banners: $e");
    }
  }

  Future<void> _fetchTemperature(double? lat, double? lon) async {
    if (lat != null && lon != null) {
      final temp = await WeatherService.getTemperature(lat, lon);
      if (mounted) {
        setState(() {
          currentTemp = temp;
        });
      }
    }
  }

  @override
  void dispose() {
    SettingsService.onLocationChanged.removeListener(_onLocationUpdated);
    super.dispose();
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty || timeStr == 'N/A') return '';
    try {
      final cleanTime = timeStr.split(' ')[0];
      final parsed = DateFormat('HH:mm').parse(cleanTime);
      return DateFormat('hh:mm a').format(parsed);
    } catch (e) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        centerTitle: false,
        style: TextStyle(fontSize: 13.sp),
        title: [
          currentArea,
          currentCity,
          currentPincode,
        ].where((e) => e.trim().isNotEmpty).join(', '),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final model = controller.prayerTimes.value;
        if (model == null) return const Center(child: Text("Error loading times"));

        final sunriseTime = _formatTime(model.timings['Sunrise'] ?? '');
        final sunsetTime = _formatTime(model.timings['Sunset'] ?? model.timings['Maghrib'] ?? '');

        return Column(
          children: [
            ScrollTicker(
              message:
                  "👉 Welcome to Salatuk Timetable • Daily Salah & Ramzan Updates • Please keep your phone on silent 📵 during Jamaat • 🤲 Pray on time to be successful in both worlds • May Allah 🕋 accept our prayers • JazakAllah Khair"
                      .tr,
            ),
            SizedBox(height: 14.h),
            DigitalClock(
              nextPrayer: controller.nextPrayer.value,
              nextJamaatTime: controller.nextJamaatTime.value,
              hijriOffset: controller.hijriOffset.value,
              hijriDateString: controller.prayerTimes.value?.hijri,
              sunrise: sunriseTime,
              sunset: sunsetTime,
              temperature: currentTemp,
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 180.h,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  viewportFraction: 0.85,
                ),
                items: dailyCards.isEmpty
                    ? [const Center(child: CircularProgressIndicator())]
                    : dailyCards.map((cardData) {
                        final type = cardData['type'];
                        IconData typeIcon;
                        switch (type) {
                          case 'Daily Dua':
                            typeIcon = Icons.auto_awesome;
                            break;
                          case 'Daily Hadith':
                            typeIcon = Icons.history_edu;
                            break;
                          default:
                            typeIcon = Icons.menu_book;
                        }

                        final Color c1 = Color(
                          int.parse(cardData['color1']!.replaceFirst('#', '0xFF')),
                        );
                        final Color c2 = Color(
                          int.parse(cardData['color2']!.replaceFirst('#', '0xFF')),
                        );

                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            gradient: LinearGradient(
                              colors: [c1, c2],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c2.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(typeIcon, size: 14.sp, color: Colors.white),
                                      SizedBox(width: 4.w),
                                      Text(
                                        cardData['type']!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                if (cardData['arabic']!.isNotEmpty)
                                  Text(
                                    cardData['arabic']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                      fontFamily: 'Amiri',
                                    ),
                                  ),
                                SizedBox(height: 8.h),
                                Text(
                                  cardData['translation']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  "- ${cardData['reference']!} -",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
