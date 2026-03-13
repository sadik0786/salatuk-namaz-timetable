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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: CommonAppBar(title: 'About App'.tr),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor.withOpacity(0.1), theme.scaffoldBackgroundColor],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.r),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 100.w,
                        height: 100.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.mosque, size: 80.w, color: primaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Salatuk',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Version 1.2.5',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Our Mission'.tr),
                  Text(
                    'Salatuk is designed to help Muslims stay connected with their faith by providing accurate prayer times, Qibla direction, and daily spiritual reminders. We strive to combine modern technology with religious mindfulness.'
                        .tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Key Features'.tr),
                  _buildFeatureItem(Icons.access_time_filled, 'Accurate Prayer Times'.tr),
                  _buildFeatureItem(Icons.notifications_active, 'Azan & Jamaat Alerts'.tr),
                  _buildFeatureItem(Icons.explore, 'Qibla Direction'.tr),
                  _buildFeatureItem(Icons.menu_book, 'Duas & Hadiths'.tr),
                  _buildFeatureItem(Icons.fingerprint, 'Digital Tasbih Counter'.tr),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Developer'.tr),
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: primaryColor.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: primaryColor.withOpacity(0.1),
                              child: Icon(Icons.person, color: primaryColor, size: 25.sp),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sadik Ali',
                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        const Divider(),
                        SizedBox(height: 10.h),
                        _buildContactRow(
                          Icons.email_outlined,
                          'alisadik99@gmail.com',
                          () => _launchUrl('mailto:alisadik99@gmail.com'),
                        ),
                        SizedBox(height: 12.h),
                        _buildContactRow(
                          Icons.phone_outlined,
                          '+91 7303224509',
                          () => _launchUrl('tel:+917303224509'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Center(
                    child: Text(
                      'Made with ❤️ for the Ummah'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: Colors.green),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Colors.grey),
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
