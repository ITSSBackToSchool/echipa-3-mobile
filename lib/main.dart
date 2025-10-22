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
    return const Scaffold(
      appBar: CustomAppBar(title: 'Home'),
      drawer: CustomDrawer(),
      body: Center(
        child: Text('This is the Home page.'),
      ),
    );
  }
}
