import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/utils/app_colors.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';
import 'package:table_calendar/table_calendar.dart';

class ConferenceRoomsPage extends StatefulWidget {
  const ConferenceRoomsPage({super.key});

  @override
  State<ConferenceRoomsPage> createState() => _ConferenceRoomsPageState();
}

class _ConferenceRoomsPageState extends State<ConferenceRoomsPage>
    with SingleTickerProviderStateMixin {
  int _selectedBuilding = 0;
  int? _selectedRoomIndex;
  int? _selectedTimeSlot;
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<int> _selectedTimeSlots = [];

  final List<String> _floors = ['Parter', 'Etaj 1', 'Etaj 2'];
  final List<String> _timeSlots = ['9AM - 10AM', '10AM - 11AM', '11AM - 12PM', '12PM - 1PM'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTimeSlotSelected(int index) {
    setState(() {
      if (_selectedTimeSlots.contains(index)) {
        // Deselect if already selected
        _selectedTimeSlots.remove(index);
      } else {
        // Check for contiguity
        if (_selectedTimeSlots.isNotEmpty) {
          final last = _selectedTimeSlots.last;
          final first = _selectedTimeSlots.first;
          if (index != last + 1 && index != first - 1) {
            _selectedTimeSlots.clear(); // Not contiguous, reset
          }
        }
        _selectedTimeSlots.add(index);
        _selectedTimeSlots.sort(); // Keep the list sorted
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
              child: IndexedStack(
                index: _tabController.index,
                children: _floors
                    .map((_) => _buildRoomsList())
                    .toList(),
              ),
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
      onPressed: () => setState(() => _selectedBuilding = index),
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

  Widget _buildRoomsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3, // Example number of rooms
      itemBuilder: (context, index) {
        return _buildRoomCard(index);
      },
    );
  }

  Widget _buildRoomCard(int index) {
    final isSelected = _selectedRoomIndex == index;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.gri,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(

                'https://images.pexels.com/photos/3201921/pexels-photo-3201921.jpeg',
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
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Colors.grey[400], size: 30),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Lounge',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.albastruInchis),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '23 locuri',
                    style: TextStyle(color: AppColors.albastruInchis),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRoomIndex =
                  _selectedRoomIndex == index ? null : index;
                });
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor:
                isSelected ? AppColors.accent : AppColors.albastruInchis,
                child: Icon(isSelected ? Icons.check : Icons.add,
                    color: AppColors.gri, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gri,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(8.0),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
         headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: AppColors.albastruInchis, fontSize: 18.0),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.albastruInchis),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.albastruInchis),
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
            color: AppColors.appBarGradientEnd.withOpacity(0.5),
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
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      children: List.generate(_timeSlots.length, (index) {
        final isSelected = _selectedTimeSlots.contains(index);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ElevatedButton(
            onPressed: () => _onTimeSlotSelected(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? AppColors.accent : AppColors.verde,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(_timeSlots[index], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                _selectedRoomIndex = null;
                _selectedTimeSlots.clear();
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
            onPressed: _selectedRoomIndex == null || _selectedTimeSlots.isEmpty
                ? null
                : () {
                    // Handle confirmation
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              backgroundColor: AppColors.gri,
              disabledBackgroundColor: Colors.grey.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm',
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
