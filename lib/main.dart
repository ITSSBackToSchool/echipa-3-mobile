import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

/// ===== Config =====
const String BASE_URL =
    'http://10.0.2.2:8090'; // Emulator Android -> 10.0.2.2; pe device: IP-ul PC-ului
const int USER_ID = 1;
const String COMPANY_ADDRESS = 'Aleea Tibles nr.3';
const _workStartH = 9, _workStartM = 0, _workEndH = 17, _workEndM = 0;

/// ===== Models =====
class Reservation {
  final int id;
  final String status; // ACTIVE, COMPLETED, CANCELLED/CANCELED
  final int? seatId; // Office dacă != null
  final int? roomId; // Conference dacă != null
  final String? seatNumber;
  final String? roomName;
  final String? buildingName;
  final String? floorName;
  final String reservationDateStart; // 'YYYY-MM-DD' sau 'YYYY-MM-DD HH:mm' / ISO
  final String? reservationDateEnd;

  Reservation({
    required this.id,
    required this.status,
    this.seatId,
    this.roomId,
    this.seatNumber,
    this.roomName,
    this.buildingName,
    this.floorName,
    required this.reservationDateStart,
    this.reservationDateEnd,
  });

  factory Reservation.fromJson(Map<String, dynamic> j) => Reservation(
    id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
    status: (j['status'] ?? '').toString(),
    seatId: j['seatId'],
    roomId: j['roomId'],
    seatNumber: j['seatNumber']?.toString(),
    roomName: j['roomName']?.toString(),
    buildingName: j['buildingName']?.toString(),
    floorName: j['floorName']?.toString(),
    reservationDateStart: j['reservationDateStart']?.toString() ?? '',
    reservationDateEnd: j['reservationDateEnd']?.toString(),
  );
}

class NextVisitVM {
  final bool exists;
  final bool? isOffice;
  final String? title;
  final String? sub;
  final String? dayLabel;
  final String? timeLabel;

  const NextVisitVM({
    required this.exists,
    this.isOffice,
    this.title,
    this.sub,
    this.dayLabel,
    this.timeLabel,
  });

  static const empty = NextVisitVM(exists: false);
}

