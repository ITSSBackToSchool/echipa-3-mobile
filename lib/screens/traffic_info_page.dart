// lib/screens/traffic_info_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';

// serviciile/utilitarele pe care le-ai creat deja
import 'package:seat_booking_mobile/utils/services/traffic_api.dart';
import 'package:seat_booking_mobile/utils/parsers/traffic_parsers.dart';
import 'package:seat_booking_mobile/utils/location/location_helper.dart';

class TrafficInfoPage extends StatefulWidget {
  const TrafficInfoPage({super.key});

  @override
  State<TrafficInfoPage> createState() => _TrafficInfoPageState();
}

class _TrafficInfoPageState extends State<TrafficInfoPage> {
  // controllers pentru câmpurile din card
  final TextEditingController _locCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController();

  // statistici rute
  String? _durationText; // ex: "16 min"
  String? _distanceText; // ex: "6.2 km"

  // incidente
  List<Map<String, dynamic>> _incidents = [];

  // stare UI
  bool _loading = false;
  String? _error;

  // ultima poziție pentru calculul "km ahead"
  Position? _lastPos;

  @override
  void initState() {
    super.initState();
    _timeCtrl.text = _formatNow();
    _locCtrl.text = 'My Location (auto)';
  }

  @override
  void dispose() {
    _locCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

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
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 8),
            _buildTravelStats(),
            const SizedBox(height: 24),

