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

class _OfficeSeatsPageState extends State<OfficeSeatsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedSeatIndex;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.gri,
        appBar: const CustomAppBar(title: 'Office Seats'),
        drawer: const CustomDrawer(),
        body: Column(
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
              color: AppColors.albastruInchis,
              child: const TabBar(
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.gri,
                tabs: [
                  Tab(text: 'Parter'),
                  Tab(text: 'Etaj 1'),
                  Tab(text: 'Etaj 2'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSeatGrid(),
                  _buildSeatGrid(),
                  _buildSeatGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 24.0,
        mainAxisSpacing: 24.0,
      ),
      itemCount: 16,
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
