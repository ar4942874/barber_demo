// lib/features/reporting/model/reporting_model.dart

/// A data point for use in charts, representing a value on a specific date.
class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({required this.date, required this.value});
}


/// A data model representing the performance of a single service.
class ServicePerformance {
  final String serviceName;
  final double totalRevenue;
  final int totalBookings;

  ServicePerformance({
    required this.serviceName,
    required this.totalRevenue,
    required this.totalBookings,
  });
}


/// The main data container for the entire Reporting Dashboard.
///
/// This single, rich object holds all the computed data for a given date range,
/// making it easy for the controller and UI to consume.
class ReportData {
  // The date range this report covers.
  final DateTime startDate;
  final DateTime endDate;

  // High-level Key Performance Indicators (KPIs).
  final double totalRevenue;
  final int billCount;
  final double averageBillValue;
  
  // Data prepared for visualization.
  final List<ChartDataPoint> dailyRevenue;
  final List<ServicePerformance> topServices;
  final Map<String, int> paymentMethodDistribution;

  const ReportData({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.billCount,
    required this.averageBillValue,
    required this.dailyRevenue,
    required this.topServices,
    required this.paymentMethodDistribution,
  });

  /// An empty factory constructor for creating a default/initial state.
  factory ReportData.empty() {
    final now = DateTime.now();
    return ReportData(
      startDate: now,
      endDate: now,
      totalRevenue: 0,
      billCount: 0,
      averageBillValue: 0,
      dailyRevenue: [],
      topServices: [],
      paymentMethodDistribution: {},
    );
  }
}