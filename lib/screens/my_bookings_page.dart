import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/utils/app_colors.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  int _selectedFilterIndex = 0; // 0: Active, 1: Completed, 2: Canceled
  final List<String> _filters = ['Active', 'Completed', 'Canceled'];

  // Mock data for bookings
  final List<Map<String, dynamic>> _allBookings = [
    {
      'id': 1,
      'type': 'seat',
      'title': 'Seat 2',
      'floor': 'Parter',
      'date': '2025-10-19',
      'status': 'Active'
    },
    {
      'id': 2,
      'type': 'room',
      'title': 'Lounge',
      'start': '2025-10-20 10:00',
      'end': '2025-10-20 12:00',
      'status': 'Active',
      'image': 'https://images.pexels.com/photos/271643/pexels-photo-271643.jpeg'
    },
    {
      'id': 3,
      'type': 'seat',
      'title': 'Seat 5',
      'floor': 'Etaj 1',
      'date': '2025-09-15',
      'status': 'Completed'
    },
    {
      'id': 4,
      'type': 'room',
      'title': 'Meeting Room A',
      'start': '2025-09-18 14:00',
      'end': '2025-09-18 15:00',
      'status': 'Completed',
      'image': 'https://images.pexels.com/photos/1181403/pexels-photo-1181403.jpeg'
    },
    {
      'id': 5,
      'type': 'seat',
      'title': 'Seat 12',
      'floor': 'Etaj 2',
      'date': '2025-10-22',
      'status': 'Canceled'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _allBookings
        .where((b) => b['status'] == _filters[_selectedFilterIndex])
        .toList();

    return Scaffold(
      backgroundColor: AppColors.gri,
      appBar: const CustomAppBar(title: 'My bookings'),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          _buildFilterButtons(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                if (booking['type'] == 'seat') {
                  return _buildSeatBookingCard(booking);
                } else {
                  return _buildRoomBookingCard(booking);
                }
              },
            ),
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
                onPressed: () => setState(() => _selectedFilterIndex = index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.albastruInchisClick
                      : AppColors.albastruInchis,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(_filters[index],
                    style: const TextStyle(color: AppColors.gri)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSeatBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.albastruDeschis,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                      Text(booking['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: AppColors.albastruInchis)),
                      const SizedBox(height: 8),
                      Text('Floor: ${booking['floor']}',
                          style: const TextStyle(
                              color: AppColors.albastruInchis, fontSize: 18)),
                      Text('Date: ${booking['date']}',
                          style: const TextStyle(
                              color: AppColors.albastruInchis, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.albastruInchis,
                  child: Icon(Icons.event_seat, color: Colors.white, size: 36),
                ),
              ],
            ),
            if (booking['status'] == 'Active') ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () { /* Handle cancel */ },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.albastruInchis,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoomBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.albastruDeschis,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                      Text(booking['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: AppColors.albastruInchis)),
                      const SizedBox(height: 8),
                      Text('Start: ${booking['start']}',
                          style: const TextStyle(
                              color: AppColors.albastruInchis, fontSize: 18)),
                      Text('End: ${booking['end']}',
                          style: const TextStyle(
                              color: AppColors.albastruInchis, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Image.network(
                    booking['image'],
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.albastruInchis,
                      child:
                          Icon(Icons.image_not_supported, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            if (booking['status'] == 'Active') ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () { /* Handle cancel */ },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.albastruInchis,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
