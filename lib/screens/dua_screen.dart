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
      {
        "title": "بیت الخلا (Toilet) میں داخل ہونے کی دعا",
        "text":
            "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ\n\nترجمہ: اے اللہ! میں خبیث جنوں اور جنیوں سے تیری پناہ مانگتا ہوں۔",
      },
      {
        "title": "بیت الخلا سے نکلنے کی دعا",
        "text": "غُفْرَانَكَ\n\nترجمہ: (اے اللہ) میں تیری بخشش کا طلبگار ہوں۔",
      },
      {
        "title": "وضو کے بعد کی دعا",
        "text":
            "أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ\n\nترجمہ: میں گواہی دیتا ہوں کہ اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، اور میں گواہی دیتا ہوں کہ محمد (صلی اللہ علیہ وسلم) اس کے بندے اور رسول ہیں۔",
      },
      {
        "title": "لباس پہننے کی دعا",
        "text":
            "الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ\n\nترجمہ: تمام تعریفیں اللہ کے لیے ہیں جس نے مجھے یہ کپڑا پہنایا اور میری کسی طاقت اور قوت کے بغیر مجھے یہ عطا فرمایا۔",
      },
      {
        "title": "آئینہ دیکھنے کی دعا",
        "text":
            "اللَّهُمَّ أَنْتَ حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي\n\nترجمہ: اے اللہ! تو نے میری صورت اچھی بنائی ہے، پس میرے اخلاق بھی اچھے کر دے۔",
      },
      {
        "title": "علم میں اضافے کی دعا",
        "text": "رَّبِّ زِدْنِي عِلْمًا\n\nترجمہ: اے میرے رب! میرے علم میں اضافہ فرما۔",
      },
      {
        "title": "دنیا و آخرت کی بھلائی کی دعا",
        "text":
            "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n\nترجمہ: اے ہمارے رب! ہمیں دنیا میں بھی بھلائی عطا فرما اور آخرت میں بھی بھلائی عطا فرما اور ہمیں آگ کے عذاب سے بچا۔",
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
      {
        "title": "शौचालय (Toilet) में प्रवेश की दुआ",
        "text":
            "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ\n\nअनुवाद: अल्लाहुम्मा इन्नी अऊज़ु बिका मिनल खुबुसि वल खबाइसि\nतर्जुमा: ऐ अल्लाह! मैं खबीस और गंदे जिन्नों से तेरी पनाह मांगता हूँ।",
      },
      {
        "title": "शौचालय से बाहर निकलने की दुआ",
        "text":
            "غُفْرَانَكَ\n\nअनुवाद: गुफ़रानका\nतर्जुमा: (ऐ अल्लाह) मैं तेरी माफी (बख्शिश) मांगता हूँ।",
      },
      {
        "title": "वज़ू के बाद की दुआ",
        "text":
            "أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ\n\nअनुवाद: अश्हदु अल्ला इलाहा इल्लल्लाहु वह्दहू ला शरीका लहू व अश्हदु अन्ना मुहम्मदं अब्दुहू व रसूलुह\nतर्जुमा: मैं गवाही देता हूँ कि अल्लाह के सिवा कोई माबूद नहीं, वो अकेला है, उसका कोई शरीक नहीं, और मैं गवाही देता हूँ कि मुहम्मद (सल्ल.) उसके बंदे और रसूल हैं।",
      },
      {
        "title": "कपड़े पहनने की दुआ",
        "text":
            "الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ\n\nअनुवाद: अल्हम्दु लिल्लाहिल-लज़ी कसानी हाज़ा व रज़क़नीहि मिन गैरि हवलिम-मिन्नी व ला कुव्वह\nतर्जुमा: सब तारीफें उस अल्लाह के लिए हैं जिसने मुझे ये लिबास पहनाया और मेरी किसी कोशिश और ताक़त के बगैर मुझे ये अता किया।",
      },
      {
        "title": "आईना देखने की दुआ",
        "text":
            "اللَّهُمَّ أَنْتَ حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي\n\nअनुवाद: अल्लाहुम्मा अंता हस्सन्ता खल्की फ हस्सिन खुलुकी\nतर्जुमा: ऐ अल्लाह! तूने मेरी सूरत अच्छी बनाई है, मेरे अख़लाक़ भी अच्छे कर दे।",
      },
      {
        "title": "इल्म (ज्ञान) में इज़ाफे की दुआ",
        "text":
            "رَّبِّ زِدْنِي عِلْمًا\n\nअनुवाद: रब्बि ज़िदनी इल्मा\nतर्जुमा: ऐ मेरे रब! मेरे इल्म (ज्ञान) में इज़ाफा फरमा।",
      },
      {
        "title": "दुनिया और आख़िरत में भलाई की दुआ",
        "text":
            "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n\nअनुवाद: रब्बना आतिना फिद-दुनिया हसनतंव-वफ़िल आख़िरति हसनतंव-वकिना अज़ाबन्नार\nतर्जुमा: ऐ हमारे रब! हमें दुनिया में भी भलाई दे और आख़िरत में भी भलाई दे और हमें आग के अज़ाब से बचा।",
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
      {
        "title": "Entering Toilet",
        "text":
            "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ\n\nAllahumma innee a'oodhu bika minal-khubuthi wal-khaba-ith\nTranslation: O Allah, I seek refuge with You from all offensive and wicked things (evil spirits).",
      },
      {
        "title": "Leaving Toilet",
        "text": "غُفْرَانَكَ\n\nGhufranaka\nTranslation: I ask You (Allah) for forgiveness.",
      },
      {
        "title": "After Wudu",
        "text":
            "أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ\n\nAsh-hadu alla ilaha illallahu wahdahu la shareeka lahu wa ash-hadu anna Muhammadan 'abduhu wa Rasooluhu\nTranslation: I bear witness that none has the right to be worshipped but Allah alone, Who has no partner; and I bear witness that Muhammad is His slave and His Messenger.",
      },
      {
        "title": "Wearing Clothes",
        "text":
            "الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ\n\nAlhamdu lillahil-lathee kasanee hatha warazaqaneehi min ghayri hawlin minnee wala quwwatin\nTranslation: Praise be to Allah who has clothed me with this garment and provided it for me, with no power or might from myself.",
      },
      {
        "title": "Looking in Mirror",
        "text":
            "اللَّهُمَّ أَنْتَ حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي\n\nAllahumma anta hassanta khalqi fahassin khuluqi\nTranslation: O Allah, just as You have made my external form beautiful, make my character beautiful as well.",
      },
      {
        "title": "For Knowledge",
        "text":
            "رَّبِّ زِدْنِي عِلْمًا\n\nRabbi zidnee 'ilman\nTranslation: O my Lord, increase me in knowledge.",
      },
      {
        "title": "For Success in World & Hereafter",
        "text":
            "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n\nRabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan waqina 'adhaban-nar\nTranslation: Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good and protect us from the punishment of the Fire.",
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
                
                // Dua List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    itemCount: duas.length,
                    itemBuilder: (context, index) {
                      final dua = duas[index];
                      return _DuaExpansionTile(
                        dua: dua,
                        isUrdu: _selectedLanguage == 'Urdu',
                        isHindi: _selectedLanguage == 'Hindi',
                        primaryColor: theme.colorScheme.primary,
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

class _DuaExpansionTile extends StatefulWidget {
  final Map<String, String> dua;
  final bool isUrdu;
  final bool isHindi;
  final Color primaryColor;

  const _DuaExpansionTile({
    required this.dua,
    required this.isUrdu,
    required this.isHindi,
    required this.primaryColor,
  });

  @override
  State<_DuaExpansionTile> createState() => _DuaExpansionTileState();
}

class _DuaExpansionTileState extends State<_DuaExpansionTile> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: _isExpanded ? Colors.blueGrey.withOpacity(0.1) : Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _isExpanded
              ? Colors.blueGrey.withOpacity(0.2)
              : theme.dividerColor.withOpacity(0.05),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // Header (Title) - Tighter Padding
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isExpanded = !_isExpanded);
            },
            borderRadius: BorderRadius.circular(18.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: _isExpanded
                          ? Colors.blueGrey.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmarks_rounded,
                      size: 16.sp,
                      color: _isExpanded ? Colors.blueGrey : Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.dua['title']!,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: _isExpanded ? FontWeight.w800 : FontWeight.w700,
                        color: _isExpanded
                            ? Colors.blueGrey.shade700
                            : theme.colorScheme.onSurface.withOpacity(0.8),
                        letterSpacing: -0.3,
                      ),
                      textDirection: widget.isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 20.sp,
                      color: _isExpanded ? Colors.blueGrey : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details (Expanded Content) - Minimalist Spacing
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              heightFactor: _isExpanded ? 1.0 : 0.0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: SelectableText(
                        widget.dua['text']!,
                        style: TextStyle(fontSize: 14.sp, height: 1.6, fontWeight: FontWeight.w500),
                        textAlign: widget.isUrdu ? TextAlign.right : TextAlign.left,
                        textDirection: widget.isUrdu ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Action Buttons - Compact
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _ActionButton(
                          icon: Icons.content_copy_rounded,
                          label: 'Copy',
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: "${widget.dua['title']}\n\n${widget.dua['text']}",
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Dua copied".tr),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 8.w),
                        _ActionButton(
                          icon: Icons.ios_share_rounded,
                          label: 'Share',
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: "${widget.dua['title']}\n\n${widget.dua['text']}",
                              ),
                            );
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text("Link copied".tr)));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14.sp, color: Colors.blueGrey),
            SizedBox(width: 4.w),
            Text(
              label.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
