// lib/core/constants/db_constants.dart

class DbConstants {
  static const String databaseName = 'barber_shop.db';
  static const int databaseVersion = 4; // ⬅️ Bumped to 3 for multi-service support
  
  // Table Names
  static const String tableServices = 'services';
  static const String tableAppointments = 'appointments';
  static const String tableAppointmentServices = 'appointment_services'; // ⬅️ NEW Junction Table
  
  // Services Table Columns
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colDescription = 'description';
  static const String colPrice = 'price';
  static const String colDurationMinutes = 'durationMinutes';
  static const String colIsActive = 'isActive';
  static const String colIsSynced = 'isSynced';
  static const String colLastUpdated = 'lastUpdated';
  
  // Appointments Table Columns
  // Removed colServiceId & colServiceName as they are now in junction table
  static const String colCustomerName = 'customerName';
  static const String colCustomerPhone = 'customerPhone';
  static const String colAppointmentDate = 'appointmentDate';
  static const String colStartTime = 'startTime';
  static const String colEndTime = 'endTime';
  static const String colStatus = 'status';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'createdAt';
  static const String colUpdatedAt = 'updatedAt';
  
  // Appointment Services Junction Table Columns
  static const String colApptId = 'appointment_id';
  static const String colSvcId = 'service_id';
}