// lib/features/billing/model/billing_model.dart

import 'package:uuid/uuid.dart';
import '../../../core/constants/db_constants.dart';
import '../../services/model/service_model.dart';

// Enums remain the same
enum PaymentMethod { cash, card, upi, other }

// ✨ RENAMED & REFACTORED: This is the ephemeral UI state for the billing screen.
class BillingState {
  final String? customerName;
  final String? customerPhone;
  final List<BillItemModel> items;
  final double taxRate;
  
  // ✨ NEW: To link a bill back to an appointment
  final String? linkedAppointmentId;

  // --- Calculated Properties ---
  bool get hasItems => items.isNotEmpty;
  int get itemCount => items.length;
  
  int get totalDuration => items.fold(0, (sum, item) => sum + (item.durationMinutes ?? 0) * item.quantity);
  
  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  
  double get discountAmount {
    // TODO: Implement discount logic later if needed
    return 0.0;
  }
  
  double get taxAmount => (subtotal - discountAmount) * taxRate;
  
  double get total => (subtotal - discountAmount) + taxAmount;

  BillingState({
    this.customerName,
    this.customerPhone,
    this.items = const [],
    this.taxRate = 0.05, // Example 5% tax
    this.linkedAppointmentId,
  });

  BillingState copyWith({
    String? customerName,
    String? customerPhone,
    List<BillItemModel>? items,
    String? linkedAppointmentId,
    bool clearLinkedAppointmentId = false, // Helper to nullify the ID
  }) {
    return BillingState(
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      taxRate: taxRate,
      linkedAppointmentId: clearLinkedAppointmentId ? null : linkedAppointmentId ?? this.linkedAppointmentId,
    );
  }
}


// ✨ NEW: This is the persistent INVOICE model that gets saved to the database.
class BillModel {
  final String id;
  final String billNumber;
  final String? appointmentId;
  final String? customerName;
  final String? customerPhone;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double total;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  
  // This is populated by the repository after fetching from two tables
  final List<BillItemModel> items;

  BillModel({
    required this.id,
    required this.billNumber,
    this.appointmentId,
    this.customerName,
    this.customerPhone,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      DbConstants.colId: id,
      DbConstants.colBillNumber: billNumber,
      DbConstants.colAppointmentId: appointmentId,
      DbConstants.colCustomerName: customerName,
      DbConstants.colCustomerPhone: customerPhone,
      DbConstants.colSubtotal: subtotal,
      DbConstants.colTaxAmount: taxAmount,
      DbConstants.colDiscountAmount: discountAmount,
      DbConstants.colTotal: total,
      DbConstants.colPaymentMethod: paymentMethod.name,
      DbConstants.colCreatedAt: createdAt.toIso8601String(),
      // 'status' is also in your DB schema, let's add it. Using a fixed 'Paid' for now.
      DbConstants.colStatus: 'Paid',
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map, {List<BillItemModel>? items}) {
    return BillModel(
      id: map[DbConstants.colId] as String,
      billNumber: map[DbConstants.colBillNumber] as String,
      appointmentId: map[DbConstants.colAppointmentId] as String?,
      customerName: map[DbConstants.colCustomerName] as String?,
      customerPhone: map[DbConstants.colCustomerPhone] as String?,
      subtotal: map[DbConstants.colSubtotal] as double,
      taxAmount: map[DbConstants.colTaxAmount] as double,
      discountAmount: map[DbConstants.colDiscountAmount] as double,
      total: map[DbConstants.colTotal] as double,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map[DbConstants.colPaymentMethod],
        orElse: () => PaymentMethod.other,
      ),
      createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
      items: items ?? [],
    );
  }
}


// ✨ UPDATED: Now works for both UI state and Database persistence.
class BillItemModel {
  final String id;
  final String? billId; // Foreign key to BillModel
  final String? serviceId; // Needed when creating from a service
  final String serviceName;
  final int? durationMinutes; // Needed when creating from a service
  final double price;
  final int quantity;

  BillItemModel({
    String? id,
    this.billId,
    this.serviceId,
    required this.serviceName,
    this.durationMinutes,
    required this.price,
    this.quantity = 1,
  }) : id = id ?? const Uuid().v4();

  double get totalPrice => price * quantity;

  // Helper to create an item from a service, used by the UI
  factory BillItemModel.fromService(ServiceModel service) {
    return BillItemModel(
      serviceId: service.id,
      serviceName: service.name,
      durationMinutes: service.durationMinutes,
      price: service.price,
      quantity: 1,
    );
  }

  // Maps to the `bill_items` table in the database
  Map<String, dynamic> toMap() {
    return {
      DbConstants.colId: id,
      DbConstants.colBillId: billId,
      DbConstants.colServiceName: serviceName,
      DbConstants.colPrice: price,
      DbConstants.colQuantity: quantity,
    };
  }

  // Creates an item from a database record
  factory BillItemModel.fromMap(Map<String, dynamic> map) {
    return BillItemModel(
      id: map[DbConstants.colId] as String,
      billId: map[DbConstants.colBillId] as String,
      serviceName: map[DbConstants.colServiceName] as String,
      price: map[DbConstants.colPrice] as double,
      quantity: map[DbConstants.colQuantity] as int,
      // serviceId and durationMinutes are null because they are not stored in bill_items table
    );
  }

  BillItemModel copyWith({int? quantity, String? billId}) {
    return BillItemModel(
      id: id,
      billId: billId ?? this.billId,
      serviceId: serviceId,
      serviceName: serviceName,
      durationMinutes: durationMinutes,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}