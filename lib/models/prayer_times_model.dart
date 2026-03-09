class PrayerTimesModel {
  final Map<String, String> timings;
  final Map<String, String> jamaatTimes;
  final Map<String, String> endTimes;
  final String hijri;

  PrayerTimesModel({
    required this.timings,
    required this.jamaatTimes,
    required this.endTimes,
    required this.hijri,
  });

  factory PrayerTimesModel.fromMap(Map<String, dynamic> map) {
    return PrayerTimesModel(
      timings: Map<String, String>.from(map['timings'] ?? {}),
      jamaatTimes: Map<String, String>.from(map['jamaatTimes'] ?? {}),
      endTimes: Map<String, String>.from(map['endTimes'] ?? {}),
      hijri: map['hijri'] ?? '',
    );
  }
}
