import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/screens/conference_rooms_page.dart';
import 'package:seat_booking_mobile/screens/my_bookings_page.dart';
import 'package:seat_booking_mobile/screens/office_seats_page.dart';
import 'package:seat_booking_mobile/screens/traffic_info_page.dart';
import 'package:seat_booking_mobile/screens/weather_page.dart';
import 'package:seat_booking_mobile/utils/app_colors.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';

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
        scaffoldBackgroundColor: AppColors.albastruInchis,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Light grey background
      appBar: const CustomAppBar(title: 'Home'),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 32),
            _buildNextVisitCard(context),
          ],
        ),
      ),
    );
  }

  /// Builds the top welcome section with text and an image.
  Widget _buildWelcomeHeader() {
    return Column( // Changed from Row to Column
      crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
      children: [
        const Text(
          'Bine ai revenit, User!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Azi lucrezi / nu lucrezi de la birou',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4B5563),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24), // Added space between text and image
        Image.asset( // This widget is not const
          'assets/images/working_man.png',
          height: 150, // Slightly larger for better visibility
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  /// Builds the card showing details about the next office visit.
  Widget _buildNextVisitCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEAF6), // Light blue background
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Urmatoarea ta vizita la birou:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          _buildVisitDetails(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/my-bookings');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF374151), // Dark button color
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            child: const Text(
              'View Reservations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the inner container with specific visit details.
  Widget _buildVisitDetails() {
    return Container( // FIXED: Removed 'const' from here
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: const Color(0xFF374151), width: 1.5),
      ),
      child: const Column( // This 'const' is fine as its children are const
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biroul 3- Parter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  'Aleea Tibles nr.3',
                  style: TextStyle(color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ),
          Divider(color: Color(0xFF374151), height: 1.5),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '9 Octombrie',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  '9AM-17PM',
                  style: TextStyle(color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
