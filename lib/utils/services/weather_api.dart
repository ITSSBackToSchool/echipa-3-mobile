// lib/utils/services/weather_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:seat_booking_mobile/utils/models/weather_response.dart';

class WeatherApi {
  final double lat;
  final double lon;

  WeatherApi({required this.lat, required this.lon});

  Future<WeatherResponse> fetch() async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=$lat&longitude=$lon'
          '&current=temperature_2m,wind_speed_10m,wind_direction_10m,weather_code,precipitation,relative_humidity_2m,surface_pressure'
          '&daily=weather_code,temperature_2m_max,temperature_2m_min'
          '&timezone=auto',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Open-Meteo error: ${res.statusCode} ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return WeatherResponse.fromJson(json);
  }
}
