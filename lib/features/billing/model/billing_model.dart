// lib/features/billing/model/billing_model.dart

import 'package:uuid/uuid.dart';

enum BillStatus { draft, finalized, paid, cancelled }
enum PaymentMethod { cash, card, upi, other }

class BillItemModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final int durationMinutes;
  final double price;
  final int quantity;

  BillItemModel({
    String? id,
    required this.serviceId,
    required this.serviceName,
    required this.durationMinutes,
    required this.price,
    this.quantity = 1,
  }) : id = id ?? const Uuid().v4();

  double get totalPrice => price * quantity;

  BillItemModel copyWith({int? quantity}) {
    return BillItemModel(
      id: id,
      serviceId: serviceId,
      serviceName: serviceName,
      durationMinutes: durationMinutes,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}

class BillModel {
  final String id;
  final String? customerName;
  final String? customerPhone;
  final List<BillItemModel> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discountAmount;
  final double total;
  final BillStatus status;
  final PaymentMethod? paymentMethod;
  final DateTime createdAt;

  BillModel({
    String? id,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    this.taxRate = 0.08,
    required this.taxAmount,
    this.discountAmount = 0.0,
    required this.total,
    this.status = BillStatus.draft,
    this.paymentMethod,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  String get statusText {
    switch (status) {
      case BillStatus.draft: return 'Draft';
      case BillStatus.finalized: return 'Finalized';
      case BillStatus.paid: return 'Paid';
      case BillStatus.cancelled: return 'Cancelled';
    }
  }
}