import 'package:flutter/material.dart';
import 'package:seat_booking_app/screens/conference_rooms_page.dart';
import 'package:seat_booking_app/screens/my_bookings_page.dart';
import 'package:seat_booking_app/screens/office_seats_page.dart';
import 'package:seat_booking_app/screens/traffic_info_page.dart';
import 'package:seat_booking_app/screens/weather_page.dart';
import 'package:seat_booking_app/widgets/custom_app_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF232D3F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/office-seats': (context) => const OfficeSeatsPage(),
        '/conference-rooms': (context) => const ConferenceRoomsPage(),
        '/my-bookings': (context) => const MyBookingsPage(),
        '/weather': (context) => const WeatherPage(),
        '/traffic-info': (context) => const TrafficInfoPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isBookNowExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home'),
      drawer: Drawer(
        backgroundColor: const Color(0xFF374151),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Book\nYour\nSeat',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildExpansionTile(),
                  const SizedBox(height: 10),
                  _buildDrawerButton('My Bookings', '/my-bookings'),
                  const SizedBox(height: 10),
                  _buildDrawerButton('Weather', '/weather'),
                  const SizedBox(height: 10),
                  _buildDrawerButton('Traffic Info', '/traffic-info'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        CircleAvatar(radius: 25, backgroundColor: Colors.grey),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cosmin Gheorghe', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            Text('cosmin@example.com', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            Text('View profile', style: TextStyle(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Logout', style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(color: Colors.white38), // Empty body for now
    );
  }

  Widget _buildExpansionTile() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: const Text('Book now', style: TextStyle(color: Colors.black)),
            trailing: Icon(_isBookNowExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black),
            onTap: () => setState(() => _isBookNowExpanded = !_isBookNowExpanded),
          ),
          if (_isBookNowExpanded)
            Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 32.0),
                  title: const Text('Office Seats', style: TextStyle(color: Colors.black87)),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.pushNamed(context, '/office-seats');
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 32.0),
                  title: const Text('Conference Rooms', style: TextStyle(color: Colors.black87)),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.pushNamed(context, '/conference-rooms');
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(String title, String routeName) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }
}
