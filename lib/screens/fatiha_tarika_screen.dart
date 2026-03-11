import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';

class FatihaTarikaScreen extends StatelessWidget {
  const FatihaTarikaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Fatiha Ka Tarika'.tr),
      body: ValueListenableBuilder<String>(
        valueListenable: SettingsService.languageNotifier,
        builder: (context, lang, _) {
          return ListView(
            padding: EdgeInsets.all(10.w),
            children: [
              _buildStepCard(
                context,
                title: 'Step 1: Durood Shareef'.tr,
                instruction:
                    'Read Durood Shareef 3, 5, 7, or 11 times. (e.g., Durood-e-Ibrahimi)'.tr,
                arabicText:
                    'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ.\nاللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
                hindiText:
                    'अल्लाहुम्मा सल्ले अला मुहम्मदिंव-व अला आलि मुहम्मदिन कमा सल्लैत अला इब्राहीम व अला आलि इब्राहीम इन्नक हमीदुम मजीद\n\nअल्लाहुम्मा बारिक अला मुहम्मदिंव-व अला आलि मुहम्मदिन कमा बारकता अला इब्राहीम व अला आलि इब्राहीम इन्नक हमीदुम-मजीद',
                englishText:
                    'O Allah, let Your Mercy come upon Muhammad and the family of Muhammad as You let it come upon Ibrahim and the family of Ibrahim. Truly, You are Praiseworthy and Glorious. O Allah, bless Muhammad and the family of Muhammad as You blessed Ibrahim and the family of Ibrahim. Truly, You are Praiseworthy and Glorious.',
              ),
              _buildStepCard(
                context,
                title: 'Step 2: Surah Al-Kafirun (1 time)'.tr,
                instruction: 'Read Surah Al-Kafirun 1 time.'.tr,
                arabicText:
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُلْ يَا أَيُّهَا الْكَافِرُونَ\nلَا أَعْبُدُ مَا تَعْبُدُونَ\nوَلَا أَنْتُمْ عَابِدُونَ مَا أَعْبُدُ\nوَلَا أَنَا عَابِدٌ مَا عَبَدْتُمْ\nوَلَا أَنْتُمْ عَابِدُونَ مَا أَعْبُدُ\nلَكُمْ دِينُكُمْ وَلِيَ دِينِ',
                hindiText:
                    'बिस्मिल्लाहिर्रहमानिर्रहीम\nकुल या अय्युहल काफ़िरून. ला अअबुदु मा ताअबुदून. व ला अतुम आबिदू-न मा अअबुद. व ला अना आबिदुम मा अबत्तूम. व ला अतुम आबिदू-न मा अअबुद. लकुम दी नुकुम वली यदिन्.',
                englishText:
                    'Say, "O disbelievers, I do not worship what you worship. Nor are you worshippers of what I worship. Nor will I be a worshipper of what you worship. Nor will you be worshippers of what I worship. For you is your religion, and for me is my religion."',
              ),
              _buildStepCard(
                context,
                title: 'Step 3: Surah Al-Ikhlas (3 times)'.tr,
                instruction: 'Read Surah Al-Ikhlas (Qul Huwa Allahu Ahad) 3 times.'.tr,
                arabicText:
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُلْ هُوَ اللَّهُ أَحَدٌ\nاللَّهُ الصَّمَدُ\nلَمْ يَلِدْ وَلَمْ يُولَدْ\nوَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
                hindiText:
                    'बिस्मिल्लाहिर्रहमानिर्रहीम\nकुल हु अल्लाहु अहद. अल्ला-हुस समद. लम यलिद वलम यूलद. वलम यकुल्-लहू कुफू-वन अहद.',
                englishText:
                    'Say, "He is Allah, [who is] One, Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent."',
              ),
              _buildStepCard(
                context,
                title: 'Step 4: Surah Al-Falaq (1 time)'.tr,
                instruction: 'Read Surah Al-Falaq 1 time.'.tr,
                arabicText:
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُل| أَعُوذُ بِرَبِّ الْفَلَقِ\nمِنْ شَرِّ مَا خَلَقَ\nوَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ\nوَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ\nوَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
                hindiText:
                    'बिस्मिल्लाहिर्रहमानिर्रहीम\nकुल अ-ऊजु बिरब्बिल फलक. मिन शर-रि मा खलक. व मिन शर-रि गासिकिन इजा वकबा. व मिन शर-रिन नफ्फसाति फिल उकद. व मिन शर-रि हासिदिन इजा हसद.',
                englishText:
                    'Say, "I seek refuge in the Lord of daybreak. From the evil of that which He created. And from the evil of darkness when it settles. And from the evil of the blowers in knots. And from the evil of an envier when he envies."',
              ),
              _buildStepCard(
                context,
                title: 'Step 5: Surah An-Nas (1 time)'.tr,
                instruction: 'Read Surah An-Nas 1 time.'.tr,
                arabicText:
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ\nمَلِكِ النَّاسِ\nإِلَٰهِ النَّاسِ\nمِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ\nالَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ\nمِنَ الْجِنَّةِ وَالنَّاسِ',
                hindiText:
                    'बिस्मिल्लाहिर्रहमानिर्रहीम\nकुल अ-ऊजु बिरब्बिन नासि. मलिकिन नासि. इलाहिन नासि. मिन शर-रिल वसवासिल खन्नास. अल् लजी युवासविसू फी सुदूरिन-नासि. मिनल जिन्नति वन्नासि.',
                englishText:
                    'Say, "I seek refuge in the Lord of mankind, The Sovereign of mankind. The God of mankind, From the evil of the retreating whisperer - Who whispers [evil] into the breasts of mankind - From among the jinn and mankind."',
              ),
              _buildStepCard(
                context,
                title: 'Step 6: Surah Al-Fatiha (1 time)'.tr,
                instruction: 'Read Surah Al-Fatiha (Alhamdulillah) 1 time.'.tr,
                arabicText:
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَٰنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
                hindiText:
                    'बिस्मिल्लाहिर्रहमानिर्रहीम\nअल हम्दु लिल्लाहि रब्बिल आलमीन. अर-रहमानिर-रहीम. मालिकि यौमिद्दीन. इय्याक नाबूदु व इय्याक नस्तईन. इह-दिनस सिरातल मुस्तक़ीम. सिरातल लज़ीना अन अमता अलैहिम. गैरिल मग़ज़ूबि अलैहिम वा लद-दुआल्लिन. (आमीन)',
                englishText:
                    'In the name of Allah, the Entirely Merciful, the Especially Merciful. [All] praise is [due] to Allah, Lord of the worlds - The Entirely Merciful, the Especially Merciful, Sovereign of the Day of Recompense. It is You we worship and You we ask for help. Guide us to the straight path - The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
              ),
              _buildStepCard(
                context,
                title: 'Step 7: Surah Al-Baqarah (Beginning)'.tr,
                instruction: 'Read the first 5 Ayats of Surah Al-Baqarah.'.tr,
                arabicText:
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالم ۝ ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِلْمُتَّقِينَ ۝ الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنْفِقُونَ ۝ وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنْزِلَ إِلَيْكَ وَمَا أُنْزِلَ مِنْ قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ ۝ أُولَٰئِكَ عَلَىٰ هُدًى مِنْ رَبِّهِمْ ۖ وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ',
                hindiText:
                    'बिस्मिल्लाहिर्रहमानिर्रहीम\nअलिफ़ लाम मीम. जालिकल किताबु ला रै-ब फ़ी-ह हुदल लि-ल मुत्तक़ीन. अल् लज़ीना यूअ-मिनूना बिल-गैबि वा युकी मूनस-सलाता वा मिम्मा रज़क़नाहुम युनफ़िक़ून. वल-लज़ीना यूअ-मिनूना बिमा उंज़िला इलैक वा मा उंज़िला मिन कब्लिक वा बिल आखिरति हुम यूकिनून. उलाइ-क अला हुदम मिर-रब्बिहिम वा उलाइ-क हुमुल मुफ़लीहून.',
                englishText:
                    'Alif, Lam, Meem. This is the Book about which there is no doubt, a guidance for those conscious of Allah - Who believe in the unseen, establish prayer, and spend out of what We have provided for them, And who believe in what has been revealed to you, [O Muhammad], and what was revealed before you, and of the Hereafter they are certain. Those are upon [right] guidance from their Lord, and it is those who are the successful.',
              ),
              _buildStepCard(
                context,
                title: 'Step 8: Final Durood and Dua'.tr,
                instruction:
                    'Recite Durood Shareef again 3, 5, 7 or 11 times. Then raise your hands in Dua and ask Allah to accept it and present the reward (Esaal-e-Sawab) to the beloved Prophet (PBUH), his family, companions, all Awliya Allah, and all deceased Muslims.'
                        .tr,
                hindiText:
                    'फिर आख़िर में दरूद शरीफ़ 3, 5, 7 या 11 बार पढ़ें। फिर हाथ उठाकर ईसाल-ए-सवाब की दुआ माँगें।',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String title,
    required String instruction,
    String? arabicText,
    String? hindiText,
    String? englishText,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(Icons.menu_book, color: Theme.of(context).primaryColor),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    instruction,
                    style: TextStyle(fontSize: 15.sp, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 16.h),
                  if (arabicText != null) ...[
                    Text(
                      'Arabi (عربی)'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      arabicText,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 22.sp,
                        height: 1.8,
                        fontFamily: 'Jameel Noori Nastaleeq',
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 16.h),
                    Divider(height: 1.h, color: Colors.grey.withOpacity(0.3)),
                    SizedBox(height: 16.h),
                  ],
                  if (hindiText != null) ...[
                    Text(
                      'Hindi (हिंदी)'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(hindiText, style: TextStyle(fontSize: 16.sp, height: 1.6)),
                    SizedBox(height: 16.h),
                  ],
                  if (englishText != null) ...[
                    Divider(height: 1.h, color: Colors.grey.withOpacity(0.3)),
                    SizedBox(height: 16.h),
                    Text(
                      'English'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(englishText, style: TextStyle(fontSize: 15.sp, height: 1.6)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
