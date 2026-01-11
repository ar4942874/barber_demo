// lib/core/constants/db_constants.dart

class DbConstants {
  // ✅ Kept your version bump. This is correct.
  static const String databaseName = 'barber_shop.db';
  static const int databaseVersion = 5;
  
  // Table Names
  static const String tableServices = 'services';
  static const String tableAppointments = 'appointments';
  static const String tableAppointmentServices = 'appointment_services';
  
  // ✨ NEW: Table names for billing
  static const String tableBills = 'bills';
  static const String tableBillItems = 'bill_items';
  
  // --- Common Columns ---
  static const String colId = 'id';
  static const String colIsSynced = 'isSynced';

  // --- Services Table Columns ---
  static const String colName = 'name';
  static const String colDescription = 'description';
  static const String colPrice = 'price';
  static const String colDurationMinutes = 'durationMinutes';
  static const String colIsActive = 'isActive';
  static const String colLastUpdated = 'lastUpdated';
  
  // --- Appointments Table Columns ---
  static const String colCustomerName = 'customerName';
  static const String colCustomerPhone = 'customerPhone';
  static const String colAppointmentDate = 'appointmentDate';
  static const String colStartTime = 'startTime';
  static const String colEndTime = 'endTime';
  static const String colStatus = 'status';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'createdAt';
  static const String colUpdatedAt = 'updatedAt';
  
  // --- Appointment Services Junction Table Columns ---
  static const String colApptId = 'appointment_id';
  static const String colSvcId = 'service_id';

  // ✨ NEW: Bills Table Columns
  static const String colBillNumber = 'billNumber';
  static const String colAppointmentId = 'appointmentId';
  // Reuses colCustomerName, colCustomerPhone, colStatus, colCreatedAt from above
  static const String colSubtotal = 'subtotal';
  static const String colTaxAmount = 'taxAmount';
  static const String colDiscountAmount = 'discountAmount';
  static const String colTotal = 'total';
  static const String colPaymentMethod = 'paymentMethod';

  // ✨ NEW: Bill Items Table Columns
  static const String colBillId = 'billId';
  static const String colServiceName = 'serviceName';
  // Reuses colPrice from above
  static const String colQuantity = 'quantity';
}