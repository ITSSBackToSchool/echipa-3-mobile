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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Office Seats'),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Container(
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
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
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
                  selectedTextStyle: TextStyle(color: AppColors.gri),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
