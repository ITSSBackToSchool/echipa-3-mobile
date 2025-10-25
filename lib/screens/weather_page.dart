// lib/screens/weather_page.dart
import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';
import 'package:weather_icons/weather_icons.dart';

import 'package:seat_booking_mobile/utils/services/weather_api.dart';
import 'package:seat_booking_mobile/utils/models/weather_response.dart';
import 'package:seat_booking_mobile/utils/mappers/weather_code_mapper.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final api = WeatherApi(lat: 44.43, lon: 26.1063); // București

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const CustomAppBar(title: 'Weather Page'),
      drawer: const CustomDrawer(),
      body: FutureBuilder<WeatherResponse>(
        future: api.fetch(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Eroare: ${snap.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          final data = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentWeather(data),
                const SizedBox(height: 16),
                _buildDailyForecast(data),
                const SizedBox(height: 24),
                _buildWeatherDetailsGrid(data),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========== UI builders ==========

  Widget _buildCurrentWeather(WeatherResponse w) {
    final c = w.current;
    final icon = iconForCode(c.weatherCode, isDay: true);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bucharest, Romania',
                style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _labelForCode(c.weatherCode),
                style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 8),
              Text(
                '${c.temperature2m.toStringAsFixed(0)}° C',
                style: const TextStyle(
                  fontSize: 64, fontWeight: FontWeight.w400, color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                // High/Low din prima zi daily
                'H:${w.daily.temperature2mMax.first.toStringAsFixed(0)}°C   '
                    'L:${w.daily.temperature2mMin.first.toStringAsFixed(0)}°C',
                style: const TextStyle(fontSize: 20, color: Color(0xFF4B5563)),
              ),
            ],
          ),
          Icon(icon, size: 80, color: const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildDailyForecast(WeatherResponse w) {
    final days = w.daily.time.length;

    return Column(
      children: List.generate(days, (i) {
        final date = DateTime.parse(w.daily.time[i]);
        final dayName = _weekdayRo(date.weekday);
        final temp = w.daily.temperature2mMax[i].toStringAsFixed(0);
        final code = w.daily.weatherCode[i];
        final icon = iconForCode(code, isDay: true);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$dayName: $temp°',
                  style: const TextStyle(fontSize: 20, color: Color(0xFF4B5563)),
                ),
                Icon(icon, color: const Color(0xFFF59E0B), size: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWeatherDetailsGrid(WeatherResponse w) {
    final c = w.current;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildDetailItem(title: 'Precipitations', value: '${c.precipitation.toStringAsFixed(1)} mm', icon: WeatherIcons.rain),
        _buildDetailItem(title: 'Wind', value: '${c.windSpeed10m.toStringAsFixed(0)} km/h', icon: WeatherIcons.strong_wind),
        _buildDetailItem(title: 'Humidity', value: '${c.relativeHumidity2m}%', icon: WeatherIcons.humidity),
        _buildDetailItem(title: 'Pressure', value: '${c.surfacePressure.toStringAsFixed(0)} hPa', icon: WeatherIcons.barometer),
      ],
    );
  }

  Widget _buildDetailItem({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, color: Color(0xFF4B5563))),
              Icon(icon, color: const Color(0xFF4B5563), size: 32),
            ],
          ),
        ],
      ),
    );
  }

  // ========== helpers ==========

  String _weekdayRo(int weekday) {
    const names = ['Luni','Marți','Miercuri','Joi','Vineri','Sâmbătă','Duminică'];
    return names[(weekday - 1) % 7];
  }

  String _labelForCode(int code) {
    if (code == 0) return 'Senin';
    if (code == 1 || code == 2 || code == 3) return 'Înnorat';
    if (code == 45 || code == 48) return 'Ceață';
    if (code >= 51 && code <= 57) return 'Burniță';
    if (code >= 61 && code <= 67) return 'Ploaie';
    if (code >= 71 && code <= 77) return 'Ninsoare';
    if (code >= 80 && code <= 82) return 'Averse';
    if (code == 85 || code == 86) return 'Averse de ninsoare';
    if (code == 95) return 'Furtună';
    if (code == 96 || code == 99) return 'Furtună cu grindină';
    return 'N/A';
  }
}
