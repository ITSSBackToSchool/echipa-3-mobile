import 'package:flutter/material.dart';
import 'package:seat_booking_app/widgets/custom_app_bar.dart';
import 'package:seat_booking_app/widgets/custom_drawer.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Weather'),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('This is the Weather page.'),
      ),
    );
  }
}
