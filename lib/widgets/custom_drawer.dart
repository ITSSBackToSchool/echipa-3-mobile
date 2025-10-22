import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/utils/app_colors.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isBookNowExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.albastruInchis,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
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
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Book\nYour\nSeat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