            // Lista de incidente
            ..._incidents.map((inc) {
              final String type = (inc['type'] ?? 'Incident').toString();
              final icon = _incidentIcon(type);
              final color = _incidentColor(type);
              final line1 = _incidentLine1(type, inc['startTime'] as String?);
              final line2 = _incidentLine2(inc['lat'] as double?, inc['lon'] as double?);
              final sev = inc['severity'] as int?;
              return _buildTrafficAlert(
                title: inc['title']?.toString() ?? 'Traffic incident',
                icon: icon,
                iconColor: color,
                line1: line1,
                line2: line2,
                severity: sev,
              );
            }),
          ],
        ),
      ),
    );
  }

  // ================== ACTIONS ==================

  Future<void> _onSearch() async {
    setState(() {
      _loading = true;
      _error = null;
      _incidents = [];
      _durationText = null;
      _distanceText = null;
    });

    try {
      // 1) Locație curentă (cu fallback dacă emulatorul dă Googleplex)
      var pos = await LocationHelper.getCurrentPosition();
      var lat = pos.latitude;
      var lon = pos.longitude;

      // fallback pentru emulatorul Android (Google HQ)
      bool _isNear(double a, double b, double eps) => (a - b).abs() < eps;
      if (_isNear(lat, 37.4219983, 0.0008) && _isNear(lon, -122.084, 0.0008)) {
        lat = 44.4325;
        lon = 26.1039;
      }

      final start = '$lat,$lon';
      _lastPos = Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: pos.accuracy,
        altitude: pos.altitude,
        heading: pos.heading,
        speed: pos.speed,
        speedAccuracy: pos.speedAccuracy,
        altitudeAccuracy: pos.altitudeAccuracy,
        headingAccuracy: pos.headingAccuracy,
      );

      _locCtrl.text = start;
      _timeCtrl.text = _formatNow();

      // 2) Directions (traffic=true, car)
      final dirJson = await TrafficApi.getDirections(
        start: start,
        traffic: true,
        travelMode: 'car',
      );
      final s = TrafficParsers.parseRouteSummary(dirJson);
      _durationText = _formatMinutes(s.secs ?? 0);
      _distanceText = _formatKm(s.meters ?? 0);

      // 3) Incidents (GeoJSON) + filtrare ultimele 2 ore
      final incJson = await TrafficApi.getIncidents(startBbox: start);
      var incs = TrafficParsers.parseIncidents(incJson);
      incs = _filterRecentIncidents(incs); // ✅ păstrează doar ultimele 2 ore
      _incidents = incs;

      setState(() {});
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================== UI WIDGETS ==================

  Widget _buildRoutePlanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
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
            _buildTextField(icon: Icons.location_on, label: 'My Location (auto)', controller: _locCtrl),
            const SizedBox(height: 12),
            _buildTextField(icon: Icons.watch_later, label: 'Current Hour', controller: _timeCtrl),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF374151),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
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

  Widget _buildTravelStats() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
        ),
      ],
    );
  }

  Widget _buildTrafficAlert({
    required String title,
    required IconData icon,
    required Color iconColor,
    String? line1,
    String? line2,
    int? severity,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
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
                  Text(title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      )),
                  const SizedBox(height: 8),
                  if (line1 != null) Text(line1, style: TextStyle(color: Colors.grey[700])),
                  if (line2 != null) ...[
                    const SizedBox(height: 4),
                    Text(line2, style: TextStyle(color: Colors.grey[700])),
                  ],
                  if (severity != null) ...[
                    const SizedBox(height: 4),
                    Text('Severity: $severity', style: TextStyle(color: Colors.grey[700])),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    TextEditingController? controller,
  }) {
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
        controller: controller,
        readOnly: true,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
        ),
      ),
    );
  }

  // ================== HELPERS ==================

  BoxShadow _buildBoxShadow() => BoxShadow(
    color: Colors.black.withOpacity(0.25),
    offset: const Offset(0, 4),
    blurRadius: 4,
    spreadRadius: 0,
  );

  String _formatNow() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatMinutes(int secs) => '${(secs / 60).round()} min';

  String _formatKm(int meters) {
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(km >= 10 ? 0 : 1)} km';
  }

  IconData _incidentIcon(String type) {
    switch (type) {
      case 'Congestion':
        return Icons.warning_amber_rounded; // 🟠
      case 'Construction':
        return Icons.construction_rounded; // 🟠 (aceeași culoare prin _incidentColor)
      default:
        return Icons.report_problem_rounded;
    }
  }

  // ✅ aceeași culoare pentru Congestion și Construction (orange)
  Color _incidentColor(String type) {
    switch (type) {
      case 'Congestion':
      case 'Construction':
        return Colors.orange;
      default:
        return const Color(0xFF374151);
    }
  }

  String _incidentLine1(String type, String? startIso) {
    final label = (type == 'Congestion')
        ? 'Congestion'
        : (type == 'Construction')
        ? 'Roadworks'
        : type;

    int? mins;
    if (startIso != null) {
      try {
        final t = DateTime.parse(startIso).toUtc();
        mins = DateTime.now().toUtc().difference(t).inMinutes;
      } catch (_) {}
    }
    final reported = (mins != null && mins >= 0) ? ' - Reported $mins min ago' : '';
    return '• $label$reported';
  }

  String _incidentLine2(double? lat, double? lon) {
    if (_lastPos == null || lat == null || lon == null) return '•';
    final km = _distanceKm(_lastPos!.latitude, _lastPos!.longitude, lat, lon);
    return '• ${km.toStringAsFixed(km >= 10 ? 0 : 1)} km ahead';
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    double d2r(double d) => d * math.pi / 180.0;
    final dLat = d2r(lat2 - lat1);
    final dLon = d2r(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(d2r(lat1)) * math.cos(d2r(lat2)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  /// ✅ păstrează doar incidentele din ultimele 2 ore
  List<Map<String, dynamic>> _filterRecentIncidents(List<Map<String, dynamic>> xs) {
    final now = DateTime.now().toUtc();
    return xs.where((e) {
      final s = e['startTime'];
      if (s is! String) return false;
      try {
        final t = DateTime.parse(s).toUtc();
        final mins = now.difference(t).inMinutes;
        return mins >= 0 && mins <= 120; // ultimele 120 minute
      } catch (_) {
        return false;
      }
    }).toList();
  }
}
