// lib/features/dashboard/controller/dashboard_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../appointment/model/appointment_model.dart';
import '../../appointment/controller/appointment_controller.dart';

// Dashboard Stats Model
class DashboardStats {
  final int totalAppointments;
  final int todayAppointments;
  final int pendingAppointments;
  final double totalRevenue;
  final int completedAppointments;

  DashboardStats({
    required this.totalAppointments,
    required this.todayAppointments,
    required this.pendingAppointments,
    required this.totalRevenue,
    required this.completedAppointments,
  });
}

// Stats Provider
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  
  // Fetch data
  final allAppointments = await repository.getAllAppointments();
  final todayAppointmentsList = await repository.getTodaysAppointments();
  
  // Calculate stats
  final totalAppointments = allAppointments.length;
  final todayAppointments = todayAppointmentsList.length;
  
  final pendingAppointments = allAppointments.where((a) => 
    a.status == AppointmentStatus.scheduled || 
    a.status == AppointmentStatus.confirmed
  ).length;
  
  final completedAppointments = allAppointments.where((a) => 
    a.status == AppointmentStatus.completed
  ).length;
  
  // Calculate revenue from completed appointments
  final totalRevenue = allAppointments
      .where((a) => a.status == AppointmentStatus.completed)
      .fold(0.0, (sum, item) => sum + item.price);

  return DashboardStats(
    totalAppointments: totalAppointments,
    todayAppointments: todayAppointments,
    pendingAppointments: pendingAppointments,
    totalRevenue: totalRevenue,
    completedAppointments: completedAppointments,
  );
});