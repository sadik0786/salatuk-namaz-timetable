import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    debugPrint('Could not launch $url');
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'About App'.tr),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 100.w,
                height: 100.w,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.mosque, size: 100.w, color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: Text(
                'Salatuk',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ),
            SizedBox(height: 32.h),
            Text('Prayer Times & Qibla Direction app.'.tr, style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 32.h),
            Text(
              'Developer Details'.tr,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Card(
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('Name'.tr),
                    subtitle: const Text('Sadik Ali'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text('Email'.tr),
                    subtitle: const Text('alisadik99@gmail.com'),
                    onTap: () => _launchUrl('mailto:alisadik99@gmail.com'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text('Phone'.tr),
                    subtitle: const Text('+91 7303224509'),
                    onTap: () => _launchUrl('tel:+917303224509'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
