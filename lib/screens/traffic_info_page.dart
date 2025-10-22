import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';

class TrafficInfoPage extends StatelessWidget {
  const TrafficInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Traffic Info'),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('This is the Traffic Info page.'),
      ),
    );
  }
}
