import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Light grey background
      appBar: const CustomAppBar(title: 'Weather Page'),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Weather Section
            _buildCurrentWeather(),

            // Daily Forecast Section
            _buildDailyForecast(),
            const SizedBox(height: 24),

            // Weather Details Grid Section
            _buildWeatherDetailsGrid(),
          ],
        ),
      ),
    );
  }

  // Builds the top section showing current weather
  Widget _buildCurrentWeather() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row( // <-- REMOVED const HERE
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bucharest, Romania',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B5563),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Sunny',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4B5563),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '21° C',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4B5563),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'H:23°C   L:18°C',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
          Icon( // This is not constant
            WeatherIcons.day_sunny,
            size: 80,
            color: Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  // Builds the list of daily forecast items
  Widget _buildDailyForecast() {
    // Dummy data for the forecast list
    final List<Map<String, dynamic>> dailyData = List.generate(
      7,
          (index) => {
        'day': 'Monday',
        'temp': 11,
        'icon': WeatherIcons.day_sunny,
      },
    );

    return Column(
      children: dailyData.map((data) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE), // Light blue background
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25), // 25%
                  offset: const Offset(0, 4),            // X=0, Y=4
                  blurRadius: 4,                         // Blur=4
                  spreadRadius: 0,                       // Spread=0
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${data['day']}: ${data['temp']}°',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF4B5563),
                  ),
                ),
                Icon(
                  data['icon'],
                  color: const Color(0xFFF59E0B),
                  size: 24,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Builds the grid with weather details like precipitation, wind, etc.
  Widget _buildWeatherDetailsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5, // Adjust this ratio for item height
      children: [
        _buildDetailItem(
          title: 'Precipitations',
          value: '25%',
          icon: WeatherIcons.rain,
        ),
        _buildDetailItem(
          title: 'Wind',
          value: '10km/h',
          icon: WeatherIcons.strong_wind,
        ),
        _buildDetailItem(
          title: 'Humidity',
          value: '25%',
          icon: WeatherIcons.humidity,
        ),
        _buildDetailItem(
          title: 'Pressure',
          value: '1000hPa',
          icon: WeatherIcons.barometer,
        ),
      ],
    );
  }

  // Helper widget for creating a single item in the details grid
  Widget _buildDetailItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // 25%
            offset: const Offset(0, 4),            // X=0, Y=4
            blurRadius: 4,                         // Blur=4
            spreadRadius: 0,                       // Spread=0
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF4B5563)
                ),
              ),
              Icon(icon, color: const Color(0xFF4B5563), size: 32), // UPDATED ICON COLOR
            ],
          ),
        ],
      ),
    );
  }
}
