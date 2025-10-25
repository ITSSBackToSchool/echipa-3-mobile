import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';

import 'package:seat_booking_mobile/utils/location/location_helper.dart';
import 'package:seat_booking_mobile/utils/services/traffic_api.dart';
import 'package:seat_booking_mobile/utils/parsers/traffic_parsers.dart';

class TrafficInfoPage extends StatefulWidget {
  const TrafficInfoPage({super.key});

  @override
  State<TrafficInfoPage> createState() => _TrafficInfoPageState();
}

class _TrafficInfoPageState extends State<TrafficInfoPage> {
  String? _durationText; // ex: "21 min"
  String? _distanceText; // ex: "10.1 km"
  List<Map<String, dynamic>> _incidents = [];
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const CustomAppBar(title: 'Traffic Page'),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRoutePlanner(context),
            const SizedBox(height: 24),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            _buildTravelStats(),
            const SizedBox(height: 24),

            // Incidents list
            ..._incidents.map((e) => _buildTrafficAlert(
              title: e['description']?.toString() ?? 'Traffic incident',
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orange,
              subtitle: _incidentSubtitle(e),
            )),
          ],
        ),
      ),
    );
  }

  String _incidentSubtitle(Map<String, dynamic> e) {
    final sev = e['severity']?.toString() ?? '';
    final delay = e['delay'];
    final road = e['road']?.toString() ?? '';
    final delayTxt = (delay is num) ? ' • delay ~ ${delay.toInt()}s' : '';
    final roadTxt = road.isNotEmpty ? ' • $road' : '';
    return 'Severity: $sev$delayTxt$roadTxt';
  }

  BoxShadow _buildBoxShadow() {
    return BoxShadow(
      color: Colors.black.withOpacity(0.25),
      offset: const Offset(9, 9),
      blurRadius: 4,
      spreadRadius: 0,
    );
  }

  Widget _buildRoutePlanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0F8),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [_buildBoxShadow()],
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

            // câmpurile rămân decorative pentru moment
            _buildTextField(icon: Icons.location_on, label: 'My Location (auto)'),
            const SizedBox(height: 12),
            _buildTextField(icon: Icons.watch_later, label: 'Current Hour'),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF374151),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
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

  Future<void> _onSearch() async {
    setState(() {
      _loading = true;
      _error = null;
      _incidents = [];
      _durationText = null;
      _distanceText = null;
    });

    try {
      // 1) Locația curentă (lat,lon)
      //final pos = await LocationHelper.getCurrentPosition();
      //final start = '${pos.latitude},${pos.longitude}';
      final start = '44.4325,26.1039';
      // 2) Directions: traffic=true, travelMode=car
      final dirJson = await TrafficApi.getDirections(
        start: start,
        traffic: true,
        travelMode: 'car',
      );
      final summary = TrafficParsers.parseRouteSummary(dirJson);

      final secs = summary.secs ?? 0;
      final meters = summary.meters ?? 0;
      // format
      _durationText = _formatMinutes(secs);
      _distanceText = _formatKm(meters);

      // 3) Incidente (backend-ul tău cere startBbox=lat,lon)
      final incJson = await TrafficApi.getIncidents(startBbox: start);
      _incidents = TrafficParsers.parseIncidents(incJson);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _formatMinutes(int secs) {
    final m = (secs / 60).round();
    return '$m min';
    // dacă vrei HH:MM, schimbă logica aici.
  }

  String _formatKm(int meters) {
    final km = (meters / 1000.0);
    return '${km.toStringAsFixed(km >= 10 ? 0 : 1)} km';
  }

  Widget _buildTextField({required IconData icon, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        readOnly: true, // locația e auto; poți permite editare dacă vrei
        style: const TextStyle(color: Color(0xFF4B5563)),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF374151)),
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xFF4B5563)),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: Colors.black, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: Colors.black, width: 1.0),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
        ),
      ),
    );
  }

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
            _buildStatItem(icon: Icons.directions_car, value: _durationText ?? '--'),
            _buildStatItem(icon: Icons.bookmark_border, value: _distanceText ?? '--'),
          ],
        ),
      ),
    );
  }

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

  Widget _buildTrafficAlert({
    required String title,
    required IconData icon,
    required Color iconColor,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(subtitle, style: TextStyle(color: Colors.grey[700])),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
