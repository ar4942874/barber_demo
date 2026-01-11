// lib/features/reporting/repository/reporting_repository.dart

import 'package:barber_demo/core/databases/database_helper.dart';
import 'package:barber_demo/features/billing/repository/billing_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/constants/db_constants.dart';
import '../model/reporting_model.dart'; // We will create this file next

/// Provider to make the ReportingRepository available to the controller.
final reportingRepositoryProvider = Provider<ReportingRepository>((ref) {
  // Uses the existing DatabaseHelper instance from the billing module's provider
  final dbHelper = ref.watch(databaseHelperProvider);
  return ReportingRepository(dbHelper);
});

// We can reuse the provider for DatabaseHelper defined in the billing repository.
// If not, you can define it here again:
// final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);


class ReportingRepository {
  final DatabaseHelper _dbHelper;
  ReportingRepository(this._dbHelper);

  /// The main method to fetch and compute all data for the dashboard for a given date range.
  Future<ReportData> getReportData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;

    // To use in WHERE clauses, we need to format dates to match how they are stored in SQLite.
    // We set the time to the very beginning of the start day and the very end of the end day.
    final start = DateTime(startDate.year, startDate.month, startDate.day).toIso8601String();
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59).toIso8601String();
    
    // Execute all queries in parallel for maximum performance.
    final results = await Future.wait([
      _getTotalRevenue(db, start, end),
      _getDailyRevenue(db, start, end),
      _getTopServices(db, start, end),
      _getPaymentMethodDistribution(db, start, end),
    ]);

    // Unpack the results from Future.wait
    final kpiData = results[0] as Map<String, dynamic>;
    final dailyRevenue = results[1] as List<ChartDataPoint>;
    final topServices = results[2] as List<ServicePerformance>;
    final paymentMethods = results[3] as Map<String, int>;

    // Construct the final, rich data model.
    return ReportData(
      startDate: startDate,
      endDate: endDate,
      totalRevenue: kpiData['totalRevenue'] ?? 0.0,
      billCount: kpiData['billCount'] ?? 0,
      averageBillValue: kpiData['averageBillValue'] ?? 0.0,
      dailyRevenue: dailyRevenue,
      topServices: topServices,
      paymentMethodDistribution: paymentMethods,
    );
  }

  // --- Private Helper Methods for Individual SQL Queries ---

  /// Calculates high-level KPIs: Total Revenue, Bill Count, and Average Bill Value.
  Future<Map<String, dynamic>> _getTotalRevenue(Database db, String start, String end) async {
    // This single query uses SQL aggregate functions to get all 3 KPIs at once.
    final result = await db.rawQuery('''
      SELECT
        SUM(${DbConstants.colTotal}) as totalRevenue,
        COUNT(${DbConstants.colId}) as billCount,
        AVG(${DbConstants.colTotal}) as averageBillValue
      FROM ${DbConstants.tableBills}
      WHERE ${DbConstants.colCreatedAt} BETWEEN ? AND ?
    ''', [start, end]);

    final data = result.first;
    // The result from SUM/AVG can be null if there are no rows, so we must handle that.
    return {
      'totalRevenue': data['totalRevenue'] ?? 0.0,
      'billCount': data['billCount'] ?? 0,
      'averageBillValue': data['averageBillValue'] ?? 0.0,
    };
  }

  /// Calculates revenue per day for the bar chart.
  Future<List<ChartDataPoint>> _getDailyRevenue(Database db, String start, String end) async {
    // `strftime` is a powerful SQLite function to format dates.
    // We group by 'YYYY-MM-DD' to sum up all sales for each day.
    final result = await db.rawQuery('''
      SELECT
        strftime('%Y-%m-%d', ${DbConstants.colCreatedAt}) as date,
        SUM(${DbConstants.colTotal}) as dailyTotal
      FROM ${DbConstants.tableBills}
      WHERE ${DbConstants.colCreatedAt} BETWEEN ? AND ?
      GROUP BY date
      ORDER BY date ASC
    ''', [start, end]);

    if (result.isEmpty) return [];

    return result.map((row) {
      return ChartDataPoint(
        date: DateTime.parse(row['date'] as String),
        value: (row['dailyTotal'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  /// Finds the top-performing services by revenue.
  Future<List<ServicePerformance>> _getTopServices(Database db, String start, String end) async {
    // This query joins bill_items with bills to filter by date, then groups by serviceName.
    final result = await db.rawQuery('''
      SELECT
        bi.${DbConstants.colServiceName},
        SUM(bi.${DbConstants.colPrice} * bi.${DbConstants.colQuantity}) as totalRevenue,
        SUM(bi.${DbConstants.colQuantity}) as totalQuantity
      FROM ${DbConstants.tableBillItems} as bi
      JOIN ${DbConstants.tableBills} as b ON bi.${DbConstants.colBillId} = b.id
      WHERE b.${DbConstants.colCreatedAt} BETWEEN ? AND ?
      GROUP BY bi.${DbConstants.colServiceName}
      ORDER BY totalRevenue DESC
      LIMIT 5 
    ''', [start, end]); // We limit to the top 5 services.

    if (result.isEmpty) return [];

    return result.map((row) {
      return ServicePerformance(
        serviceName: row[DbConstants.colServiceName] as String,
        totalRevenue: (row['totalRevenue'] as num?)?.toDouble() ?? 0.0,
        totalBookings: (row['totalQuantity'] as int?) ?? 0,
      );
    }).toList();
  }

  /// Calculates the distribution of payments by method.
  Future<Map<String, int>> _getPaymentMethodDistribution(Database db, String start, String end) async {
    final result = await db.rawQuery('''
      SELECT
        ${DbConstants.colPaymentMethod},
        COUNT(${DbConstants.colId}) as count
      FROM ${DbConstants.tableBills}
      WHERE ${DbConstants.colCreatedAt} BETWEEN ? AND ?
      GROUP BY ${DbConstants.colPaymentMethod}
    ''', [start, end]);
    
    if (result.isEmpty) return {};

    // Convert the list of maps into a single map for easier lookup.
    return {
      for (var row in result)
        row[DbConstants.colPaymentMethod] as String: (row['count'] as int?) ?? 0
    };
  }
}