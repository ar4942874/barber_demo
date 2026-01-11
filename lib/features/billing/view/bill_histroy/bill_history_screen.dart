// lib/features/billing/view/bill_history/bill_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../controller/bill_history_controller.dart';
import '../../model/billing_model.dart';
// Note: You will need to create bill_detail_screen.dart in the next step.
// For now, the import might show an error, which is expected.
import 'bill_detail_screen.dart'; 

// ===========================================================================
// MAIN SCREEN WIDGET
// ===========================================================================

class BillHistoryScreen extends ConsumerWidget {
  const BillHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(billHistoryControllerProvider);
    final controller = ref.read(billHistoryControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const SizedBox(height: 16),
            _SearchBar(
              onChanged: (query) => controller.setSearchQuery(query),
            ),
            const SizedBox(height: 16),
            _FilterChips(
              activeFilter: state.activeFilter,
              onFilterSelected: (filter) => controller.setFilter(filter),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildBillList(state, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillList(BillHistoryState state, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }

    if (state.allBills.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'No Bills Yet',
        message: 'When you finalize a bill, it will appear here.',
      );
    }
    
    final filteredBills = state.filteredBills;

    if (filteredBills.isEmpty) {
      return const _EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Matching Bills',
        message: 'Try adjusting your search or filter.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(billHistoryControllerProvider.notifier).fetchBills(),
      color: AppTheme.accent,
      backgroundColor: AppTheme.cardDark,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: filteredBills.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bill = filteredBills[index];
          return _BillListItem(bill: bill);
        },
      ),
    );
  }
}


// ===========================================================================
// HEADER WIDGET
// ===========================================================================

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textGrey),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bill History',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Review all finalized transactions',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// SEARCH BAR WIDGET
// ===========================================================================

class _SearchBar extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  ConsumerState<_SearchBar> createState() => __SearchBarState();
}

class __SearchBarState extends ConsumerState<_SearchBar> {
  late final TextEditingController _searchController;
  
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
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _searchController,
        onChanged: widget.onChanged,
        style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
        cursorColor: AppTheme.accent,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.cardDark,
          hintText: 'Search by Customer or Bill No...',
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.accent, width: 2),
          ),
        ),
      ),
    );
  }
}


// ===========================================================================
// FILTER CHIPS WIDGET
// ===========================================================================

class _FilterChips extends StatelessWidget {
  final BillHistoryFilter activeFilter;
  final ValueChanged<BillHistoryFilter> onFilterSelected;

  const _FilterChips({required this.activeFilter, required this.onFilterSelected});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _FilterChip(
            label: 'All',
            isActive: activeFilter == BillHistoryFilter.all,
            onTap: () => onFilterSelected(BillHistoryFilter.all),
          ),
          _FilterChip(
            label: 'Today',
            isActive: activeFilter == BillHistoryFilter.today,
            onTap: () => onFilterSelected(BillHistoryFilter.today),
          ),
          _FilterChip(
            label: 'This Week',
            isActive: activeFilter == BillHistoryFilter.thisWeek,
            onTap: () => onFilterSelected(BillHistoryFilter.thisWeek),
          ),
          _FilterChip(
            label: 'This Month',
            isActive: activeFilter == BillHistoryFilter.thisMonth,
            onTap: () => onFilterSelected(BillHistoryFilter.thisMonth),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.accent : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? Colors.transparent : AppTheme.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : AppTheme.textGrey,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// BILL LIST ITEM WIDGET
// ===========================================================================

class _BillListItem extends StatelessWidget {
  final BillModel bill;
  const _BillListItem({required this.bill});

  @override
  Widget build(BuildContext context) {
    IconData paymentIcon;
    switch (bill.paymentMethod) {
      case PaymentMethod.cash: paymentIcon = Icons.money_rounded; break;
      case PaymentMethod.card: paymentIcon = Icons.credit_card; break;
      case PaymentMethod.upi: paymentIcon = Icons.qr_code; break;
      default: paymentIcon = Icons.payment; break;
    }
    
    return Material(
      color: AppTheme.cardDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BillDetailScreen(bill: bill),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(paymentIcon, color: AppTheme.accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.customerName?.isNotEmpty == true
                          ? bill.customerName!
                          : 'Walk-in Customer',
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bill.billNumber} • ${DateFormat('MMM d, yyyy').format(bill.createdAt)}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '\$${bill.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// EMPTY STATE WIDGET
// ===========================================================================

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  
  const _EmptyState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardDark,
                border: Border.all(color: AppTheme.border, width: 2),
              ),
              child: Icon(icon, color: AppTheme.textMuted, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}