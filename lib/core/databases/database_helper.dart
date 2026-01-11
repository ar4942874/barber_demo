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

    // ✨ CHANGE: Bump the database version to 4 to trigger the upgrade
    // Make sure your DbConstants.databaseVersion is also set to 4
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
    
    // ✨ CHANGE: Create new billing tables on initial creation
    await _createBillsTable(db);
    await _createBillItemsTable(db);

    print("✅ Database created with version $version");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("⚠️ Upgrading Database from $oldVersion to $newVersion");
    
    if (oldVersion < 2) {
      await _createAppointmentsTable(db);
    }

    if (oldVersion < 3) {
      // Your existing migration from v2 to v3 is good. No changes needed here.
      await db.transaction((txn) async {
        try {
          await txn.execute('ALTER TABLE ${DbConstants.tableAppointments} RENAME TO appointments_old');
          await _createAppointmentsTable(txn);
          await _createAppointmentServicesTable(txn);
          final oldData = await txn.query('appointments_old');
          for (final row in oldData) {
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
            if (row['serviceId'] != null) {
              await txn.insert(DbConstants.tableAppointmentServices, {
                DbConstants.colApptId: row[DbConstants.colId],
                DbConstants.colSvcId: row['serviceId'],
              });
            }
          }
          await txn.execute('DROP TABLE appointments_old');
          print("✅ Successfully migrated appointments to version 3");
        } catch (e) {
          print("⚠️ Migration warning for v3: $e");
        }
      });
    }

    // ✨ CHANGE: Add the billing tables for users upgrading from older versions
    if (oldVersion < 4) {
      await _createBillsTable(db);
      await _createBillItemsTable(db);
      print("✅ Successfully upgraded database to version 4 with billing tables.");
    }
  }

  // 1. Services Table
  Future<void> _createServicesTable(DatabaseExecutor db) async {
    // No changes here
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

  // 2. Appointments Table
  Future<void> _createAppointmentsTable(DatabaseExecutor db) async {
    // No changes here
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
    await db.execute('CREATE INDEX IF NOT EXISTS idx_appt_date ON ${DbConstants.tableAppointments}(${DbConstants.colAppointmentDate})');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_appt_status ON ${DbConstants.tableAppointments}(${DbConstants.colStatus})');
  }

  // 3. Appointment-Services Junction Table
  Future<void> _createAppointmentServicesTable(DatabaseExecutor db) async {
    // No changes here
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

  // ✨ NEW: 4. Bills Table
  Future<void> _createBillsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableBills} (
        id TEXT PRIMARY KEY,
        billNumber TEXT NOT NULL UNIQUE,
        status TEXT NOT NULL,
        appointmentId TEXT,
        customerName TEXT,
        customerPhone TEXT,
        subtotal REAL NOT NULL,
        taxAmount REAL NOT NULL,
        discountAmount REAL NOT NULL,
        total REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (appointmentId) 
          REFERENCES ${DbConstants.tableAppointments}(id) 
          ON DELETE SET NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_bill_date ON ${DbConstants.tableBills}(createdAt)');
  }

  // ✨ NEW: 5. Bill Items Table
  Future<void> _createBillItemsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableBillItems} (
        id TEXT PRIMARY KEY,
        billId TEXT NOT NULL,
        serviceName TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (billId) 
          REFERENCES ${DbConstants.tableBills}(id) 
          ON DELETE CASCADE
      )
    ''');
  }

  // Helper: Reset DB (Dev Only)
  Future<void> resetDatabase() async {
    final db = await database;
    // ✨ CHANGE: Add new tables to the drop list
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableBillItems}');
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableBills}');
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableAppointmentServices}');
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableAppointments}');
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableServices}');
    
    await _onCreate(db, 4); // Use the new latest version
    print("🔄 Database reset complete");
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}