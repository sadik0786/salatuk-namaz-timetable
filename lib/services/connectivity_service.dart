import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_settings/app_settings.dart';
import 'package:namaz_timetable/controllers/prayer_controller.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  bool _isShown = false;
  bool _canShow = false;

  @override
  void onInit() {
    super.onInit();
    // Enable showing only after 4 seconds (Splash finishes in 3s)
    Future.delayed(const Duration(seconds: 4), () {
      _canShow = true;
      checkInitialStatus(); // Initial check after becoming ready
      _connectivity.onConnectivityChanged.listen((results) {
        _updateConnectionStatus(results);
      });
    });
  }

  Future<void> checkInitialStatus() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (!_canShow) return; // Ignore everything during splash transition

    bool isConnected = results.any((result) => result != ConnectivityResult.none);

    if (!isConnected) {
      if (!_isShown) {
        _showNoInternetBottomSheet();
      }
    } else {
      // Internet is ON
      if (_isShown) {
        // Only close if it's actually open
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        _isShown = false;
      }

      // Automatically refresh data if it's missing (anytime internet returns)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.isRegistered<PrayerController>()) {
          final prayerController = Get.find<PrayerController>();
          if (prayerController.prayerTimes.value == null || prayerController.isLoading.value) {
            prayerController.refreshPrayerTimes();
          }
        }
      });
    }
  }

  void _showNoInternetBottomSheet() {
    _isShown = true;
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? const Color(0xFF121212) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[400]?.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 25.h),
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.wifi_off_rounded, size: 50.sp, color: Colors.redAccent),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Connection Lost",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Get.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "It looks like you're offline.\nPlease check your internet connection to continue using Salatuk.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 25.h),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => checkInitialStatus(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                    ),
                    child: Text(
                      "Try Reconnecting",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                TextButton(
                  onPressed: () {
                    // This will open the mobile's wireless/connectivity settings
                    AppSettings.openAppSettings(type: AppSettingsType.wireless);
                  },
                  child: Text(
                    "Check your settings",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: false,
      enableDrag: false,
      persistent: true,
      backgroundColor: Colors.transparent,
    ).then((_) {
      _isShown = false;
    });
  }
}
