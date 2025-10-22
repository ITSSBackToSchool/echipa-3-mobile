import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';

class TrafficInfoPage extends StatelessWidget {
  const TrafficInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Consistent background color with other pages
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const CustomAppBar(title: 'Traffic Page'),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRoutePlanner(context),
            const SizedBox(height: 24),
            _buildTravelStats(),
            const SizedBox(height: 24),
            _buildTrafficAlert(
              title: 'Traffic diverted at Unirii Square',
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildTrafficAlert(
              title: 'Traffic diverted at Unirii Square',
              icon: Icons.alt_route_rounded,
              iconColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  // A helper function to define the consistent box shadow style
  BoxShadow _buildBoxShadow() {
    return BoxShadow(
      color: Colors.black.withOpacity(0.25), // 25%
      offset: const Offset(0, 4),            // X=0, Y=4
      blurRadius: 4,                         // Blur=4
      spreadRadius: 0,
    );
  }

  /// Builds the main card for planning a route.
  Widget _buildRoutePlanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0F8),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // 25%
            offset: const Offset(9, 9),            // X=0, Y=4
            blurRadius: 4,                         // Blur=4
            spreadRadius: 0,                       // Spread=0
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan your route',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(icon: Icons.location_on, label: 'My Location'),
            const SizedBox(height: 12),
            _buildTextField(icon: Icons.watch_later, label: 'Current Hour'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF374151), // Dark blue-grey
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0), // Updated radius
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text('Search', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper for creating styled text fields for the route planner.
  Widget _buildTextField({required IconData icon, required String label}) {
    // This part remains the same, with the shadow on the text field itself
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0), // Updated radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF374151)),
          hintText: label,
          filled: true,
          fillColor: Colors.transparent, // Set to transparent as the Container provides the color
          enabledBorder: OutlineInputBorder( // Border when enabled
            borderRadius: BorderRadius.circular(25.0), // Updated radius
            borderSide: const BorderSide(color: Colors.black, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder( // Border when focused
            borderRadius: BorderRadius.circular(25.0), // Updated radius
            borderSide: const BorderSide(color: Colors.black, width: 1.0),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
        ),
      ),
    );
  }

  /// Builds the card showing travel time and distance.
  Widget _buildTravelStats() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0F8),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [_buildBoxShadow()],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(icon: Icons.directions_car, value: '21 min'),
            _buildStatItem(icon: Icons.bookmark_border, value: '10.1 km'),
          ],
        ),
      ),
    );
  }

  /// Helper for creating an individual stat item (icon and value).
  Widget _buildStatItem({required IconData icon, required String value}) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFF374151)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  /// Builds a card for displaying a traffic alert.
  Widget _buildTrafficAlert({
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0F8),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [_buildBoxShadow()],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 12 min - Reported 5 min ago',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• 1,1 km ahead',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
