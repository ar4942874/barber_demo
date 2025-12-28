// lib/features/appointment/repository/appointment_repository.dart

import 'package:barber_demo/core/databases/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/db_constants.dart';
import '../model/appointment_model.dart';

class AppointmentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER: Extract int from query result
  // ─────────────────────────────────────────────────────────────────────────
  int _extractCount(List<Map<String, dynamic>> result) {
    if (result.isEmpty) return 0;
    final firstRow = result.first;
    final value = firstRow['count'] ?? firstRow.values.first;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER: Fetch Service IDs for Appointments
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<AppointmentModel>> _populateServiceIds(List<Map<String, dynamic>> appointmentMaps) async {
    final db = await _dbHelper.database;
    List<AppointmentModel> appointments = [];

    for (final map in appointmentMaps) {
      final apptId = map[DbConstants.colId] as String;
      
      // Query junction table for service IDs
      final serviceMaps = await db.query(
        DbConstants.tableAppointmentServices,
        columns: [DbConstants.colSvcId],
        where: '${DbConstants.colApptId} = ?',
        whereArgs: [apptId],
      );
      
      final serviceIds = serviceMaps.map((s) => s[DbConstants.colSvcId] as String).toList();

      // Create model with fetched service IDs
      appointments.add(AppointmentModel.fromMap(map, serviceIds: serviceIds));
    }
    return appointments;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────────────────────────────
  Future<AppointmentModel> createAppointment({
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
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final appointmentId = _uuid.v4();

    final appointment = AppointmentModel(
      id: appointmentId,
      customerName: customerName,
      customerPhone: customerPhone,
      serviceIds: serviceIds, // Populate model directly
      serviceName: serviceNames,
      appointmentDate: appointmentDate,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      price: price,
      status: AppointmentStatus.scheduled,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    await db.transaction((txn) async {
      // 1. Insert into Appointments Table
      await txn.insert(
        DbConstants.tableAppointments,
        appointment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Insert into Junction Table
      for (final serviceId in serviceIds) {
        await txn.insert(
          DbConstants.tableAppointmentServices,
          {
            DbConstants.colApptId: appointmentId,
            DbConstants.colSvcId: serviceId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });

    print("✅ Appointment created: $appointmentId with ${serviceIds.length} services");
    return appointment;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // READ ALL
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<AppointmentModel>> getAllAppointments() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DbConstants.tableAppointments,
      orderBy: '${DbConstants.colAppointmentDate} DESC, ${DbConstants.colStartTime} ASC',
    );

    return _populateServiceIds(maps);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // READ BY DATE
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<AppointmentModel>> getAppointmentsByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = DateTime(date.year, date.month, date.day)
        .toIso8601String()
        .split('T')[0];

    final maps = await db.query(
      DbConstants.tableAppointments,
      where: '${DbConstants.colAppointmentDate} LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: '${DbConstants.colStartTime} ASC',
    );

    return _populateServiceIds(maps);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // READ TODAY'S APPOINTMENTS
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<AppointmentModel>> getTodaysAppointments() async {
    return getAppointmentsByDate(DateTime.now());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // READ BY STATUS
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<AppointmentModel>> getAppointmentsByStatus(AppointmentStatus status) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DbConstants.tableAppointments,
      where: '${DbConstants.colStatus} = ?',
      whereArgs: [status.name],
      orderBy: '${DbConstants.colAppointmentDate} DESC, ${DbConstants.colStartTime} ASC',
    );

    return _populateServiceIds(maps);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // READ BY ID
  // ─────────────────────────────────────────────────────────────────────────
  Future<AppointmentModel?> getAppointmentById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DbConstants.tableAppointments,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    
    // Populate service IDs for single item
    final appointments = await _populateServiceIds(maps);
    return appointments.first;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // READ UPCOMING APPOINTMENTS
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final maps = await db.query(
      DbConstants.tableAppointments,
      where: "${DbConstants.colAppointmentDate} >= ? AND ${DbConstants.colStatus} IN ('scheduled', 'confirmed')",
      whereArgs: [now],
      orderBy: '${DbConstants.colAppointmentDate} ASC, ${DbConstants.colStartTime} ASC',
    );

    return _populateServiceIds(maps);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // READ APPOINTMENTS BY SERVICE
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<AppointmentModel>> getAppointmentsByService(String serviceId) async {
    final db = await _dbHelper.database;
    
    final query = '''
      SELECT a.* 
      FROM ${DbConstants.tableAppointments} a
      INNER JOIN ${DbConstants.tableAppointmentServices} as_j 
      ON a.${DbConstants.colId} = as_j.${DbConstants.colApptId}
      WHERE as_j.${DbConstants.colSvcId} = ?
      ORDER BY a.${DbConstants.colAppointmentDate} DESC
    ''';

    final maps = await db.rawQuery(query, [serviceId]);
    return _populateServiceIds(maps);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COUNT BOOKINGS BY SERVICE
  // ─────────────────────────────────────────────────────────────────────────
  Future<int> getBookingCountByService(String serviceId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.tableAppointmentServices} WHERE ${DbConstants.colSvcId} = ?',
      [serviceId],
    );
    return _extractCount(result);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updateAppointment(
    AppointmentModel appointment, {
    List<String>? newServiceIds,
  }) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1. Update appointment details
      await txn.update(
        DbConstants.tableAppointments,
        appointment.copyWith(updatedAt: DateTime.now()).toMap(),
        where: '${DbConstants.colId} = ?',
        whereArgs: [appointment.id],
      );

      // 2. Update services if provided
      if (newServiceIds != null) {
        // Delete old links
        await txn.delete(
          DbConstants.tableAppointmentServices,
          where: '${DbConstants.colApptId} = ?',
          whereArgs: [appointment.id],
        );

        // Add new links
        for (final serviceId in newServiceIds) {
          await txn.insert(
            DbConstants.tableAppointmentServices,
            {
              DbConstants.colApptId: appointment.id,
              DbConstants.colSvcId: serviceId,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    });

    print("✅ Appointment updated: ${appointment.id}");
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE STATUS
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    final db = await _dbHelper.database;
    await db.update(
      DbConstants.tableAppointments,
      {
        DbConstants.colStatus: status.name,
        DbConstants.colUpdatedAt: DateTime.now().toIso8601String(),
        DbConstants.colIsSynced: 0,
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
    print("✅ Appointment status updated to: ${status.name}");
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> deleteAppointment(String id) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        DbConstants.tableAppointmentServices,
        where: '${DbConstants.colApptId} = ?',
        whereArgs: [id],
      );
      await txn.delete(
        DbConstants.tableAppointments,
        where: '${DbConstants.colId} = ?',
        whereArgs: [id],
      );
    });
    print("✅ Appointment deleted: $id");
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET STATS
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, int>> getAppointmentStats() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final todayStr = DateTime(today.year, today.month, today.day)
        .toIso8601String()
        .split('T')[0];

    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM ${DbConstants.tableAppointments}');
    final todayResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.tableAppointments} WHERE ${DbConstants.colAppointmentDate} LIKE ?',
      ['$todayStr%'],
    );
    final completedResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM ${DbConstants.tableAppointments} WHERE ${DbConstants.colStatus} = 'completed'",
    );
    final upcomingResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM ${DbConstants.tableAppointments} WHERE ${DbConstants.colStatus} IN ('scheduled', 'confirmed') AND ${DbConstants.colAppointmentDate} >= ?",
      [DateTime.now().toIso8601String()],
    );
    final cancelledResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM ${DbConstants.tableAppointments} WHERE ${DbConstants.colStatus} = 'cancelled'",
    );

    return {
      'total': _extractCount(totalResult),
      'today': _extractCount(todayResult),
      'completed': _extractCount(completedResult),
      'upcoming': _extractCount(upcomingResult),
      'cancelled': _extractCount(cancelledResult),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHECK TIME SLOT AVAILABILITY
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> isTimeSlotAvailable(
    DateTime date,
    String startTime, {
    String? excludeId,
  }) async {
    final db = await _dbHelper.database;
    final dateStr = DateTime(date.year, date.month, date.day)
        .toIso8601String()
        .split('T')[0];

    String query = '''
      SELECT COUNT(*) as count FROM ${DbConstants.tableAppointments} 
      WHERE ${DbConstants.colAppointmentDate} LIKE ? 
      AND ${DbConstants.colStartTime} = ? 
      AND ${DbConstants.colStatus} NOT IN ('cancelled')
    ''';

    List<dynamic> args = ['$dateStr%', startTime];

    if (excludeId != null) {
      query += ' AND ${DbConstants.colId} != ?';
      args.add(excludeId);
    }

    final result = await db.rawQuery(query, args);
    return _extractCount(result) == 0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET BOOKED TIME SLOTS FOR A DATE
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<String>> getBookedTimeSlots(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = DateTime(date.year, date.month, date.day)
        .toIso8601String()
        .split('T')[0];

    final maps = await db.query(
      DbConstants.tableAppointments,
      columns: [DbConstants.colStartTime],
      where: "${DbConstants.colAppointmentDate} LIKE ? AND ${DbConstants.colStatus} NOT IN ('cancelled')",
      whereArgs: ['$dateStr%'],
    );

    return maps.map((map) => map[DbConstants.colStartTime] as String).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET UNSYNCED APPOINTMENTS
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<AppointmentModel>> getUnsyncedAppointments() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DbConstants.tableAppointments,
      where: '${DbConstants.colIsSynced} = ?',
      whereArgs: [0],
    );

    return _populateServiceIds(maps);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MARK AS SYNCED
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> markAsSynced(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      DbConstants.tableAppointments,
      {DbConstants.colIsSynced: 1},
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }
}