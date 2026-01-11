// lib/features/billing/view/walk_in_billing_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../services/controller/service_controller.dart';
import '../../services/model/service_model.dart';
import '../controller/billing_controller.dart';
import '../model/billing_model.dart';

// ===========================================================================
// MAIN SCREEN WIDGET
// ===========================================================================

class WalkInBillingScreen extends ConsumerWidget {
  const WalkInBillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingState = ref.watch(billingControllerProvider);
    final servicesAsync = ref.watch(serviceControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    // The main build method is now very clean and easy to read.
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: _BillingAppBar(billingState),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(isDesktop ? 32 : 20),
            child: isDesktop
                ? _DesktopLayout(billingState: billingState, servicesAsync: servicesAsync)
                : _MobileLayout(billingState: billingState, servicesAsync: servicesAsync),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// LAYOUT WIDGETS
// ===========================================================================

class _DesktopLayout extends StatelessWidget {
  final BillingState billingState;
  final AsyncValue<List<ServiceModel>> servicesAsync;

  const _DesktopLayout({required this.billingState, required this.servicesAsync});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 3,
          child: Column(
            children: [
              _CustomerDetailsCard(),
              SizedBox(height: 24),
              _ServicesCard(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _BillingCartCard(billingState: billingState),
              const SizedBox(height: 24),
              _SummaryCard(billingState: billingState),
              const SizedBox(height: 24),
              const _ActionButtons(),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final BillingState billingState;
  final AsyncValue<List<ServiceModel>> servicesAsync;

  const _MobileLayout({required this.billingState, required this.servicesAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _CustomerDetailsCard(),
        const SizedBox(height: 20),
        const _ServicesCard(),
        const SizedBox(height: 20),
        _BillingCartCard(billingState: billingState),
        const SizedBox(height: 20),
        _SummaryCard(billingState: billingState),
        const SizedBox(height: 20),
        const _ActionButtons(),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ===========================================================================
// AppBar WIDGET
// ===========================================================================

class _BillingAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final BillingState billingState;

  const _BillingAppBar(this.billingState);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFromAppointment = billingState.linkedAppointmentId != null;

    return AppBar(
      backgroundColor: AppTheme.cardDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textGrey, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isFromAppointment ? 'Finalize Appointment Bill' : 'Walk-in Billing',
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            billingState.hasItems
                ? '${billingState.itemCount} item${billingState.itemCount > 1 ? 's' : ''} added'
                : 'Create a new invoice',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        if (billingState.hasItems)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () {
                ref.read(billingControllerProvider.notifier).clearBill();
              },
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 18),
              label: const Text('Clear', style: TextStyle(color: AppTheme.error)),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


// ===========================================================================
// CUSTOMER DETAILS CARD WIDGET
// ===========================================================================

class _CustomerDetailsCard extends ConsumerStatefulWidget {
  const _CustomerDetailsCard();

  @override
  ConsumerState<_CustomerDetailsCard> createState() => __CustomerDetailsCardState();
}

class __CustomerDetailsCardState extends ConsumerState<_CustomerDetailsCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    // Initialize controllers from Riverpod state
    final initialState = ref.read(billingControllerProvider);
    _nameController.text = initialState.customerName ?? '';
    _phoneController.text = initialState.customerPhone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to Riverpod state and update local controllers if they differ
    ref.listen<BillingState>(billingControllerProvider, (previous, next) {
      if (next.customerName != _nameController.text) {
        _nameController.text = next.customerName ?? '';
      }
      if (next.customerPhone != _phoneController.text) {
        _phoneController.text = next.customerPhone ?? '';
      }
    });

    final billingState = ref.watch(billingControllerProvider);
    final isFromAppointment = billingState.linkedAppointmentId != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.whiteGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded, color: AppTheme.blue, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Details', style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    isFromAppointment ? 'From booked appointment' : 'Optional - for invoice',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          _CustomTextField(
            controller: _nameController,
            label: 'CUSTOMER NAME',
            hintText: 'Enter customer name',
            prefixIcon: Icons.badge_outlined,
            enabled: !isFromAppointment,
            onChanged: (value) => ref.read(billingControllerProvider.notifier).setCustomerName(value),
          ),
          const SizedBox(height: 20),
          _CustomTextField(
            controller: _phoneController,
            label: 'PHONE NUMBER',
            hintText: 'Enter phone number',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            enabled: !isFromAppointment,
            onChanged: (value) => ref.read(billingControllerProvider.notifier).setCustomerPhone(value),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// SERVICES CARD WIDGET
// ===========================================================================

class _ServicesCard extends ConsumerStatefulWidget {
  const _ServicesCard();

  @override
  ConsumerState<_ServicesCard> createState() => __ServicesCardState();
}

class __ServicesCardState extends ConsumerState<_ServicesCard> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddedFeedback(String name) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20), const SizedBox(width: 12), Text('$name added')]),
        backgroundColor: AppTheme.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(serviceControllerProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.whiteGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.purple.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.content_cut_rounded, color: AppTheme.purple, size: 22)),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Select Services', style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)), Text('Tap to add to bill', style: TextStyle(color: AppTheme.textMuted, fontSize: 12))])),
            ],
          ),
          const SizedBox(height: 24),
          _CustomTextField(
            controller: _searchController,
            label: 'SEARCH SERVICES',
            hintText: 'Search services...',
            prefixIcon: Icons.search_rounded,
            onChanged: (value) => setState(() => _searchQuery = value),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          const SizedBox(height: 20),
          servicesAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2))),
            error: (e, _) => const _ErrorState('Failed to load services'),
            data: (services) {
              final activeServices = services.where((s) => s.isActive).toList();
              final filteredServices = _searchQuery.isEmpty ? activeServices : activeServices.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              if (filteredServices.isEmpty) {
                return _EmptyState(icon: Icons.search_off_rounded, message: _searchQuery.isEmpty ? 'No services available' : 'No services found');
              }
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: filteredServices.map((service) => _ServiceCard(
                  service: service,
                  onTap: () {
                    ref.read(billingControllerProvider.notifier).addService(service);
                    HapticFeedback.lightImpact();
                    _showAddedFeedback(service.name);
                  },
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// BILLING CART CARD WIDGET
// ===========================================================================

class _BillingCartCard extends ConsumerWidget {
  final BillingState billingState;

  const _BillingCartCard({required this.billingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: billingState.hasItems ? AppTheme.accent.withOpacity(0.3) : AppTheme.border),
        boxShadow: AppTheme.whiteGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.shopping_bag_rounded, color: AppTheme.accent, size: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Cart', style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(billingState.hasItems ? '${billingState.totalDuration} min total' : 'No items yet', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (billingState.hasItems)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(20)),
                  child: Text('${billingState.itemCount}', style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (!billingState.hasItems)
            const _EmptyState(icon: Icons.add_shopping_cart_rounded, message: 'Add services to begin')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: billingState.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = billingState.items[index];
                return _CartItemTile(
                  item: item,
                  onRemove: () {
                    ref.read(billingControllerProvider.notifier).removeService(item.id);
                    HapticFeedback.lightImpact();
                  },
                  onQuantityChanged: (qty) {
                    ref.read(billingControllerProvider.notifier).updateQuantity(item.id, qty);
                    HapticFeedback.selectionClick();
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// SUMMARY CARD WIDGET
// ===========================================================================

class _SummaryCard extends StatelessWidget {
  final BillingState billingState;

  const _SummaryCard({required this.billingState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.goldGlowShadow),
      child: Column(
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.receipt_long_rounded, color: Colors.black, size: 22)), const SizedBox(width: 12), const Text('Bill Summary', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 24),
          _SummaryRow(label: 'Subtotal', value: '\$${billingState.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Tax (${(billingState.taxRate * 100).toInt()}%)', value: '\$${billingState.taxAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Discount', value: '-\$${billingState.discountAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.black.withOpacity(0.15)),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Total Amount', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)), Text('Including tax', style: TextStyle(color: Colors.black54, fontSize: 11))]),
              Text('\$${billingState.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// ACTION BUTTONS WIDGET
// ===========================================================================

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons();

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20), const SizedBox(width: 12), Text(message)]), backgroundColor: AppTheme.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20), const SizedBox(width: 12), Expanded(child: Text(message))]), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref, BillingState billingState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PaymentSheet(
        total: billingState.total,
        onPaymentSelected: (method) async {
          Navigator.pop(context);
          try {
            await ref.read(billingControllerProvider.notifier).finalizeBill(method);
            _showSuccessSnackbar(context, 'Bill finalized and saved successfully!');
          } catch (e) {
            _showErrorSnackbar(context, 'Failed to save bill: ${e.toString()}');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingState = ref.watch(billingControllerProvider);
    final isValid = billingState.hasItems;

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isValid ? () => _showPaymentDialog(context, ref, billingState) : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: isValid ? AppTheme.goldGradient : null,
                  color: isValid ? null : AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isValid ? AppTheme.goldGlowShadow : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: isValid ? Colors.black : AppTheme.textMuted, size: 20),
                    const SizedBox(width: 8),
                    Text('Finalize Bill', style: TextStyle(color: isValid ? Colors.black : AppTheme.textMuted, fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


// ===========================================================================
// SHARED HELPER WIDGETS
// ===========================================================================

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(color: enabled ? AppTheme.textWhite : AppTheme.textMuted, fontSize: 15, fontWeight: FontWeight.w500),
          cursorColor: AppTheme.accent,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppTheme.inputBg : AppTheme.cardDark,
            hintText: hintText,
            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w400),
            prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Icon(prefixIcon, color: AppTheme.textMuted, size: 22)),
            prefixIconConstraints: const BoxConstraints(minWidth: 56),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border, width: 1)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border, width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.accent, width: 2)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border, width: 1)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.error, width: 1)),
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;
  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.inputBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_rounded, color: AppTheme.green, size: 18)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(service.name, style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w600)), Text('${service.durationMinutes} min', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11))]), const SizedBox(width: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Text('\$${service.price.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.bold)))]))));
}

class _CartItemTile extends StatelessWidget {
  final BillItemModel item;
  final VoidCallback onRemove;
  final void Function(int) onQuantityChanged;
  const _CartItemTile({required this.item, required this.onRemove, required this.onQuantityChanged});

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.inputBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.serviceName, style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text('${item.durationMinutes} min • \$${item.price.toStringAsFixed(0)} each', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11))])), Container(decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(10)), child: Row(children: [Material(color: Colors.transparent, child: InkWell(onTap: () => onQuantityChanged(item.quantity - 1), borderRadius: BorderRadius.circular(8), child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.remove_rounded, color: AppTheme.textGrey, size: 18)))), Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('${item.quantity}', style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 14))), Material(color: Colors.transparent, child: InkWell(onTap: () => onQuantityChanged(item.quantity + 1), borderRadius: BorderRadius.circular(8), child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.add_rounded, color: AppTheme.accent, size: 18))))])), const SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('\$${item.totalPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Material(color: Colors.transparent, child: InkWell(onTap: onRemove, child: const Text('Remove', style: TextStyle(color: AppTheme.error, fontSize: 11, fontWeight: FontWeight.w500))))])]));
}

