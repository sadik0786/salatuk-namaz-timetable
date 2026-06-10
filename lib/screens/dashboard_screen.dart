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
import 'package:namaz_timetable/screens/prayer_tracker_screen.dart';
import 'package:namaz_timetable/screens/zakat_calculator_screen.dart';
import 'package:namaz_timetable/screens/qibla_screen.dart';
import 'package:namaz_timetable/screens/asma_ul_husna_screen.dart';
import 'package:namaz_timetable/screens/quran_screen.dart';
import 'package:namaz_timetable/screens/calendar_screen.dart';

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
        final resEn = await http.get(
          Uri.parse('https://api.alquran.cloud/v1/ayah/random/en.asad'),
        );
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
            'reference':
                'Surah ${dataEn['surah']['englishName']}, Ayah ${dataEn['numberInSurah']}',
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
        'translation':
            'He who does not show mercy to others, Allah will not show mercy to him.',
        'reference': 'Sahih Al-Bukhari',
        'color1': '#8A2387',
        'color2': '#E94057',
      });

      // 4. Ayatul Kursi
      fetchedCards.add({
        'type': 'Ayatul Kursi',
        'arabic':
            'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        'translation':
            'Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is [presently] before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
        'reference': 'Surah Al-Baqarah, 2:255',
        'color1': '#4e54c8',
        'color2': '#8f94fb',
      });

      // 5. Surah Al-Ikhlas
      fetchedCards.add({
        'type': 'Surah Ikhlas',
        'arabic':
            'قُلْ هُوَ اللَّهُ أَحَدٌ اللَّهُ الصَّمَدُ لَمْ يَلِدْ وَلَمْ يُولَدْ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        'translation':
            'Say, "He is Allah, [who is] One, Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent."',
        'reference': 'Surah Al-Ikhlas, 112',
        'color1': '#F2994A',
        'color2': '#F2C94C',
      });

      // 6. Surah Al-Falaq
      fetchedCards.add({
        'type': 'Surah Falak',
        'arabic':
            'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ مِن شَرِّ مَا خَلَقَ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        'translation':
            'Say, "I seek refuge in the Lord of daybreak From the evil of that which He created And from the evil of darkness when it settles And from the evil of the blowers in knots And from the evil of an envier when he envies."',
        'reference': 'Surah Al-Falaq, 113',
        'color1': '#00b09b',
        'color2': '#96c93d',
      });

      // 7. Surah An-Nas
      fetchedCards.add({
        'type': 'Surah An-Nas',
        'arabic':
            'قُلْ أَعُوذُ بِرَبِّ النَّاسِ مَلِكِ النَّاسِ إِلَٰهِ النَّاسِ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ مِنَ الْجِنَّةِ وَالنَّاسِ',
        'translation':
            'Say, "I seek refuge in the Lord of mankind, The Sovereign of mankind, The God of mankind, From the evil of the retreating whisperer - Who whispers [evil] into the breasts of mankind - From among the jinn and mankind."',
        'reference': 'Surah An-Nas, 114',
        'color1': '#e65c00',
        'color2': '#F9D423',
      });

      // 8. Surah Al-Kafirun
      fetchedCards.add({
        'type': 'Surah Al-Kafirun',
        'arabic':
            'قُلْ يَا أَيُّهَا الْكَافِرُونَ لَا أَعْبُدُ مَا تَعْبُدُونَ وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ وَلَا أَنَا عَابِدٌ مَا عَبَدتُّمْ وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ لَكُمْ دِينُكُمْ وَلِيَ دِينِ',
        'translation':
            'Say, "O disbelievers, I do not worship what you worship. Nor are you worshippers of what I worship. Nor will I be a worshipper of what you have worshipped. Nor will you be worshippers of what I worship. For you is your religion, and for me is my religion."',
        'reference': 'Surah Al-Kafirun, 109',
        'color1': '#1e3c72',
        'color2': '#2a5298',
      });

      // 9. Surah Al-Fatiha
      fetchedCards.add({
        'type': 'Surah Al-Fatiha',
        'arabic':
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ الرَّحْمَٰنِ الرَّحِيمِ مَالِكِ يَوْمِ الدِّينِ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
        'translation':
            'In the name of Allah, the Entirely Merciful, the Especially Merciful. [All] praise is [due] to Allah, Lord of the worlds - The Entirely Merciful, the Especially Merciful, Sovereign of the Day of Recompense. It is You we worship and You we ask for help. Guide us to the straight path - The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
        'reference': 'Surah Al-Fatiha, 1',
        'color1': '#0f0c29',
        'color2': '#302b63',
      });

      // 10. Dua for Knowledge
      fetchedCards.add({
        'type': 'Daily Dua',
        'arabic': 'رَّبِّ زِدْنِي عِلْمًا',
        'translation': 'My Lord, increase me in knowledge.',
        'reference': 'Surah Ta-Ha, 20:114',
        'color1': '#000000',
        'color2': '#434343',
      });

      // 11. Dua for Parents
      fetchedCards.add({
        'type': 'Daily Dua',
        'arabic': 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
        'translation':
            'My Lord, have mercy upon them as they brought me up [when I was] small.',
        'reference': 'Surah Al-Isra, 17:24',
        'color1': '#6a11cb',
        'color2': '#2575fc',
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: CommonAppBar(
        centerTitle: false,
        style: TextStyle(fontSize: 13.sp),
        title: [
          currentArea,
          currentCity,
          currentState,
          currentCountry,
          currentPincode,
        ].where((e) => e.trim().isNotEmpty).join(', '),
      ),
      body: Stack(
        children: [
          Positioned(
            right: -50.w,
            bottom: -50.w,
            child: Icon(
              Icons.mosque,
              size: 250.w,
              color: theme.primaryColor.withOpacity(isDark ? 0.03 : 0.05),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final model = controller.prayerTimes.value;
            if (model == null) {
              return Center(child: Text("Error loading times".tr));
            }

            final sunriseTime = _formatTime(model.timings['Sunrise'] ?? '');
            final sunsetTime = _formatTime(
              model.timings['Sunset'] ?? model.timings['Maghrib'] ?? '',
            );

            return SingleChildScrollView(
              child: Column(
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
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 180.h,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      viewportFraction: 0.85,
                    ),
                    items: dailyCards.isEmpty
                        ? [const Center(child: CircularProgressIndicator())]
                        : dailyCards.map((cardData) {
                            // ... existing item code ...
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
                              int.parse(
                                cardData['color1']!.replaceFirst('#', '0xFF'),
                              ),
                            );
                            final Color c2 = Color(
                              int.parse(
                                cardData['color2']!.replaceFirst('#', '0xFF'),
                              ),
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            typeIcon,
                                            size: 14.sp,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            cardData['type']!.tr,
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
                                      cardData['translation']!.tr,
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
                  SizedBox(height: 16.h),
                  _buildToolsGrid(context, isDark),
                  SizedBox(height: 16.h),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Islamic Tools".tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildToolCard(
                context,
                "Prayer Tracker".tr,
                Icons.track_changes_rounded,
                Colors.orange,
                () => Get.to(() => const PrayerTrackerScreen()),
              ),
              SizedBox(width: 12.w),
              _buildToolCard(
                context,
                "Zakat Calculator".tr,
                Icons.calculate,
                Colors.green,
                () => Get.to(() => const ZakatCalculatorScreen()),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildToolCard(
                context,
                "Find Qibla".tr,
                Icons.explore,
                Colors.blue,
                () => Get.to(() => const QiblaScreen()),
              ),
              SizedBox(width: 12.w),
              _buildToolCard(
                context,
                "99 Names".tr,
                Icons.volunteer_activism_rounded,
                Colors.pink,
                () => Get.to(() => const AsmaUlHusnaScreen()),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildToolCard(
                context,
                "Calendar".tr,
                Icons.calendar_month,
                Colors.purple,
                () => Get.to(() => const CalendarScreen()),
              ),
              SizedBox(width: 12.w),
              _buildToolCard(
                context,
                "Quran".tr,
                Icons.menu_book_rounded,
                Colors.teal,
                () => Get.to(() => const QuranScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
