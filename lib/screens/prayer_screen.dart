import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namaz_timetable/controllers/prayer_controller.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:namaz_timetable/widgets/timetable_grid.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PrayerController controller = Get.find<PrayerController>();

    return Scaffold(
      appBar: CommonAppBar(title: 'Timetable'.tr),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final model = controller.prayerTimes.value;
        if (model == null) {
          return const Center(child: Text("Error loading times"));
        }

        return Column(
          children: [
            Expanded(
              child: TimetableGrid(
                timings: model.timings,
                jamaatTimes: model.jamaatTimes,
                endTimes: model.endTimes,
                nextPrayer: controller.nextPrayer.value,
              ),
            ),
          ],
        );
      }),
    );
  }
}
