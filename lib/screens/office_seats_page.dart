import 'package:flutter/material.dart';
import 'package:seat_booking_mobile/utils/app_colors.dart';
import 'package:seat_booking_mobile/widgets/custom_app_bar.dart';
import 'package:seat_booking_mobile/widgets/custom_drawer.dart';
import 'package:table_calendar/table_calendar.dart';

class OfficeSeatsPage extends StatefulWidget {
  const OfficeSeatsPage({super.key});

  @override
  State<OfficeSeatsPage> createState() => _OfficeSeatsPageState();
}

class _OfficeSeatsPageState extends State<OfficeSeatsPage>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedSeatIndex;
  late TabController _tabController;
  final List<String> _floors = ['Parter', 'Etaj 1', 'Etaj 2'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedSeatIndex = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            Container(
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
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                          color: AppColors.albastruInchis, fontSize: 18.0),
                      leftChevronIcon: Icon(Icons.chevron_left,
                          color: AppColors.albastruInchis),
                      rightChevronIcon: Icon(Icons.chevron_right,
                          color: AppColors.albastruInchis),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: AppColors.albastruInchis),
                      weekendStyle: TextStyle(color: AppColors.albastruInchis),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle:
                          const TextStyle(color: AppColors.albastruInchis),
                      weekendTextStyle:
                          const TextStyle(color: AppColors.albastruInchis),
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
            ),
            Container(
              color: AppColors.gri,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent,
                labelColor: AppColors.albastruInchis,
                unselectedLabelColor: AppColors.albastruInchis.withOpacity(0.6),
                tabs: const [
                  Tab(text: 'Parter'),
                  Tab(text: 'Etaj 1'),
                  Tab(text: 'Etaj 2'),
                ],
              ),
            ),
            Container(
              color: AppColors.gri,
              child: IndexedStack(
                index: _tabController.index,
                children: [
                  _buildSeatGrid(),
                  _buildSeatGrid(),
                  _buildSeatGrid(),
                ],
              ),
            ),
            Container(
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
            )
          ],
        ),
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
                    _selectedSeatIndex != null
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
                    _selectedSeatIndex != null
                        ? "Seat: ${_selectedSeatIndex! + 1}"
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
                _selectedSeatIndex = null;
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
            onPressed: _selectedSeatIndex == null
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

  Widget _buildSeatGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Changed to 5
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: 17,
      itemBuilder: (context, index) {
        final bool isAvailable = ![2, 5, 8, 9, 13, 14].contains(index);
        final bool isSelected = _selectedSeatIndex == index;

        Color seatColor;
        if (isSelected) {
          seatColor = AppColors.portocaliu;
        } else if (isAvailable) {
          seatColor = AppColors.verde;
        } else {
          seatColor = AppColors.rosu;
        }

        return GestureDetector(
          onTap: () {
            if (isAvailable) {
              setState(() {
                if (_selectedSeatIndex == index) {
                  _selectedSeatIndex = null;
                } else {
                  _selectedSeatIndex = index;
                }
              });
            }
          },
          child: Icon(Icons.event_seat, color: seatColor, size: 40),
        );
      },
    );
  }
}
