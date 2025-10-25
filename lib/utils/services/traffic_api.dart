import 'dart:convert';
import 'package:http/http.dart' as http;

class TrafficApi {
  static const String _hostPort = '10.0.2.2:8090'; // emulator Android
  static const String _basePath = '/traffic';

  static Future<Map<String, dynamic>> getDirections({
    required String start,
    bool traffic = true,
    String travelMode = 'car',
  }) async {
    final uri = Uri.http(_hostPort, '$_basePath/directions', {
      'start': start,                 // ex: "44.4325,26.1039"
      'traffic': traffic.toString(),  // "true"
      'travelMode': travelMode,       // "car"
    });
    print('[GET] $uri');  // vezi exact ce pleacă
    final r = await http.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 8));
    print('[GET] status=${r.statusCode} body=${r.body}');
    if (r.statusCode != 200) {
      throw Exception('Directions error: ${r.statusCode} ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getIncidents({required String startBbox}) async {
    final uri = Uri.http(_hostPort, '$_basePath/incidents', {'startBbox': startBbox});
    print('[GET] $uri');
    final r = await http.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) {
      throw Exception('Incidents error: ${r.statusCode} ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}
