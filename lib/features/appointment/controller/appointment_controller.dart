// lib/features/appointment/controller/appointment_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/appointment_model.dart';
import '../repository/appointment_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Repository Provider
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository();
});

/// Selected Date Provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// All Appointments Provider
final allAppointmentsProvider = FutureProvider<List<AppointmentModel>>((ref) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getAllAppointments();
});

/// Appointments by Date Provider
final appointmentsByDateProvider = FutureProvider.family<List<AppointmentModel>, DateTime>((ref, date) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getAppointmentsByDate(date);
});

/// Today's Appointments Provider
final todaysAppointmentsProvider = FutureProvider<List<AppointmentModel>>((ref) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getTodaysAppointments();
});

/// Selected Date Appointments Provider
final selectedDateAppointmentsProvider = FutureProvider<List<AppointmentModel>>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getAppointmentsByDate(selectedDate);
});

/// Appointment Stats Provider
final appointmentStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getAppointmentStats();
});

/// Booked Time Slots Provider
final bookedTimeSlotsProvider = FutureProvider.family<List<String>, DateTime>((ref, date) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getBookedTimeSlots(date);
});

/// Booking Count by Service Provider
final bookingCountByServiceProvider = FutureProvider.family<int, String>((ref, serviceId) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getBookingCountByService(serviceId);
});

/// Upcoming Appointments Provider
final upcomingAppointmentsProvider = FutureProvider<List<AppointmentModel>>((ref) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getUpcomingAppointments();
});

// ─────────────────────────────────────────────────────────────────────────────
// APPOINTMENT CONTROLLER
// ─────────────────────────────────────────────────────────────────────────────

class AppointmentController extends StateNotifier<AsyncValue<List<AppointmentModel>>> {
  final AppointmentRepository _repository;
  final Ref _ref;

  AppointmentController(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadAppointments();
  }

  /// Load all appointments
  Future<void> loadAppointments() async {
    state = const AsyncValue.loading();
    try {
      final appointments = await _repository.getAllAppointments();
      state = AsyncValue.data(appointments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Load appointments by specific date
  Future<void> loadAppointmentsByDate(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final appointments = await _repository.getAppointmentsByDate(date);
      state = AsyncValue.data(appointments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add new appointment with multiple services
  Future<AppointmentModel?> addAppointment({
    required String customerName,
    required String customerPhone,
    required List<String> serviceIds,
    required String serviceNames,
    required DateTime appointmentDate,
    required String startTime,
    required String endTime,
    required int durationMinutes,
    required double price,
    String? notes,
  }) async {
    try {
      if (serviceIds.isEmpty) {
        throw Exception('At least one service must be selected');
      }

      final isAvailable = await _repository.isTimeSlotAvailable(
        appointmentDate,
        startTime,
      );

      if (!isAvailable) {
        throw Exception('This time slot is already booked');
      }

      final appointment = await _repository.createAppointment(
        customerName: customerName,
        customerPhone: customerPhone,
        serviceIds: serviceIds,
        serviceNames: serviceNames,
        appointmentDate: appointmentDate,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: durationMinutes,
        price: price,
        notes: notes,
      );

      _invalidateProviders();
      await loadAppointments();

      return appointment;
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ Update existing appointment with optional new service IDs
  Future<void> updateAppointment(
    AppointmentModel appointment, {
    List<String>? newServiceIds,  // ✅ Added optional parameter
  }) async {
    try {
      await _repository.updateAppointment(
        appointment,
        newServiceIds: newServiceIds,  // ✅ Pass to repository
      );
      _invalidateProviders();
      await loadAppointments();
    } catch (e) {
      rethrow;
    }
  }

  /// Update appointment status
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    try {
      await _repository.updateStatus(id, status);
      _invalidateProviders();
      await loadAppointments();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete appointment
  Future<void> deleteAppointment(String id) async {
    try {
      await _repository.deleteAppointment(id);
      _invalidateProviders();
      await loadAppointments();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if time slot is available
  Future<bool> checkTimeSlotAvailability(
    DateTime date,
    String startTime, {
    String? excludeId,
  }) async {
    return _repository.isTimeSlotAvailable(date, startTime, excludeId: excludeId);
  }

  /// Invalidate all related providers
  void _invalidateProviders() {
    _ref.invalidate(appointmentStatsProvider);
    _ref.invalidate(todaysAppointmentsProvider);
    _ref.invalidate(selectedDateAppointmentsProvider);
    _ref.invalidate(upcomingAppointmentsProvider);
    _ref.invalidate(allAppointmentsProvider);
  }
  
}

/// Controller Provider
final appointmentControllerProvider =
    StateNotifierProvider<AppointmentController, AsyncValue<List<AppointmentModel>>>((ref) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return AppointmentController(repository, ref);
});