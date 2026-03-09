import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<double?> getTemperature(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['current_weather']['temperature'] as num).toDouble();
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
    }
    return null;
  }
}
