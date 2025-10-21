import 'package:flutter/material.dart';

class ConferenceRoomsPage extends StatelessWidget {
  const ConferenceRoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conference Rooms'),
      ),
      body: const Center(
        child: Text('This is the Conference Rooms page.'),
      ),
    );
  }
}
