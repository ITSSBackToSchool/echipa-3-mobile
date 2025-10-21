import 'package:flutter/material.dart';
import 'package:seat_booking_app/widgets/custom_app_bar.dart';
import 'package:seat_booking_app/widgets/custom_drawer.dart';

class OfficeSeatsPage extends StatelessWidget {
  const OfficeSeatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Office Seats'),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('This is the Office Seats page.'),
      ),
    );
  }
}
