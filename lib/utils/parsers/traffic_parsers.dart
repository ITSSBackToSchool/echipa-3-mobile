class TrafficParsers {
  static ({
  int? secs,
  int? meters,
  DateTime? departure,
  DateTime? arrival,
  }) parseRouteSummary(Map<String, dynamic> json) {
    if (json['routes'] is List && (json['routes'] as List).isNotEmpty) {
      final s = (json['routes'][0]['summary'] as Map<String, dynamic>);
      DateTime? _dt(dynamic v) {
        try { if (v is String) return DateTime.parse(v); } catch (_) {}
        return null;
      }
      return (
      secs:   (s['travelTimeInSeconds'] as num?)?.toInt(),
      meters: (s['lengthInMeters']      as num?)?.toInt(),
      departure: _dt(s['departureTime']),
      arrival:   _dt(s['arrivalTime']),
      );
    }
    return (secs: null, meters: null, departure: null, arrival: null);
  }

  /// GeoJSON incidents -> păstrăm și startTime + coordonate
  static List<Map<String, dynamic>> parseIncidents(Map<String, dynamic> json) {
    final out = <Map<String, dynamic>>[];
    final feats = json['features'];
    if (feats is List) {
      for (final f in feats) {
        final m = f as Map<String, dynamic>;
        final p = (m['properties'] as Map<String, dynamic>?);
        final g = (m['geometry']   as Map<String, dynamic>?);
        final coords = (g?['coordinates'] as List?)?.cast<num>();
        out.add({
          'title': p?['title'] ?? p?['description'] ?? 'Traffic incident',
          'type':  p?['incidentType'],
          'startTime': p?['startTime'], // string ISO
          'lon': coords != null && coords.length >= 2 ? coords[0].toDouble() : null,
          'lat': coords != null && coords.length >= 2 ? coords[1].toDouble() : null,
        });
      }
    }
    return out;
  }
}
