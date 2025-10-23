import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:seat_booking_mobile/utils/app_colors.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';
import 'package:table_calendar/table_calendar.dart';

// Seat Model
class Seat {
  final int id;
  final String seatNumber;
  final bool occupied;

  Seat({required this.id, required this.seatNumber, required this.occupied});

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'],
      seatNumber: json['seatNumber'],
      occupied: json['occupied'],
    );
  }
}

class OfficeSeatsPage extends StatefulWidget {
  const OfficeSeatsPage({super.key});

  @override
  State<OfficeSeatsPage> createState() => _OfficeSeatsPageState();
}

class _OfficeSeatsPageState extends State<OfficeSeatsPage>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedSeatId;
  late TabController _tabController;
  final List<String> _floors = ['Parter', 'Etaj 1', 'Etaj 2'];
  bool _isConfirming = false;
  Timer? _debounce;

  // State management for seats
  List<Seat> _seats = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 3, vsync: this);
    _fetchSeats(); // Initial fetch

    _tabController.addListener(() {
      setState(() {
        _selectedSeatId = null;
      });
      _debouncedFetch();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _debouncedFetch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () { // Reduced debounce time
      _fetchSeats();
    });
  }

  Future<void> _fetchSeats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final floorId = _tabController.index + 1;
    final date = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final url = Uri.parse(
        'http://10.0.2.2:8080/seats/freeSeats?floorId=$floorId&dateStart=${date}T00:00&dateEnd=${date}T23:59');

    try {
      // Perform API call and a minimum delay in parallel
      final apiCall = http.get(url);
      final delay = Future.delayed(const Duration(milliseconds: 500));

      final responses = await Future.wait([apiCall, delay]);
      final response = responses[0] as http.Response;

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            _seats = data.map((json) => Seat.fromJson(json)).toList();
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

    Future<void> _confirmReservation() async {
    if (_selectedSeatId == null) return;

    setState(() {
      _isConfirming = true;
    });

    final url = Uri.parse('http://10.0.2.2:8080/reservations/seats');
    final date = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final body = {
      'userId': 1, // Hardcoded userId
      'seatIds': [_selectedSeatId],
      'reservationDateStart': '${date}T00:00:00',
      'reservationDateEnd': '${date}T23:59:00',
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: AppColors.verde,
              content: Text('Reservation confirmed successfully!')),
        );
        setState(() {
          _selectedSeatId = null;
        });
        _fetchSeats(); // Refresh seats after confirmation
      } else {
        throw Exception('Failed to confirm: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: AppColors.rosu, content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.albastruInchis,
      appBar: const CustomAppBar(title: 'Office Seats'),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendar(),
            Container(
              color: AppColors.gri,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent,
                labelColor: AppColors.albastruInchis,
                unselectedLabelColor: AppColors.albastruInchis.withOpacity(0.6),
                tabs: _floors.map((floor) => Tab(text: floor)).toList(),
              ),
            ),
            Container(
              color: AppColors.gri,
              child: _buildSeatGridContainer(),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      color: AppColors.albastruInchis,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.gri,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedSeatId = null;
                });
                _debouncedFetch();
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle:
                  TextStyle(color: AppColors.albastruInchis, fontSize: 18.0),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: AppColors.albastruInchis),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: AppColors.albastruInchis),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.albastruInchis),
              weekendStyle: TextStyle(color: AppColors.albastruInchis),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: AppColors.albastruInchis),
              weekendTextStyle: const TextStyle(color: AppColors.albastruInchis),
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: AppColors.appBarGradientEnd,
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: AppColors.gri),
              selectedDecoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: AppColors.gri),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatGridContainer() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('Error: $_errorMessage'),
        ),
      );
    } else if (_seats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No seats available.'),
        ),
      );
    } else {
      return _buildSeatGrid(_seats);
    }
  }

  Widget _buildSeatGrid(List<Seat> seats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: seats.length,
      itemBuilder: (context, index) {
        final seat = seats[index];
        final isSelected = _selectedSeatId == seat.id;

        Color seatColor;
        if (isSelected) {
          seatColor = AppColors.portocaliu;
        } else if (!seat.occupied) {
          seatColor = AppColors.verde;
        } else {
          seatColor = AppColors.rosu;
        }

        return GestureDetector(
          onTap: () {
            if (!seat.occupied) {
              setState(() {
                if (_selectedSeatId == seat.id) {
                  _selectedSeatId = null;
                } else {
                  _selectedSeatId = seat.id;
                }
              });
            }
          },
          child: Tooltip(
            message: seat.seatNumber,
            child: Icon(Icons.event_seat, color: seatColor, size: 40),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.albastruInchis,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegend(),
          const SizedBox(height: 20),
          _buildSelectedSeatInfo(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gri,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tables on the scheme:",
              style: TextStyle(
                  color: AppColors.albastruInchis.withOpacity(0.8),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(AppColors.verde, "Available"),
                _buildLegendItem(AppColors.portocaliu, "Selected"),
                _buildLegendItem(AppColors.rosu, "Unavailable"),
              ],
            ),
          ],
        ));
  }

  Widget _buildLegendItem(Color? color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: AppColors.albastruInchis)),
      ],
    );
  }

  Widget _buildSelectedSeatInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Selected seat:",
          style: TextStyle(
              color: AppColors.gri, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.gri,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    _selectedSeatId != null
                        ? "Floor: ${_floors[_tabController.index]}"
                        : "Floor: -",
                    style: const TextStyle(
                        color: AppColors.albastruInchis,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const VerticalDivider(
                color: AppColors.albastruInchis,
                thickness: 1,
                width: 1,
                indent: 10,
                endIndent: 10,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _selectedSeatId != null
                        ? "Seat: $_selectedSeatId"
                        : "Seat: -",
                    style: const TextStyle(
                        color: AppColors.albastruInchis,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedSeatId = null;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              side: const BorderSide(color: AppColors.gri),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reset',
                style: TextStyle(
                    color: AppColors.gri,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedSeatId == null || _isConfirming
                ? null
                : _confirmReservation,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              backgroundColor: AppColors.gri,
              disabledBackgroundColor: Colors.grey.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isConfirming
                ? const CircularProgressIndicator(color: AppColors.albastruInchis)
                : const Text('Confirm',
                    style: TextStyle(
                        color: AppColors.albastruInchis,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
