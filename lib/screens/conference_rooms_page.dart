import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:seat_booking_mobile/utils/app_colors.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';
import 'package:table_calendar/table_calendar.dart';

// Models
class Room {
  final int roomId;
  final int seatCount;
  final String name;

  Room({required this.roomId, required this.seatCount, required this.name});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['roomId'] ?? 0,
      seatCount: json['seatCount'] ?? 0,
      name: json['name'] ?? 'Unnamed Room',
    );
  }
}

class TimeSlot {
  final String start;
  final String end;
  final bool available;

  TimeSlot({required this.start, required this.end, required this.available});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'] ?? '00:00:00',
      end: json['end'] ?? '00:00:00',
      available: json['available'] ?? false,
    );
  }
}

class ConferenceRoomsPage extends StatefulWidget {
  const ConferenceRoomsPage({super.key});

  @override
  State<ConferenceRoomsPage> createState() => _ConferenceRoomsPageState();
}

class _ConferenceRoomsPageState extends State<ConferenceRoomsPage>
    with SingleTickerProviderStateMixin {
  int _selectedBuilding = 0; // 0 for T1, 1 for T2
  int? _selectedRoomId;
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Timer? _debounce;

  // Room State
  List<Room> _rooms = [];
  bool _isLoadingRooms = true;
  String? _roomsErrorMessage;

  // TimeSlot State
  List<TimeSlot> _timeSlots = [];
  bool _isLoadingTimeSlots = false;
  String? _timeSlotsErrorMessage;
  List<int> _selectedTimeSlotIndices = [];

  bool _isConfirming = false;

  final List<String> _floors = ['Parter', 'Etaj 1', 'Etaj 2'];
  final List<String> _buildings = ['T1', 'T2'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 3, vsync: this);
    _fetchRooms(); // Initial fetch

    _tabController.addListener(() {
      setState(() {
        _selectedRoomId = null;
        _timeSlots.clear();
        _selectedTimeSlotIndices.clear();
        _timeSlotsErrorMessage = null;
      });
      _debouncedFetchRooms();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _debouncedFetchRooms() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchRooms();
    });
  }

  Future<void> _fetchRooms() async {
    if (!mounted) return;
    setState(() {
      _isLoadingRooms = true;
      _roomsErrorMessage = null;
    });

    final floorName = _floors[_tabController.index];
    final buildingName = _buildings[_selectedBuilding];
    final url = Uri.parse(
        'http://10.0.2.2:8080/rooms/roomByFloorAndBuilding?floorName=$floorName&buildingName=$buildingName');

    try {
      final apiCall = http.get(url);
      final delay = Future.delayed(const Duration(milliseconds: 400));
      final responses = await Future.wait([apiCall, delay]);
      final response = responses[0] as http.Response;

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            _rooms = data.map((json) => Room.fromJson(json)).toList();
            _isLoadingRooms = false;
          });
        } else {
          throw Exception('Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _roomsErrorMessage = e.toString();
          _isLoadingRooms = false;
        });
      }
    }
  }

  Future<void> _fetchTimeSlots(int roomId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingTimeSlots = true;
      _timeSlotsErrorMessage = null;
      _timeSlots.clear();
      _selectedTimeSlotIndices.clear();
    });

    final date = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final url = Uri.parse(
        'http://10.0.2.2:8080/rooms/timeslots?roomId=$roomId&dateStart=${date}T00:00&dateEnd=${date}T23:00');

    try {
      final apiCall = http.get(url);
      final delay = Future.delayed(const Duration(milliseconds: 500));
      final responses = await Future.wait([apiCall, delay]);
      final response = responses[0] as http.Response;

      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            _timeSlots = data
                .map((json) => TimeSlot.fromJson(json))
                .where((slot) => slot.available)
                .toList();
            _isLoadingTimeSlots = false;
          });
        } else {
          throw Exception('Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _timeSlotsErrorMessage = e.toString();
          _isLoadingTimeSlots = false;
        });
      }
    }
  }

  Future<void> _confirmReservation() async {
    if (_selectedRoomId == null || _selectedTimeSlotIndices.isEmpty) return;

    setState(() {
      _isConfirming = true;
    });

    final firstSlot = _timeSlots[_selectedTimeSlotIndices.first];
    final lastSlot = _timeSlots[_selectedTimeSlotIndices.last];

    final url = Uri.parse('http://10.0.2.2:8080/reservations/rooms');
    final body = {
      'userId': 1,
      'roomId': _selectedRoomId,
      'reservationDateStart': firstSlot.start, // Corrected
      'reservationDateEnd': lastSlot.end,       // Corrected
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: AppColors.verde,
                content: Text('Reservation confirmed successfully!')),
          );
          setState(() {
            _selectedRoomId = null;
            _timeSlots.clear();
            _selectedTimeSlotIndices.clear();
          });
        } else {
          throw Exception('Failed to confirm: ${response.body}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: AppColors.rosu,
              content: Text("Room was already reserved by someone else")),
        );
        // Refetch on error
        if(_selectedRoomId != null) _fetchTimeSlots(_selectedRoomId!); 
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }


  void _onTimeSlotSelected(int index) {
    // The list is already filtered for available slots.
    setState(() {
      if (_selectedTimeSlotIndices.contains(index)) {
        _selectedTimeSlotIndices.remove(index);
      } else {
        if (_selectedTimeSlotIndices.isNotEmpty) {
          final last = _selectedTimeSlotIndices.last;
          final first = _selectedTimeSlotIndices.first;
          if (index != last + 1 && index != first - 1) {
            _selectedTimeSlotIndices.clear();
          }
        }
        _selectedTimeSlotIndices.add(index);
        _selectedTimeSlotIndices.sort();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.albastruInchis,
      appBar: const CustomAppBar(title: 'Conference Rooms'),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBuildingFilters(),
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
              color: AppColors.albastruInchis,
              child: _buildRoomsListContainer(),
            ),
            Container(
              color: AppColors.albastruInchis,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCalendar(),
                  const SizedBox(height: 20),
                  _buildTimeSlots(),
                  const SizedBox(height: 20),
                  _buildLegend(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingFilters() {
    return Container(
      color: AppColors.albastruInchis,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(0, 'Building T1'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFilterButton(1, 'Building T2'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(int index, String text) {
    final isSelected = _selectedBuilding == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedBuilding = index;
        });
        _debouncedFetchRooms();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.gri : AppColors.albastruInchis,
        side: isSelected ? null : const BorderSide(color: AppColors.gri),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(text,
          style: TextStyle(
              color: isSelected ? AppColors.albastruInchis : AppColors.gri)),
    );
  }

  Widget _buildRoomsListContainer() {
    if (_isLoadingRooms) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_roomsErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('An error occurred: $_roomsErrorMessage', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.rosu)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchRooms,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.albastruInchis),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    } else if (_rooms.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No rooms available for this selection.'),
        ),
      );
    } else {
      return _buildRoomsList();
    }
  }

  Widget _buildRoomsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        return _buildRoomCard(_rooms[index]);
      },
    );
  }

  Widget _buildRoomCard(Room room) {
    final isSelected = _selectedRoomId == room.roomId;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.gri,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                "https://images.pexels.com/photos/159213/hall-congress-architecture-building-159213.jpeg", // Placeholder for room.imageUrl
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 30),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.albastruInchis),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${room.seatCount} seats',
                    style: const TextStyle(color: AppColors.albastruInchis),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedRoomId == room.roomId) {
                     _selectedRoomId = null;
                     _timeSlots.clear();
                  } else {
                    _selectedRoomId = room.roomId;
                    _fetchTimeSlots(room.roomId);
                  }
                });
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: isSelected ? AppColors.accent : AppColors.albastruInchis,
                child: Icon(isSelected ? Icons.check : Icons.add, color: AppColors.gri, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final DateTime today = DateTime.now();


    final DateTime firstDayNextMonth =
    DateTime(today.year, today.month + 1, 1);
    final DateTime lastDayNextMonth =
    DateTime(today.year, today.month + 2, 0); // 0 = ultima zi din luna precedentă

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gri,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(8.0),
      child: TableCalendar(
        firstDay: today,
        lastDay: lastDayNextMonth,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

        onDaySelected: (selectedDay, focusedDay) {
          // blocăm weekendurile (sâmbătă = 6, duminică = 7)
          if (selectedDay.weekday == DateTime.saturday ||
              selectedDay.weekday == DateTime.sunday) {
            return;
          }

          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            if (_selectedRoomId != null) {
              _fetchTimeSlots(_selectedRoomId!);
            }
          }
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
          weekendStyle: TextStyle(color: Colors.grey),
        ),

        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: AppColors.albastruInchis),
          weekendTextStyle: const TextStyle(color: Colors.grey),
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: AppColors.appBarGradientEnd.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(color: AppColors.gri),
          selectedDecoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: AppColors.gri),
          disabledTextStyle: const TextStyle(color: Colors.grey),
        ),

        enabledDayPredicate: (day) {
          // nu permite selectarea weekendurilor
          return day.weekday != DateTime.saturday &&
              day.weekday != DateTime.sunday;
        },
      ),
    );
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

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Colors on the scheme:',
          style: TextStyle(color: AppColors.gri, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.gri,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(AppColors.verde, "Available"),
              _buildLegendItem(AppColors.accent, "Selected"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    if (_selectedRoomId == null) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Please select a room to see time slots.',
                  style: TextStyle(color: AppColors.gri))));
    }
    if (_isLoadingTimeSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_timeSlotsErrorMessage != null) {
      return Center(
          child: Column(children: [
        Text('Error: $_timeSlotsErrorMessage', style: const TextStyle(color: AppColors.rosu)),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: () => _fetchTimeSlots(_selectedRoomId!), child: const Text('Retry'))
      ]));
    }
    if (_timeSlots.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No time slots available.', style: TextStyle(color: AppColors.gri))));
    }

    return Column(
      children: List.generate(_timeSlots.length, (index) {
        final timeSlot = _timeSlots[index];
        final isSelected = _selectedTimeSlotIndices.contains(index);
        
        String startTime = DateFormat.jm().format(DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(timeSlot.start));
        String endTime = DateFormat.jm().format(DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(timeSlot.end));

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ElevatedButton(
            onPressed: () => _onTimeSlotSelected(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected
                  ? AppColors.accent
                  : AppColors.verde,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text('$startTime - $endTime', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      }),
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
                _selectedRoomId = null;
                _selectedTimeSlotIndices.clear();
                _timeSlots.clear();
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
            onPressed: _selectedRoomId == null || _selectedTimeSlotIndices.isEmpty || _isConfirming
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
