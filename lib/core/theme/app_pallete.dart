import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

const Color loginConColor = Colors.purple;

BorderRadius borderRadius = BorderRadius.circular(10);
BorderRadius borderRadius13=BorderRadius.circular(13);
Color borderColor = Color(0xFFD6D6D6);

class AdminDashboardColor {
  // Header Gradient
  static const Color headerGradientStart = Color(0xFF536CE4);
  static const Color headerGradientEnd = Color(0xFF8045D8);

  // Text  Color
  static const Color titleTextColor = Color(0xFF1E293B);
  static const Color subTextColor = Color(0xFF64748B);
  static const Color cardBorderColor = Color(0xFFD6D6D6);

  // 1. Appointments (Blue) Color
  static const Color bluebackGroundColor = Color(0xFFE4EDFF);
  static const Color blueIconColor = Color(0xFF3B82F6);

  // 2. Revenue (Green) Color
  static const Color greenBackgroundColor = Color(0xFFDFFCE5);
  static const Color greenIcon = Color(0xFF22C55E);

  // 3. Walk-ins (Purple) Color
  static const Color purpleBackgroundColor = Color(0xFFF2E7FE);
  static const Color purpleIcon = Color(0xFF9333EA);

  // 4. Completed (Orange) Color
  static const Color orangeBackgroundColor = Color(0xFFFFEDD5);
  static const Color orangeIconColor = Color(0xFFF97316);
}

class AdminAppointmentCalendarColor {
  static const Color primaryPurple = Color(0xFF8B3DFF);
  static const Color lightPurpleBg = Color(0xFFF3E8FF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF9CA3AF);
  static const Color greenAccent = Color(0xFF10B981);
  static const Color greenBg = Color(0xFFD1FAE5);
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color blueBg = Color(0xFFDBEAFE);
  static const Color purpleAccent = Color(0xFF8B5CF6);
}
class AppColors {
  static const background = Color(0xFFF5F7FA);
  static const sidebar = Color(0xFF1A202C);
  static const card = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);

  static const primary = Color(0xFF3182CE);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);

  static const border = Color(0xFFE5E7EB);
}

// class AdminAppointmentCalendarColor {
//   static const Color primaryPurple = Color(0xFF8B3DFF);
//   static const Color lightPurpleBg = Color(0xFFF3E8FF);
//   static const Color textDark = Color(0xFF1F2937);
//   static const Color textGrey = Color(0xFF9CA3AF);
//   static const Color greenAccent = Color(0xFF10B981);
//   static const Color greenBg = Color(0xFFD1FAE5);
//   static const Color blueAccent = Color(0xFF3B82F6);
//   static const Color blueBg = Color(0xFFDBEAFE);
//   static const Color purpleAccent = Color(0xFF8B5CF6);
// }

class AppPallete {
  // --- RICH BACKGROUNDS ---
  // A deep, space-like gradient for the main background
  static const Color midnightStart = Color(0xFF0F172A); // Deepest Navy
  static const Color midnightEnd = Color(0xFF1E293B);   // Slate Navy
  
  // --- ACCENTS ---
  static const Color gold = Color(0xFFFFD700);        // Electric Gold
  static const Color goldDim = Color(0xFFC5A059);     // Muted Gold
  static const Color accentCyan = Color(0xFF06B6D4);  // Cyber Cyan (for focus)
  
  // --- SURFACE ---
  static const Color glassWhite = Colors.white;       // We will use opacity on this
  static const Color glassBorder = Colors.white24;    // Subtle border
  
  // --- TEXT ---
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF94A3B8);
  
  // --- UTILS ---
  static const Color error = Color(0xFFFF453A);
  
  // --- GRADIENTS ---
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [midnightStart, midnightEnd],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}