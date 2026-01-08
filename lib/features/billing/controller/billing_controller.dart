// lib/features/billing/controller/billing_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/billing_model.dart';
import '../../services/model/service_model.dart';

class BillingState {
  final String customerName;
  final String customerPhone;
  final List<BillItemModel> items;
  final double taxRate;
  final double discountAmount;
  final bool isLoading;

  const BillingState({
    this.customerName = '',
    this.customerPhone = '',
    this.items = const [],
    this.taxRate = 0.08,
    this.discountAmount = 0.0,
    this.isLoading = false,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get taxAmount => subtotal * taxRate;
  double get total => subtotal + taxAmount - discountAmount;
  int get totalDuration => items.fold(0, (sum, item) => sum + item.durationMinutes * item.quantity);
  bool get hasItems => items.isNotEmpty;
  bool get hasCustomer => customerName.isNotEmpty;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  BillingState copyWith({
    String? customerName,
    String? customerPhone,
    List<BillItemModel>? items,
    double? taxRate,
    double? discountAmount,
    bool? isLoading,
  }) {
    return BillingState(
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      taxRate: taxRate ?? this.taxRate,
      discountAmount: discountAmount ?? this.discountAmount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BillingController extends StateNotifier<BillingState> {
  BillingController() : super(const BillingState());

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void setCustomerPhone(String phone) {
    state = state.copyWith(customerPhone: phone);
  }

  void addService(ServiceModel service) {
    final existingIndex = state.items.indexWhere((item) => item.serviceId == service.id);

    if (existingIndex != -1) {
      final updatedItems = List<BillItemModel>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      final newItem = BillItemModel(
        serviceId: service.id,
        serviceName: service.name,
        durationMinutes: service.durationMinutes,
        price: service.price,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void removeService(String itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeService(itemId);
      return;
    }
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == itemId) return item.copyWith(quantity: quantity);
        return item;
      }).toList(),
    );
  }

  void setDiscount(double amount) {
    state = state.copyWith(discountAmount: amount);
  }

  Future<void> saveAsDraft() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false);
  }

  Future<void> finalizeBill(PaymentMethod method) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false);
  }

  void clearBill() {
    state = const BillingState();
  }
}

final billingControllerProvider = StateNotifierProvider<BillingController, BillingState>((ref) {
  return BillingController();
});