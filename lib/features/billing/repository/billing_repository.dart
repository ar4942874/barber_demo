// lib/features/billing/repository/billing_repository.dart

import 'package:barber_demo/core/databases/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/constants/db_constants.dart';
import '../model/billing_model.dart';

/// Provider to make the BillingRepository available throughout the app
final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return BillingRepository(dbHelper);
});

// A provider for the DatabaseHelper itself
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});


class BillingRepository {
  final DatabaseHelper _dbHelper;

  BillingRepository(this._dbHelper);

  /// Saves a complete bill, including all its items, in a single transaction.
  Future<void> saveBill(BillModel bill) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1. Insert the main bill record.
      await txn.insert(
        DbConstants.tableBills,
        bill.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Insert each associated bill item.
      for (final item in bill.items) {
        // We create a copy of the item and assign the billId before saving.
        final itemToSave = item.copyWith(billId: bill.id);
        await txn.insert(
          DbConstants.tableBillItems,
          itemToSave.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Fetches all bills from the database, ordered from newest to oldest.
  /// For each bill, it also fetches its associated items.
  Future<List<BillModel>> getBills() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> billMaps = await db.query(
      DbConstants.tableBills,
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );

    if (billMaps.isEmpty) {
      return [];
    }

    final List<BillModel> bills = [];
    for (final billMap in billMaps) {
      // For each bill, fetch its items from the bill_items table.
      final List<Map<String, dynamic>> itemMaps = await db.query(
        DbConstants.tableBillItems,
        where: '${DbConstants.colBillId} = ?',
        whereArgs: [billMap[DbConstants.colId]],
      );

      final List<BillItemModel> items = itemMaps.map((itemMap) {
        return BillItemModel.fromMap(itemMap);
      }).toList();

      // Construct the full BillModel with its items.
      bills.add(BillModel.fromMap(billMap, items: items));
    }

    return bills;
  }
  
  /// Generates the next sequential bill number for the current year.
  /// Example: INV-2023-0001, INV-2023-0002, etc.
  Future<String> getNextBillNumber() async {
    final db = await _dbHelper.database;
    final year = DateTime.now().year;

    // Find the last bill from the current year
    final result = await db.query(
      DbConstants.tableBills,
      columns: [DbConstants.colBillNumber],
      where: "${DbConstants.colBillNumber} LIKE ?",
      whereArgs: ['INV-$year-%'],
      orderBy: '${DbConstants.colBillNumber} DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      // No bills this year, start from 1
      return 'INV-$year-0001';
    } else {
      // Get the number part of the last bill number and increment it
      final lastBillNumber = result.first[DbConstants.colBillNumber] as String;
      final parts = lastBillNumber.split('-');
      final lastNumber = int.tryParse(parts.last) ?? 0;
      final nextNumber = (lastNumber + 1).toString().padLeft(4, '0');
      return 'INV-$year-$nextNumber';
    }
  }
}