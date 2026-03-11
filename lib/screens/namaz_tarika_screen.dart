import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';

class NamazTarikaScreen extends StatelessWidget {
  const NamazTarikaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Namaz Tarika'.tr),
      body: ValueListenableBuilder<String>(
        valueListenable: SettingsService.languageNotifier,
        builder: (context, lang, _) {
          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _buildNamazCard(
                context,
                'Fajr'.tr,
                '2 Rakats Sunnah (Muakkadah)\n2 Rakats Fard\nTotal: 4 Rakats'.tr,
                'نیت کرتا/کرتی ہوں میں ۲ رکعت فرض نماز فجر کی، واسطے اللہ تعالیٰ کے، منہ میرا طرف کعبہ شریف کے، اللہ اکبر۔',
                'नीयत करता/करती हूँ मैं 2 रकात फ़र्ज़ नमाज़ फ़ज्र की, वास्ते अल्लाह तआला के, मुँह मेरा काबा शरीफ़ की तरफ़, अल्लाहु अकबर।',
              ),
              _buildNamazCard(
                context,
                'Dhuhr'.tr,
                '4 Rakats Sunnah (Muakkadah)\n4 Rakats Fard\n2 Rakats Sunnah (Muakkadah)\n2 Rakats Nafl\nTotal: 12 Rakats'
                    .tr,
                'نیت کرتا/کرتی ہوں میں ۴ رکعت فرض نماز ظہر کی، واسطے اللہ تعالیٰ کے، منہ میرا طرف کعبہ شریف کے، اللہ اکبر۔',
                'नीयत करता/करती हूँ मैं 4 रकात फ़र्ज़ नमाज़ ज़ुहर की, वास्ते अल्लाह तआला के, मुँह मेरा काबा शरीफ़ की तरफ़, अल्लाहु अकबर।',
              ),
              _buildNamazCard(
                context,
                'Asr'.tr,
                '4 Rakats Sunnah (Ghair Muakkadah)\n4 Rakats Fard\nTotal: 8 Rakats'.tr,
                'نیت کرتا/کرتی ہوں میں ۴ رکعت فرض نماز عصر کی، واسطے اللہ تعالیٰ کے، منہ میرا طرف کعبہ شریف کے، اللہ اکبر۔',
                'नीयत करता/करती हूँ मैं 4 रकात फ़र्ज़ नमाज़ असर की, वास्ते अल्लाह तआला के, मुँह मेरा काबा शरीफ़ की तरफ़, अल्लाहु अकबर।',
              ),
              _buildNamazCard(
                context,
                'Maghrib'.tr,
                '3 Rakats Fard\n2 Rakats Sunnah (Muakkadah)\n2 Rakats Nafl\nTotal: 7 Rakats'.tr,
                'نیت کرتا/کرتی ہوں میں ۳ رکعت فرض نماز مغرب کی، واسطے اللہ تعالیٰ کے، منہ میرا طرف کعبہ شریف کے، اللہ اکبر۔',
                'नीयत करता/करती हूँ मैं 3 रकात फ़र्ज़ नमाज़ मग़रिब की, वास्ते अल्लाह तआला के, मुँह मेरा काबा शरीफ़ की तरफ़, अल्लाहु अकबर।',
              ),
              _buildNamazCard(
                context,
                'Isha'.tr,
                '4 Rakats Sunnah (Ghair Muakkadah)\n4 Rakats Fard\n2 Rakats Sunnah (Muakkadah)\n2 Rakats Nafl\n3 Rakats Witr\n2 Rakats Nafl\nTotal: 17 Rakats'
                    .tr,
                'نیت کرتا/کرتی ہوں میں ۴ رکعت فرض نماز عشاء کی، واسطے اللہ تعالیٰ کے، منہ میرا طرف کعبہ شریف کے، اللہ اکبر۔\n\nنیت (وتر): نیت کرتا/کرتی ہوں میں ۳ رکعت واجب وتر عشاء کی، واسطے اللہ تعالیٰ کے، منہ میرا طرف کعبہ شریف کے، اللہ اکبر۔',
                'फ़र्ज़ नीयत: नीयत करता/करती हूँ मैं 4 रकात फ़र्ज़ नमाज़ ईशा की, वास्ते अल्लाह तआला के, मुँह मेरा काबा शरीफ़ की तरफ़, अल्लाहु अकबर।\n\nवित्र नीयत: नीयत करता/करती हूँ मैं 3 रकात वाजिब वित्र ईशा की, वास्ते अल्लाह तआला के, मुँह मेरा काबा शरीफ़ की तरफ़, अल्लाहु अकबर।',
              ),
              _buildNamazCard(
                context,
                'Jummah'.tr,
                '4 Rakats Sunnah (Muakkadah)\n2 Rakats Fard\n4 Rakats Sunnah (Muakkadah)\n2 Rakats Sunnah (Muakkadah)\n2 Rakats Nafl\nTotal: 14 Rakats'
                    .tr,
                'نیت کرتا/کرتی ہوں میں ۲ رکعت فرض نماز جمعہ کی، پیچھے اس امام کے، واسطے اللہ تعالیٰ کے، منہ میرا طرف کعبہ شریف کے، اللہ اکبر۔',
                'नीयत करता/करती हूँ मैं 2 रकात फ़र्ज़ नमाज़ जुम्मा की, पीछे इस इमाम के, वास्ते अल्लाह तआला के, मुँह मेरा काबा शरीफ़ की तरफ़, अल्लाहु अकबर।',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNamazCard(
    BuildContext context,
    String name,
    String details,
    String urduNiyyat,
    String hindiNiyyat,
  ) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ExpansionTile(
        title: Text(
          name,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        leading: Icon(Icons.book_outlined, color: Theme.of(context).primaryColor),
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rakats Details:'.tr,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(details, style: TextStyle(fontSize: 16.sp, height: 1.5)),
                SizedBox(height: 16.h),
                // Urdu Language Segment
                Text(
                  'Urdu Niyyat (نیت):'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 4.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    urduNiyyat,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 18.sp,
                      height: 1.5,
                      fontFamily: 'Jameel Noori Nastaleeq',
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Hindi Language Segment
                Text(
                  'Hindi Niyyat (नीयत):'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(hindiNiyyat, style: TextStyle(fontSize: 16.sp, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
