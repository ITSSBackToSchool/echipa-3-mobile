import 'package:flutter/material.dart';

class OfficeSeatsPage extends StatelessWidget {
  const OfficeSeatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Seats'),
      ),
      body: const Center(
        child: Text('This is the Office Seats page.'),
      ),
    );
  }
}
