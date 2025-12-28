// // lib/features/appointment/model/appointment_model.dart

// import 'dart:convert';

// enum AppointmentStatus { 
//   scheduled, 
//   confirmed, 
//   inProgress, 
//   completed, 
//   cancelled 
// }

// class AppointmentModel {
//   final String id;
//   final String customerName;
//   final String customerPhone;
//   final String serviceId;
//   final String serviceName;
//   final DateTime appointmentDate;
//   final String startTime;
//   final String endTime;
//   final int durationMinutes;
//   final double price;
//   final AppointmentStatus status;
//   final String? notes;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final bool isSynced;

//   AppointmentModel({
//     required this.id,
//     required this.customerName,
//     required this.customerPhone,
//     required this.serviceId,
//     required this.serviceName,
//     required this.appointmentDate,
//     required this.startTime,
//     required this.endTime,
//     required this.durationMinutes,
//     required this.price,
//     required this.status,
//     this.notes,
//     required this.createdAt,
//     required this.updatedAt,
//     this.isSynced = false,
//   });

//   // ─────────────────────────────────────────────────────────────────────────
//   // STATUS HELPERS
//   // ─────────────────────────────────────────────────────────────────────────
//   bool get isScheduled => status == AppointmentStatus.scheduled;
//   bool get isConfirmed => status == AppointmentStatus.confirmed;
//   bool get isInProgress => status == AppointmentStatus.inProgress;
//   bool get isCompleted => status == AppointmentStatus.completed;
//   bool get isCancelled => status == AppointmentStatus.cancelled;

//   String get statusText {
//     switch (status) {
//       case AppointmentStatus.scheduled:
//         return 'Scheduled';
//       case AppointmentStatus.confirmed:
//         return 'Confirmed';
//       case AppointmentStatus.inProgress:
//         return 'In Progress';
//       case AppointmentStatus.completed:
//         return 'Completed';
//       case AppointmentStatus.cancelled:
//         return 'Cancelled';
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // DATE/TIME HELPERS
//   // ─────────────────────────────────────────────────────────────────────────
//   String get formattedDate {
//     final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
//                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return '${months[appointmentDate.month - 1]} ${appointmentDate.day}, ${appointmentDate.year}';
//   }

//   String get dayOfWeek {
//     final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 
//                   'Friday', 'Saturday', 'Sunday'];
//     return days[appointmentDate.weekday - 1];
//   }

//   bool get isToday {
//     final now = DateTime.now();
//     return appointmentDate.year == now.year &&
//            appointmentDate.month == now.month &&
//            appointmentDate.day == now.day;
//   }

//   bool get isPast {
//     return appointmentDate.isBefore(DateTime.now());
//   }

//   bool get isUpcoming {
//     return appointmentDate.isAfter(DateTime.now()) && 
//            (isScheduled || isConfirmed);
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // FROM MAP (SQLite)
//   // ─────────────────────────────────────────────────────────────────────────
//   factory AppointmentModel.fromMap(Map<String, dynamic> map) {
//     return AppointmentModel(
//       id: map['id'] as String,
//       customerName: map['customerName'] as String,
//       customerPhone: map['customerPhone'] as String,
//       serviceId: map['serviceId'] as String,
//       serviceName: map['serviceName'] as String,
//       appointmentDate: DateTime.parse(map['appointmentDate'] as String),
//       startTime: map['startTime'] as String,
//       endTime: map['endTime'] as String,
//       durationMinutes: map['durationMinutes'] as int,
//       price: (map['price'] as num).toDouble(),
//       status: AppointmentStatus.values.firstWhere(
//         (e) => e.name == map['status'],
//         orElse: () => AppointmentStatus.scheduled,
//       ),
//       notes: map['notes'] as String?,
//       createdAt: DateTime.parse(map['createdAt'] as String),
//       updatedAt: DateTime.parse(map['updatedAt'] as String),
//       isSynced: (map['isSynced'] as int) == 1,
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // TO MAP (SQLite)
//   // ─────────────────────────────────────────────────────────────────────────
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'customerName': customerName,
//       'customerPhone': customerPhone,
//       'serviceId': serviceId,
//       'serviceName': serviceName,
//       'appointmentDate': appointmentDate.toIso8601String(),
//       'startTime': startTime,
//       'endTime': endTime,
//       'durationMinutes': durationMinutes,
//       'price': price,
//       'status': status.name,
//       'notes': notes,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//       'isSynced': isSynced ? 1 : 0,
//     };
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // COPY WITH
//   // ─────────────────────────────────────────────────────────────────────────
//   AppointmentModel copyWith({
//     String? id,
//     String? customerName,
//     String? customerPhone,
//     String? serviceId,
//     String? serviceName,
//     DateTime? appointmentDate,
//     String? startTime,
//     String? endTime,
//     int? durationMinutes,
//     double? price,
//     AppointmentStatus? status,
//     String? notes,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     bool? isSynced,
//   }) {
//     return AppointmentModel(
//       id: id ?? this.id,
//       customerName: customerName ?? this.customerName,
//       customerPhone: customerPhone ?? this.customerPhone,
//       serviceId: serviceId ?? this.serviceId,
//       serviceName: serviceName ?? this.serviceName,
//       appointmentDate: appointmentDate ?? this.appointmentDate,
//       startTime: startTime ?? this.startTime,
//       endTime: endTime ?? this.endTime,
//       durationMinutes: durationMinutes ?? this.durationMinutes,
//       price: price ?? this.price,
//       status: status ?? this.status,
//       notes: notes ?? this.notes,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? DateTime.now(),
//       isSynced: isSynced ?? this.isSynced,
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // JSON SUPPORT
//   // ─────────────────────────────────────────────────────────────────────────
//   factory AppointmentModel.fromJson(String source) =>
//       AppointmentModel.fromMap(json.decode(source));

