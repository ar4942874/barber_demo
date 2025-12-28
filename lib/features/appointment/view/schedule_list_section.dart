import 'package:barber_demo/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class ScheduleListSection extends StatelessWidget {
  const ScheduleListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Schedule",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AdminAppointmentCalendarColor.textDark,
            ),
          ),
          const SizedBox(height: 20),

          const AppointmentTimeSlot(
            time: "9:00 AM",
            name: "John Smith",
            details: "Haircut • #BA78932",
            backGroundColor: AdminAppointmentCalendarColor.greenBg,
            verticalLineColor: AdminAppointmentCalendarColor.greenAccent,
          ),
          const AvailableTimeSlot(time: "9:30 AM"),
          const AppointmentTimeSlot(
            time: "10:00 AM",
            name: "Sarah Johnson",
            details: "Premium Shave • #BA78455",
            backGroundColor: AdminAppointmentCalendarColor.blueBg,
            verticalLineColor: AdminAppointmentCalendarColor.blueAccent,
          ),
          const AppointmentTimeSlot(
            time: "10:30 AM",
            name: "Mike Davis",
            details: "Haircut + Beard • #BA78567",
            backGroundColor: AdminAppointmentCalendarColor.lightPurpleBg,
            verticalLineColor: AdminAppointmentCalendarColor.purpleAccent,
          ),
          const AvailableTimeSlot(time: "11:00 AM"),
        ],
      
    );
  }
}

// ==========================================================

// ==========================================================
class AppointmentTimeSlot extends StatelessWidget {
  final String time;
  final String name;
  final String details;
  final Color backGroundColor;
  final Color verticalLineColor;

  const AppointmentTimeSlot({
    super.key,
    required this.time,
    required this.name,
    required this.details,
    required this.backGroundColor,
    required this.verticalLineColor,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
   
        child: SizedBox(
           height: screenHeight * 0.14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 70,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    time,
                    style: const TextStyle(
                      color: AdminAppointmentCalendarColor.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                // vertical line
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backGroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: verticalLineColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            details,
                            style: TextStyle(
                              color: AdminAppointmentCalendarColor.textDark,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
   
    );
  }
}

// ==========================================================

// ==========================================================
class AvailableTimeSlot extends StatelessWidget {
  final String time;

  const AvailableTimeSlot({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: const TextStyle(
                color: AdminAppointmentCalendarColor.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  "Available",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}