class _PaymentSheet extends StatelessWidget {
  final double total;
  final void Function(PaymentMethod) onPaymentSelected;
  const _PaymentSheet({required this.total, required this.onPaymentSelected});

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(28), decoration: const BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.vertical(top: Radius.circular(28))), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 50, height: 5, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(10))), const SizedBox(height: 28), Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: AppTheme.goldGradient, shape: BoxShape.circle, boxShadow: AppTheme.goldGlowShadow), child: const Icon(Icons.payment_rounded, color: Colors.black, size: 36)), const SizedBox(height: 20), const Text('Select Payment Method', style: TextStyle(color: AppTheme.textWhite, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.accent, fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 32), _PaymentOption(icon: Icons.money_rounded, label: 'Cash', color: AppTheme.green, onTap: () => onPaymentSelected(PaymentMethod.cash)), const SizedBox(height: 14), _PaymentOption(icon: Icons.credit_card_rounded, label: 'Card', color: AppTheme.blue, onTap: () => onPaymentSelected(PaymentMethod.card)), const SizedBox(height: 14), _PaymentOption(icon: Icons.qr_code_scanner_rounded, label: 'UPI / QR Code', color: AppTheme.purple, onTap: () => onPaymentSelected(PaymentMethod.upi)), const SizedBox(height: 28), TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted, fontSize: 15))), SizedBox(height: MediaQuery.of(context).padding.bottom + 10)]));
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PaymentOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), decoration: BoxDecoration(color: AppTheme.inputBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 24)), const SizedBox(width: 16), Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600))), Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.7))]))));
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40), child: Column(children: [Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 36, color: AppTheme.accent.withOpacity(0.5))), const SizedBox(height: 14), Text(message, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14))]));
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState(this.message);
  
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline_rounded, color: AppTheme.error), const SizedBox(width: 12), Text(message, style: const TextStyle(color: AppTheme.error))]));
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)), Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600))]);
}