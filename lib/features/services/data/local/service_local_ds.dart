import 'package:barber_demo/core/databases/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../../core/constants/db_constants.dart';

import '../../model/service_model.dart';

class ServiceLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create
  Future<void> insertService(ServiceModel service) async {
    final db = await _dbHelper.database;
    await db.insert(
      DbConstants.tableServices,
      service.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read All (Only Active ones usually)
  Future<List<ServiceModel>> getAllServices() async {
    final db = await _dbHelper.database;
    // Order by name
    final result = await db.query(
      DbConstants.tableServices,
      where: 'isActive = ?',
      whereArgs: [1], 
      orderBy: 'name ASC',
    );
    return result.map((json) => ServiceModel.fromMap(json)).toList();
  }

  // Update
  Future<void> updateService(ServiceModel service) async {
    final db = await _dbHelper.database;
    await db.update(
      DbConstants.tableServices,
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  // Delete (Soft Delete)
  Future<void> deleteService(String id) async {
    final db = await _dbHelper.database;
    // We don't actually delete, we set isActive = 0
    await db.update(
      DbConstants.tableServices,
      {'isActive': 0, 'isSynced': 0, 'lastUpdated': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}