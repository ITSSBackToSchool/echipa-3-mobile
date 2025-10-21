import 'package:flutter/material.dart';

class TrafficInfoPage extends StatelessWidget {
  const TrafficInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traffic Info'),
      ),
      body: const Center(
        child: Text('This is the Traffic Info page.'),
      ),
    );
  }
}
