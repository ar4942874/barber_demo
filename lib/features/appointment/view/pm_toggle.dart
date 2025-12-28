
 import 'package:barber_demo/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class PmAmToggle extends StatelessWidget {
  final String currentPeriod;
  final Function(String) onChanged;
  const PmAmToggle({super.key, required this.currentPeriod, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Expanded(child: _buildItem("AM")),
          Expanded(child: _buildItem("PM")),
        ],
      ),
    );
  }

  Widget _buildItem(String text) {
    bool isActive = currentPeriod == text;
    return GestureDetector(
      onTap: () => onChanged(text),
      child: Container(
        width: 50,
        decoration: BoxDecoration(
          color: isActive
              ? AdminAppointmentCalendarColor.primaryPurple
              : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: text == "AM" ? const Radius.circular(15) : Radius.zero,
            bottom: text == "PM" ? const Radius.circular(15) : Radius.zero,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.white
                  : AdminAppointmentCalendarColor.textGrey,
            ),
          ),
        ),
      ),
    );
  }
}

