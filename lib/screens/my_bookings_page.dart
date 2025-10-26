import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:seat_booking_mobile/utils/app_colors.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';

// Model
class Booking {
  final int id;
  final String status;
  final String? seatNumber;
  final String? roomName;
  final String? floorName;
  final String reservationDateStart;
  final String reservationDateEnd;

  Booking(
      {required this.id,
      required this.status,
      this.seatNumber,
      this.roomName,
      this.floorName,
      required this.reservationDateStart,
      required this.reservationDateEnd});

  bool get isSeatBooking => seatNumber != null;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      status: json['status'],
      seatNumber: json['seatNumber'],
      roomName: json['roomName'],
      floorName: json['floorName'],
      reservationDateStart: json['reservationDateStart'],
      reservationDateEnd: json['reservationDateEnd'],
    );
  }
}

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  int _selectedFilterIndex = 0; // 0: ACTIVE, 1: COMPLETED, 2: CANCELLED
  final List<String> _filters = ['ACTIVE', 'COMPLETED', 'CANCELLED'];

  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final int userId = 1;
    final status = _filters[_selectedFilterIndex];
    final url =
        Uri.parse('http://10.0.2.2:8090/reservations/user?userId=$userId&status=$status');

    try {
      final apiCall = http.get(url);
      final delay = Future.delayed(const Duration(milliseconds: 400));
      final responses = await Future.wait([apiCall, delay]);
      final response = responses[0] as http.Response;

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            _bookings = data.map((json) => Booking.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          throw Exception('Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelReservation(int reservationId) async {
    final url = Uri.parse('http://10.0.2.2:8090/reservations/$reservationId');

    try {
      final response = await http.put(url);

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.verde,
              content: Text('Booking cancelled successfully!'),
            ),
          );
          _fetchBookings();
        } else {
          throw Exception('Failed to cancel booking: ${response.body}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.rosu,
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _showCancelConfirmationDialog(int reservationId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to cancel this booking?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelReservation(reservationId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gri,
      appBar: const CustomAppBar(title: 'My bookings'),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          _buildFilterButtons(),
          Expanded(
            child: _buildBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _selectedFilterIndex = index);
                  _fetchBookings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.albastruInchisClick
                      : AppColors.albastruInchis,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                    _filters[index].substring(0, 1) +
                        _filters[index].substring(1).toLowerCase(),
                    style: const TextStyle(color: AppColors.gri)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBookingsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: CircularProgressIndicator(
            color: AppColors.albastruInchis,
          ),
        ),
      );
    } else if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('An error occurred: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.rosu)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchBookings,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gri),
                child: const Text('Retry',
                    style: TextStyle(color: AppColors.albastruInchis)),
              ),
            ],
          ),
        ),
      );
    } else if (_bookings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No bookings found for this status.',
            style: TextStyle(color: AppColors.gri),
          ),
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          if (booking.isSeatBooking) {
            return _buildSeatBookingCard(booking);
          } else {
            return _buildRoomBookingCard(booking);
          }
        },
      );
    }
  }

  Widget _buildCancelButton({required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(25),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              AppColors.appBarGradientStart,
              AppColors.appBarGradientEnd,
            ]),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 64),
            child: const Text(
              'Cancel',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatBookingCard(Booking booking) {
    final date = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(booking.reservationDateStart));
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.albastruDeschis,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.seatNumber ?? 'N/A',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: AppColors.albastruInchis)),
                      const SizedBox(height: 8),
                      Text('Floor: ${booking.floorName ?? 'N/A'}',
                          style: const TextStyle(
                              color: AppColors.albastruInchis, fontSize: 18)),
                      Text('Date: $date',
                          style: const TextStyle(
                              color: AppColors.albastruInchis, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.appBarGradientStart,
                        AppColors.appBarGradientEnd,
                      ],
                    ),
                  ),
                  child: const Icon(Icons.event_seat, color: Colors.white, size: 48),
                ),
              ],
            ),
            if (booking.status == 'ACTIVE') ...[
              const SizedBox(height: 24),
              _buildCancelButton(
                  onPressed: () => _showCancelConfirmationDialog(booking.id)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoomBookingCard(Booking booking) {
    final startDateTime = DateTime.parse(booking.reservationDateStart);
    final endDateTime = DateTime.parse(booking.reservationDateEnd);

    final day = DateFormat('yyyy-MM-dd').format(startDateTime);
    final startHour = DateFormat.jm().format(startDateTime);
    final endHour = DateFormat.jm().format(endDateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.albastruDeschis,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.roomName ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: AppColors.albastruInchis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: $day',
                        style: const TextStyle(
                            color: AppColors.albastruInchis, fontSize: 18),
                      ),
                      Text('Start: $startHour',
                          style: const TextStyle(
                              color: AppColors.albastruInchis, fontSize: 18)),
                      Text('End: $endHour',
                          style: const TextStyle(
                              color: AppColors.albastruInchis, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Image.network(
                    "https://images.pexels.com/photos/159213/hall-congress-architecture-building-159213.jpeg", // Placeholder
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppColors.albastruInchis,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.image_not_supported, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            if (booking.status == 'ACTIVE') ...[
              const SizedBox(height: 24),
              _buildCancelButton( onPressed: () => _showCancelConfirmationDialog(booking.id)),
            ],
          ],
        ),
      ),
    );
  }

}
