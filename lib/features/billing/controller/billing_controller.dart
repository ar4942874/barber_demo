// lib/features/billing/controller/billing_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../appointment/controller/appointment_controller.dart';
import '../../appointment/model/appointment_model.dart';
import '../../services/model/service_model.dart';
import '../model/billing_model.dart';
import '../repository/billing_repository.dart';

/// Provider for the BillingController.
/// It now depends on the repository and another controller.
final billingControllerProvider = StateNotifierProvider<BillingController, BillingState>((ref) {
  return BillingController(
    ref.watch(billingRepositoryProvider),
    ref.watch(appointmentControllerProvider.notifier),
  );
});


class BillingController extends StateNotifier<BillingState> {
  final BillingRepository _billingRepository;
  final AppointmentController _appointmentController;

  BillingController(this._billingRepository, this._appointmentController) : super(BillingState());

  // --- Customer Info Methods ---
  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void setCustomerPhone(String phone) {
    state = state.copyWith(customerPhone: phone);
  }

  // --- Item Management Methods ---
  void addService(ServiceModel service) {
    final existingIndex = state.items.indexWhere((item) => item.serviceId == service.id);

    if (existingIndex != -1) {
      // If service already exists, just increase its quantity
      final updatedItems = List<BillItemModel>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Add a new item from the service model
      final newItem = BillItemModel.fromService(service);
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

  /// Clears the current bill from the UI, ready for a new transaction.
  void clearBill() {
    state = BillingState();
  }

  // --- Workflow Methods ---

  /// Pre-fills the billing UI state from a given appointment.
  /// This is called before navigating to the billing screen.
  void populateBillFromAppointment(
    AppointmentModel appointment,
    List<ServiceModel> appointmentServices,
  ) {
    clearBill(); // Start with a fresh state

    // Set customer details from the appointment
    setCustomerName(appointment.customerName);
    setCustomerPhone(appointment.customerPhone);

    // Add all services from the appointment
    for (final service in appointmentServices) {
      addService(service);
    }

    // IMPORTANT: Link this bill state to the appointment ID
    state = state.copyWith(linkedAppointmentId: appointment.id);
  }

  /// Finalizes the current bill, saves it to the database, and updates
  /// the linked appointment's status if applicable.
  Future<void> finalizeBill(PaymentMethod method) async {
    if (!state.hasItems) {
      throw Exception("Cannot finalize an empty bill.");
    }
    
    try {
      // 1. Construct the persistent BillModel from the current UI state.
      final billToSave = BillModel(
        id: const Uuid().v4(),
        billNumber: await _billingRepository.getNextBillNumber(),
        appointmentId: state.linkedAppointmentId,
        customerName: state.customerName,
        customerPhone: state.customerPhone,
        subtotal: state.subtotal,
        taxAmount: state.taxAmount,
        discountAmount: state.discountAmount,
        total: state.total,
        paymentMethod: method,
        createdAt: DateTime.now(),
        items: state.items,
      );

      // 2. Save the bill to the database via the repository.
      await _billingRepository.saveBill(billToSave);

      // 3. If this bill was from an appointment, update the appointment's status.
      if (billToSave.appointmentId != null) {
        await _appointmentController.updateStatus(
          billToSave.appointmentId!,
          AppointmentStatus.completed,
        );
      }
      
      // 4. Clear the UI for the next transaction.
      clearBill();

    } catch (e) {
      // Rethrow the exception to be caught and displayed by the UI.
      
      rethrow;
    }
  }
 
}