//   String toJson() => json.encode(toMap());

//   @override
//   String toString() {
//     return 'AppointmentModel(id: $id, customer: $customerName, service: $serviceName, date: $formattedDate, time: $startTime, status: $statusText)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is AppointmentModel && other.id == id;
//   }

//   @override
//   int get hashCode => id.hashCode;
// }
// lib/features/appointment/model/appointment_model.dart

// lib/models/appointment_model.dart

import 'dart:convert';

enum AppointmentStatus { 
  scheduled, 
  confirmed, 
  inProgress, 
  completed, 
  cancelled 
}

class AppointmentModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final List<String> serviceIds;
  final String serviceName; // Computed/stored display name
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final double price;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  AppointmentModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceIds,
    required this.serviceName,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.price,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // STATUS HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  bool get isScheduled => status == AppointmentStatus.scheduled;
  bool get isConfirmed => status == AppointmentStatus.confirmed;
  bool get isInProgress => status == AppointmentStatus.inProgress;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;

  String get statusText {
    switch (status) {
      case AppointmentStatus.scheduled: return 'Scheduled';
      case AppointmentStatus.confirmed: return 'Confirmed';
      case AppointmentStatus.inProgress: return 'In Progress';
      case AppointmentStatus.completed: return 'Completed';
      case AppointmentStatus.cancelled: return 'Cancelled';
    }
  }

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[appointmentDate.month - 1]} ${appointmentDate.day}, ${appointmentDate.year}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FROM MAP (SQLite → Model)
  // serviceIds comes from junction table query separately
  // ─────────────────────────────────────────────────────────────────────────
  factory AppointmentModel.fromMap(
    Map<String, dynamic> map, {
    List<String>? serviceIds,
    String? serviceName,
  }) {
    return AppointmentModel(
      id: map['id'] as String,
      customerName: map['customerName'] as String,
      customerPhone: map['customerPhone'] as String,
      serviceIds: serviceIds ?? [],
      serviceName: serviceName ?? map['serviceName'] as String? ?? '',
      appointmentDate: DateTime.parse(map['appointmentDate'] as String),
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      durationMinutes: map['durationMinutes'] as int,
      price: (map['price'] as num).toDouble(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isSynced: (map['isSynced'] as int?) == 1,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TO MAP (Model → SQLite)
  // Note: serviceIds are stored in junction table, not here
  // ─────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      // serviceName stored for quick display without joins
      'serviceName': serviceName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'durationMinutes': durationMinutes,
      'price': price,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COPY WITH
  // ─────────────────────────────────────────────────────────────────────────
  AppointmentModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    List<String>? serviceIds,
    String? serviceName,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    int? durationMinutes,
    double? price,
    AppointmentStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceIds: serviceIds ?? List.from(this.serviceIds),
      serviceName: serviceName ?? this.serviceName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? this.isSynced,
    );
  }
}