// lib/core/database/database_helper.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/db_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDB(DbConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docDir.path, 'BarberApp', fileName);
    
    final dbDir = Directory(p.dirname(dbPath));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    return await openDatabase(
      dbPath,
      version: DbConstants.databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createServicesTable(db);
    await _createAppointmentsTable(db);
    await _createAppointmentServicesTable(db);
    print("✅ Database created with version $version");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("⚠️ Upgrading Database from $oldVersion to $newVersion");
    
    // Upgrade v1 -> v2 (Add Appointments)
    if (oldVersion < 2) {
      await _createAppointmentsTable(db); // Old schema with serviceId
    }

    // Upgrade v2 -> v3 (Multi-service support)
    if (oldVersion < 3) {
      await db.transaction((txn) async {
        // 1. Rename existing appointments table
        await txn.execute('ALTER TABLE ${DbConstants.tableAppointments} RENAME TO appointments_old');

        // 2. Create new tables
        await _createAppointmentsTable(txn); // New schema without serviceId
        await _createAppointmentServicesTable(txn);

        // 3. Migrate data
        // We need to check if 'appointments_old' actually has data before querying
        try {
          final oldData = await txn.query('appointments_old');
          
          for (final row in oldData) {
            // Insert into new appointments table (map old columns to new)
            await txn.insert(DbConstants.tableAppointments, {
              DbConstants.colId: row[DbConstants.colId],
              DbConstants.colCustomerName: row[DbConstants.colCustomerName],
              DbConstants.colCustomerPhone: row[DbConstants.colCustomerPhone],
              DbConstants.colAppointmentDate: row[DbConstants.colAppointmentDate],
              DbConstants.colStartTime: row[DbConstants.colStartTime],
              DbConstants.colEndTime: row[DbConstants.colEndTime],
              DbConstants.colDurationMinutes: row[DbConstants.colDurationMinutes],
              DbConstants.colPrice: row[DbConstants.colPrice],
              DbConstants.colStatus: row[DbConstants.colStatus],
              DbConstants.colNotes: row[DbConstants.colNotes],
              DbConstants.colCreatedAt: row[DbConstants.colCreatedAt],
              DbConstants.colUpdatedAt: row[DbConstants.colUpdatedAt],
              DbConstants.colIsSynced: row[DbConstants.colIsSynced],
            });

            // Migrate the single service ID to the junction table
            if (row['serviceId'] != null) {
              await txn.insert(DbConstants.tableAppointmentServices, {
                DbConstants.colApptId: row[DbConstants.colId],
                DbConstants.colSvcId: row['serviceId'],
              });
            }
          }

          // 4. Drop old table
          await txn.execute('DROP TABLE appointments_old');
          print("✅ Successfully migrated appointments to version 3");
          
        } catch (e) {
          print("⚠️ Migration warning: $e");
          // If table didn't exist or empty, just proceed
        }
      });
    }
  }

  // 1. Services Table
  Future<void> _createServicesTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableServices} ( 
        ${DbConstants.colId} TEXT PRIMARY KEY, 
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colDescription} TEXT,
        ${DbConstants.colPrice} REAL NOT NULL,
        ${DbConstants.colDurationMinutes} INTEGER NOT NULL,
        ${DbConstants.colIsActive} INTEGER NOT NULL DEFAULT 1,
        ${DbConstants.colIsSynced} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.colLastUpdated} TEXT NOT NULL
      )
    ''');
  }

  // 2. Appointments Table (Updated Schema)
Future<void> _createAppointmentsTable(DatabaseExecutor db) async {
  await db.execute('''
    CREATE TABLE ${DbConstants.tableAppointments} (
      ${DbConstants.colId} TEXT PRIMARY KEY,
      ${DbConstants.colCustomerName} TEXT NOT NULL,
      ${DbConstants.colCustomerPhone} TEXT NOT NULL,
      serviceName TEXT DEFAULT '',
      ${DbConstants.colAppointmentDate} TEXT NOT NULL,
      ${DbConstants.colStartTime} TEXT NOT NULL,
      ${DbConstants.colEndTime} TEXT NOT NULL,
      ${DbConstants.colDurationMinutes} INTEGER NOT NULL,
      ${DbConstants.colPrice} REAL NOT NULL,
      ${DbConstants.colStatus} TEXT NOT NULL DEFAULT 'scheduled',
      ${DbConstants.colNotes} TEXT,
      ${DbConstants.colCreatedAt} TEXT NOT NULL,
      ${DbConstants.colUpdatedAt} TEXT NOT NULL,
      ${DbConstants.colIsSynced} INTEGER NOT NULL DEFAULT 0
    )
  ''');
  
  // Indexes
  await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_appt_date 
    ON ${DbConstants.tableAppointments}(${DbConstants.colAppointmentDate})
  ''');
  
  await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_appt_status 
    ON ${DbConstants.tableAppointments}(${DbConstants.colStatus})
  ''');
}

  // 3. Appointment-Services Junction Table (NEW)
  Future<void> _createAppointmentServicesTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableAppointmentServices} (
        ${DbConstants.colApptId} TEXT NOT NULL,
        ${DbConstants.colSvcId} TEXT NOT NULL,
        PRIMARY KEY (${DbConstants.colApptId}, ${DbConstants.colSvcId}),
        FOREIGN KEY (${DbConstants.colApptId}) 
          REFERENCES ${DbConstants.tableAppointments}(${DbConstants.colId}) 
          ON DELETE CASCADE,
        FOREIGN KEY (${DbConstants.colSvcId}) 
          REFERENCES ${DbConstants.tableServices}(${DbConstants.colId})
          ON DELETE CASCADE
      )
    ''');
  }

  // Helper: Reset DB (Dev Only)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableAppointmentServices}');
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableAppointments}');
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableServices}');
    
    await _onCreate(db, DbConstants.databaseVersion);
    print("🔄 Database reset complete");
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}