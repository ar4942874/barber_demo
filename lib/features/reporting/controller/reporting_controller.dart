// lib/features/reporting/controller/reporting_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/reporting_model.dart';
import '../repository/reporting_repository.dart';

// ===========================================================================
// DATE RANGE PROVIDER
// ===========================================================================

/// A simple StateProvider to hold the currently selected date range for the dashboard.
/// The UI will interact with this provider to change the date range.
final reportDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  // Default to "This Week".
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  return DateTimeRange(start: startOfWeek, end: endOfWeek);
});


// ===========================================================================
// MAIN CONTROLLER (StateNotifier)
// ===========================================================================

/// This controller is the core logic hub for the reporting screen.
/// It automatically refetches data whenever the date range changes.
class ReportingController extends StateNotifier<AsyncValue<ReportData>> {
  final ReportingRepository _repository;
  final DateTimeRange _dateRange;

  ReportingController(this._repository, this._dateRange)
      : super(const AsyncLoading()) {
    // Fetch data as soon as the controller is initialized.
    getReportData();
  }

  /// Fetches the report data from the repository for the current date range
  /// and updates the state with either the data, a loading state, or an error.
  Future<void> getReportData() async {
    state = const AsyncLoading();
    try {
      final reportData = await _repository.getReportData(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
      );
      state = AsyncData(reportData);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}


// ===========================================================================
// MAIN PROVIDER
// ===========================================================================

/// The main provider that the UI will watch.
///
/// This is a special kind of provider that depends on another provider (`reportDateRangeProvider`).
/// Whenever the date range changes, Riverpod will automatically destroy the old
/// controller and create a new one with the new date range, which in turn triggers a data refetch.
/// This elegant, reactive pattern is a core strength of Riverpod.
final reportingControllerProvider =
    StateNotifierProvider<ReportingController, AsyncValue<ReportData>>((ref) {
  final dateRange = ref.watch(reportDateRangeProvider);
  final repository = ref.watch(reportingRepositoryProvider);
  return ReportingController(repository, dateRange);
});