import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = SettingsService.languageNotifier.value;
  }

  final Map<String, List<Map<String, String>>> _duasByLanguage = {
    'Urdu': [
      {
        "title": "نیند سے بیدار ہونے کی دعا",
        "text":
            "اَلْحَمْدُ لِلّٰهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ\n\nترجمہ: تمام تعریفیں اس اللہ کے لیے ہیں جس نے ہمیں موت (نیند) کے بعد زندگی دی اور اسی کی طرف اٹھ کر جانا ہے۔",
      },
      {
        "title": "سونے سے پہلے کی دعا",
        "text":
            "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا\n\nترجمہ: اے اللہ! میں تیرے نام کے ساتھ ہی مرتا ہوں اور جیتا ہوں۔",
      },
      {
        "title": "کھانا کھانے سے پہلے کی دعا",
        "text":
            "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ\n\nترجمہ: میں نے اللہ کے نام کے ساتھ اور اللہ کی برکت پر کھانا شروع کیا۔",
      },
      {
        "title": "کھانا کھانے کے بعد کی دعا",
        "text":
            "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ\n\nترجمہ: تمام تعریفیں اللہ کے لیے ہیں جس نے ہمیں کھلایا، پلایا اور ہمیں مسلمان بنایا۔",
      },
      {
        "title": "گھر سے نکلنے کی دعا",
        "text":
            "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ\n\nترجمہ: اللہ کے نام سے، میں نے اللہ پر بھروسہ کیا، گناہوں سے بچنے کی طاقت اور نیکی کرنے کی قوت اللہ ہی کی توفیق سے ہے۔",
      },
      {
        "title": "مسجد میں داخل ہونے کی دعا",
        "text":
            "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ\n\nترجمہ: اے اللہ! میرے لیے اپنی رحمت کے دروازے کھول دے۔",
      },
      {
        "title": "مسجد سے نکلنے کی دعا",
        "text":
            "اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ\n\nترجمہ: اے اللہ! بے شک میں تجھ سے تیرا فضل مانگتا ہوں۔",
      },
      {
        "title": "سفر کی دعا",
        "text":
            "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ\n\nترجمہ: پاک ہے وہ ذات جس نے اس (سواری) کو ہمارے تابع کر دیا حالانکہ ہم اسے قابو کرنے والے نہ تھے، اور بے شک ہم اپنے رب کی طرف ہی لوٹ کر جانے والے ہیں۔",
      },
      {
        "title": "صبح شام کی دعا",
        "text":
            "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ\n\nترجمہ: اللہ کے نام کے ساتھ، جس کے نام کے ساتھ زمین اور آسمان کی کوئی چیز نقصان نہیں پہنچا سکتی اور وہ خوب سننے والا، خوب جاننے والا ہے۔",
      },
      {
        "title": "والدین کے لیے دعا",
        "text":
            "رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا\n\nترجمہ: اے میرے رب! ان دونوں (والدین) پر رحم فرما جیسا کہ انھوں نے بچپن میں مجھے پالا۔",
      },
    ],
    'Hindi': [
      {
        "title": "नींद से उठने की दुआ",
        "text":
            "اَلْحَمْدُ لِلّٰهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ\n\nअनुवाद: अल्हम्दु लिल्लाहिल-लज़ी अह्याना बअ'द मा अमातना व इलैहिन्न-नुशूर\nतर्जुमा: सब तारीफ़ें उस अल्लाह के लिए हैं जिसने हमें मौत (नींद) के बाद ज़िंदा किया और उसी की तरफ लौट कर जाना है।",
      },
      {
        "title": "सोने से पहले की दुआ",
        "text":
            "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا\n\nअनुवाद: बिस्मिल्लाहुम्मा अमुतू वा अह्या\nतर्जुमा: ऐ अल्लाह! मैं तेरे नाम के साथ ही मरता हूँ और जीता हूँ।",
      },
      {
        "title": "खाना खाने से पहले की दुआ",
        "text":
            "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ\n\nअनुवाद: बिस्मिल्लाही व अला बरकतिल्लाह\nतर्जुमा: अल्लाह के नाम के साथ और अल्लाह की बरकत पर खाना शुरू किया।",
      },
      {
        "title": "खाना खाने के बाद की दुआ",
        "text":
            "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ\n\nअनुवाद: अल्हम्दु लिल्लाहिल-लज़ी अतअ'मना व सक़ाना व जअ'लना मुस्लिमीन\nतर्जुमा: सब तारीफ़ें उस अल्लाह के लिए हैं जिसने हमें खिलाया, पिलाया और हमें मुसलमान बनाया।",
      },
      {
        "title": "घर से निकलने की दुआ",
        "text":
            "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ\n\nअनुवाद: बिस्मिल्लाहि तवक्कलतु अलल्लाह, वला हवला वला कुव्वता इल्ला बिल्लाह\nतर्जुमा: अल्लाह के नाम से, मैंने अल्लाह पर भरोसा किया, गुनाहों से बचने की और नेकी करने की ताक़त अल्लाह ही की तौफीक से है।",
      },
      {
        "title": "मस्जिद में दाखिल होने की दुआ",
        "text":
            "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ\n\nअनुवाद: अल्लाहुम्मा-फ़तहली अबवाबा रहमतिक\nतर्जुमा: ऐ अल्लाह! मेरे लिए अपनी रहमत के दरवाज़े खोल दे।",
      },
      {
        "title": "मस्जिद से निकलने की दुआ",
        "text":
            "اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ\n\nअनुवाद: अल्लाहुम्मा इन्नी अस्अलुका मिन फज़्लिक\nतर्जुमा: ऐ अल्लाह! मैं तुझसे तेरा फ़ज़्ल (कृपा) मांगता हूँ।",
      },
      {
        "title": "सफर (यात्रा) की दुआ",
        "text":
            "सُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ\n\nअनुवाद: सुब्हानल-लज़ी सख्खरा लना हाज़ा वमा कुन्ना लहू मुकरिनीन व इन्ना इला रब्बिना लमुनक़लिबून\nतर्जुमा: पाक है वो ज़ात जिसने इस (सवारी) को हमारे ताबे कर दिया हालाँकि हम इसे काबू करने वाले न थे, और बेशक हम अपने रब की तरफ ही लौट कर जाने वाले हैं।",
      },
      {
        "title": "सुबह शाम की दुआ",
        "text":
            "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ\n\nअनुवाद: बिस्मिल्लाहिल-लज़ी ला यज़ुर्ररु मअस-मिही शैउन फ़िल-अर्ज़ि वला फ़िस-समाई वहुवस-समीउल अलीम\nतर्जुमा: अल्लाह के नाम के साथ, जिसके नाम के साथ ज़मीन और आसमान की कोई चीज़ नुकसान नहीं पहुंचा सकती और वो खूब सुनने वाला, खूब जानने वाला है।",
      },
      {
        "title": "वालिदैन (माता-पिता) के लिए दुआ",
        "text":
            "रَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا\n\nअनुवाद: रब्बिर्-हमहुमा कमा रब्बयानी सगीरा\nतर्जुमा: ऐ मेरे रब! उन दोनों (वालिदैन) पर रहम फरमा जैसा कि उन्होंने बचपन में मुझे पाला।",
      },
    ],
    'English': [
      {
        "title": "Waking Up",
        "text":
            "اَلْحَمْدُ لِلّٰهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ\n\nAlhamdu lillahil-lathee ahyana ba'da ma amatana wa ilayhin-nushoor\nTranslation: All praise is due to Allah who gave us life after having taken it from us and unto Him is the resurrection.",
      },
      {
        "title": "Before Sleep",
        "text":
            "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا\n\nBismika Allahumma amutu wa ahya\nTranslation: O Allah, with Your Name I die and I live.",
      },
      {
        "title": "Before Eating",
        "text":
            "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ\n\nBismillahi wa 'alaa barakatillah\nTranslation: In the name of Allah and with the blessings of Allah.",
      },
      {
        "title": "After Eating",
        "text":
            "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ\n\nAlhamdu lillahil-lathee at'amana wasaqana waja'alana muslimeen\nTranslation: All praise is due to Allah who fed us, gave us drink, and made us Muslims.",
      },
      {
        "title": "Leaving Home",
        "text":
            "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ\n\nBismillahi tawakkaltu 'alallah, wa la hawla wa la quwwata illa billah\nTranslation: In the name of Allah, I place my trust in Allah, and there is no might nor power except with Allah.",
      },
      {
        "title": "Entering Mosque",
        "text":
            "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ\n\nAllahummaf-tahlee abwaaba rahmatik\nTranslation: O Allah, open the doors of Your mercy for me.",
      },
      {
        "title": "Leaving Mosque",
        "text":
            "اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ\n\nAllahumma innee as-aluka min fadlik\nTranslation: O Allah, I ask You from Your favor.",
      },
      {
        "title": "Travel Dua",
        "text":
            "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ\n\nSubhanal-lathee sakhkhara lana hatha wama kunna lahu muqrineen wa-inna ila rabbina lamunqaliboon\nTranslation: Glory to Him who has brought this [vehicle] under our control, though we were unable to control it, and indeed, to our Lord we will surely return.",
      },
      {
        "title": "Morning & Evening Dua",
        "text":
            "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ\n\nBismillahil-lathi la yadurru ma'as-mihi shay'un fil-ardi wala fis-sama'i wahuwas-samee'ul 'aleem\nTranslation: In the name of Allah, with whose name nothing on earth or in heaven can cause harm, and He is the All-Hearing, All-Knowing.",
      },
      {
        "title": "Dua For Parents",
        "text":
            "رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا\n\nRabbir hamhuma kama rabbayanee sagheera\nTranslation: My Lord, have mercy upon them as they brought me up [when I was] small.",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: SettingsService.languageNotifier,
      builder: (context, globalLang, _) {
        final duas = _duasByLanguage[_selectedLanguage]!;

        return Scaffold(
          appBar: CommonAppBar(title: "Dua".tr),
          extendBodyBehindAppBar: false,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor,
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                // Fancy Language Selector
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: _duasByLanguage.keys.map((lang) {
                        final isSelected = _selectedLanguage == lang;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedLanguage = lang);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(26.r),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  lang,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : (isDark ? Colors.white60 : Colors.black54),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                // Dua list view... (rest of the code below expansion)
                // Dua list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: duas.length,
                    itemBuilder: (context, index) {
                      final dua = duas[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  dua['title']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                  textDirection: _selectedLanguage == 'Urdu'
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Text
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  dua['text']!,
                                  style: const TextStyle(fontSize: 14, height: 1.4),
                                  textDirection: _selectedLanguage == 'Urdu'
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
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
          ),
        );
      },
    );
  }
}