/// ===== App =====
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seat Booking',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.albastruInchis,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Home'),
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
  bool _loading = false;
  String? _error;
  NextVisitVM _vm = NextVisitVM.empty;
  bool _worksToday = false;

  // lățimea comună pentru cardul interior și butonul „View Reservations”
  static const double _kInnerCardMaxWidth = 340.0;
  // înălțimea butonului (și a box-ului „fără vizită”)
  static const double _kButtonHeight = 50.0;

  // helper pentru a impune aceeași lățime la conținutul interior
  Widget _inner(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kInnerCardMaxWidth),
        child: child,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadNextVisit();
  }

  Future<void> _loadNextVisit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
          '$BASE_URL/reservations/user?userId=$USER_ID&status=ACTIVE');
      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }

      final decoded = json.decode(resp.body);
      final List<Reservation> list = decoded is List
          ? decoded.map<Reservation>((e) => Reservation.fromJson(e)).toList()
          : decoded != null
          ? [Reservation.fromJson(decoded as Map<String, dynamic>)]
          : <Reservation>[];

      final next = _pickNextVisit(list);

      // calculează dacă există rezervare AZI (ne-terminată)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      bool worksToday = false;
      for (final r in list) {
        if ((r.status).toUpperCase() != 'ACTIVE') continue;

        final isConference = r.roomId != null;
        if (isConference) {
          final s = _parseLocal(r.reservationDateStart);
          final e = _parseLocal(r.reservationDateEnd ?? r.reservationDateStart);
          if (s == null || e == null) continue;
          final sDay = DateTime(s.year, s.month, s.day);
          if (sDay == today && e.isAfter(now)) {
            worksToday = true;
            break;
          }
        } else {
          final d = _parseLocal(r.reservationDateStart);
          if (d == null) continue;
          final start =
          DateTime(d.year, d.month, d.day, _workStartH, _workStartM);
          final end = DateTime(d.year, d.month, d.day, _workEndH, _workEndM);
          if (DateTime(d.year, d.month, d.day) == today && end.isAfter(now)) {
            worksToday = true;
            break;
          }
        }
      }

      setState(() {
        _vm = next != null ? _toViewModel(next) : NextVisitVM.empty;
        _worksToday = worksToday;
      });
    } catch (e) {
      setState(() {
        _error = 'Nu am putut încărca rezervările.';
        _vm = NextVisitVM.empty;
        _worksToday = false;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// ===== Date helpers =====
  DateTime? _parseLocal(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    var v = s.trim();
    // 'YYYY-MM-DD'
    final onlyDay = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (onlyDay.hasMatch(v)) {
      final parts = v.split('-').map(int.parse).toList();
      return DateTime(parts[0], parts[1], parts[2]);
    }
    // înlocuim spațiul cu 'T', tăiem milisecunde
    v = v.replaceFirst(' ', 'T').replaceAll(RegExp(r'\.\d+$'), '');
    return DateTime.tryParse(v);
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  bool _sameYMD(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// ===== Business rules (identice cu web) =====
  Reservation? _pickNextVisit(List<Reservation> list) {
    final now = DateTime.now();

    final rows = <({
    Reservation r,
    bool isOffice,
    DateTime dayOnly,
    DateTime start,
    DateTime end,
    })>[];

    for (final r in list) {
      if ((r.status).toUpperCase() != 'ACTIVE') continue;

      final isConference = r.roomId != null;
      final isOffice = !isConference;

      if (isOffice) {
        final d = _parseLocal(r.reservationDateStart);
        if (d == null) continue;
        final day = _startOfDay(d);
        final start =
        DateTime(day.year, day.month, day.day, _workStartH, _workStartM);
        final end =
        DateTime(day.year, day.month, day.day, _workEndH, _workEndM);
        rows.add((r: r, isOffice: true, dayOnly: day, start: start, end: end));
      } else {
        final s = _parseLocal(r.reservationDateStart);
        final e = _parseLocal(r.reservationDateEnd ?? r.reservationDateStart);
        if (s == null || e == null) continue;
        rows.add((r: r, isOffice: false, dayOnly: _startOfDay(s), start: s, end: e));
      }
    }

    // păstrăm dacă (end >= now) sau (start >= now)
    final futureRows = rows
        .where((x) => x.end.isAfter(now) || x.start.isAfter(now) || x.end.isAtSameMomentAs(now))
        .toList();

    if (futureRows.isEmpty) return null;

    // sortare: zi -> Office > Conference (doar dacă e aceeași zi) -> ora
    futureRows.sort((a, b) {
      if (!_sameYMD(a.dayOnly, b.dayOnly)) {
        return a.dayOnly.compareTo(b.dayOnly);
      }
      if (a.isOffice != b.isOffice) {
        return a.isOffice ? -1 : 1;
      }
      return a.start.compareTo(b.start);
    });

    return futureRows.first.r;
  }

  NextVisitVM _toViewModel(Reservation r) {
    final isConference = r.roomId != null;
    final isOffice = !isConference;

    final building = (r.buildingName ?? '').trim();
    final floor = (r.floorName ?? '').trim();
    final titleBase =
    [building, floor].where((e) => e.isNotEmpty).join(' - ');
    final title = isOffice
        ? (titleBase.isNotEmpty ? titleBase : 'Birou')
        : (r.roomName ?? (titleBase.isNotEmpty ? titleBase : 'Conference Room'));

    late String dayLabel, timeLabel;

    if (isOffice) {
      final d = _parseLocal(r.reservationDateStart)!;
      dayLabel = '${d.day} ${_monthRo(d.month)}';
      timeLabel = '9AM-17PM';
    } else {
      final s = _parseLocal(r.reservationDateStart)!;
      final e = _parseLocal(r.reservationDateEnd ?? r.reservationDateStart)!;
      dayLabel = '${s.day} ${_monthRo(s.month)}';
      timeLabel = '${_hhmm(s)}-${_hhmm(e)}';
    }

    return NextVisitVM(
      exists: true,
      isOffice: isOffice,
      title: title,
      sub: COMPANY_ADDRESS,
      dayLabel: dayLabel,
      timeLabel: timeLabel,
    );
  }

  String _monthRo(int m) {
    const months = [
      '', 'Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie',
      'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie'
    ];
    return months[m];
  }

  String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
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

  Widget _buildWelcomeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Bine ai revenit, User!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _worksToday ? 'Azi lucrezi de la birou.' : 'Azi nu lucrezi de la birou.',
              style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Image.asset('assets/images/working_man.png',
                height: 200, fit: BoxFit.contain),
          ],
        ),
      ],
    );
  }

  Widget _buildNextVisitCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEAF6),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(9, 9),
            blurRadius: 4,
            spreadRadius: 0,
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

          // conținutul cardului – lățime identică cu butonul
          if (_loading) _inner(_skeletonVisitDetails())
          else if (_error != null) _inner(_errorBox(_error!))
          else _inner(_visitDetailsBox()),

          const SizedBox(height: 24),

          // buton cu aceeași lățime
          _inner(
            SizedBox(
              height: _kButtonHeight,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/my-bookings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF374151),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, _kButtonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: const Text(
                  'View Reservations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonVisitDetails() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15.0),
      border: Border.all(color: const Color(0xFF374151), width: 1.5),
    ),
    padding: const EdgeInsets.all(16),
    child: const Text(
      'Se încarcă...',
      style: TextStyle(color: Color(0xFF4B5563)),
    ),
  );

  Widget _errorBox(String msg) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15.0),
      border: Border.all(color: const Color(0xFF374151), width: 1.5),
    ),
    padding: const EdgeInsets.all(16),
    child: Text(
      msg,
      style: const TextStyle(color: Color(0xFFB91C1C)),
    ),
  );

  Widget _visitShell({required Widget child}) {
    return Container(
      // lățimea e controlată de _inner()
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: const Color(0xFF374151), width: 1.5),
      ),
      child: child,
    );
  }

  Widget _visitDetailsBox() {
    if (!_vm.exists) {
      // aceeași lățime + EXACT aceeași înălțime ca butonul
      return SizedBox(
        height: _kButtonHeight,
        child: _visitShell(
          child: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Nu ai nicio vizită viitoare programată.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Color(0xFF4B5563)),
              ),
            ),
          ),
        ),
      );
    }

    return _visitShell(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _vm.title ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF374151),
                  ),
                ),
                if ((_vm.sub ?? '').isNotEmpty)
                  Text(
                    _vm.sub!,
                    style: const TextStyle(color: Color(0xFF4B5563)),
                  ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF374151), height: 1.5),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _vm.dayLabel ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  _vm.timeLabel ?? '',
                  style: const TextStyle(color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
