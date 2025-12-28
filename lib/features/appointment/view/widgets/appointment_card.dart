
import 'package:barber_demo/core/theme/app_pallete.dart';
import 'package:barber_demo/features/appointment/view/pm_toggle.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final String name;
  final String time;
  final String service;
  final String status;
  final Color backgroundColor;
  final Color textColor;
  const AppointmentCard({
    super.key,
    required this.name,
    required this.time,
    required this.service,
    required this.status,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData = status == "Done" ? Icons.check_circle : Icons.schedule;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)), // Light Grey Border
      ),
      child: Row(
        children: [
          // 1. LEFT ICON BOX
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(iconData, color: textColor, size: 30),
          ),

          const SizedBox(width: 16),

          // 2. MIDDLE TEXT (Name & Details)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$time • $service",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B), // Grey text
                  ),
                ),
              ],
            ),
          ),

          // 3. RIGHT STATUS BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 // WIDGET 2: TIME SELECTION SECTION


class TimeSelectionSection extends StatefulWidget {
  const TimeSelectionSection({super.key});

  @override
  State<TimeSelectionSection> createState() => _TimeSelectionSectionState();
}

class _TimeSelectionSectionState extends State<TimeSelectionSection> {
  int _hour = 9;
  int _minute = 30;
  String _period = "AM";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimelineCalendar(),
        const SizedBox(height: 30),
        const Text(
          "Select Start Time",
          style: TextStyle(
            fontSize: 16,
            color: AdminAppointmentCalendarColor.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 15),

        // Time Picker Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimeBox(
              value: _hour.toString().padLeft(2, '0'),
              label: "Hour",
              onTap: () => setState(() => _hour = _hour < 12 ? _hour + 1 : 1),
            ),
            const SizedBox(width: 10),
            Container(
              height: 90,
              alignment: Alignment.center,
              child: const Text(
                ":",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AdminAppointmentCalendarColor.textDark,
                ),
              ),
            ),
            const SizedBox(width: 10),
            TimeBox(
              value: _minute.toString().padLeft(2, '0'),
              label: "Minute",
              onTap: () =>
                  setState(() => _minute = _minute < 55 ? _minute + 5 : 0),
            ),
            const SizedBox(width: 15),
            PmAmToggle(
              currentPeriod: _period,
              onChanged: (val) => setState(() => _period = val),
            ),
          ],
        ),
      ],
    );
  }
}

class TimelineCalendar extends StatelessWidget {
  const TimelineCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyDateTimeLine(
      initialDate: DateTime.now(),
      onDateChange: (selectedDate) {},
      headerProps: const EasyHeaderProps(
        showHeader: false,
        monthPickerType: MonthPickerType.switcher,
        dateFormatter: DateFormatter.fullDateDMY(),
      ),
      dayProps: EasyDayProps(
        inactiveDayStyle: const DayStyle(
          dayNumStyle: TextStyle(color: Colors.white),
        ),
        dayStructure: DayStructure.dayStrDayNum,
        activeDayStyle: DayStyle(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class TimeBox extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback onTap;
  const TimeBox({super.key, required this.value, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AdminAppointmentCalendarColor.primaryPurple,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AdminAppointmentCalendarColor.textDark,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AdminAppointmentCalendarColor.textGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}