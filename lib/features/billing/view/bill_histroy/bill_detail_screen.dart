// lib/features/billing/view/bill_history/bill_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../model/billing_model.dart';

// ===========================================================================
// MAIN SCREEN WIDGET
// ===========================================================================

class BillDetailScreen extends StatelessWidget {
  final BillModel bill;
  const BillDetailScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textGrey, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill Details',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Invoice #${bill.billNumber}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          // Future actions like Print, Share, etc. can go here
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppTheme.textGrey),
            onPressed: () {
              // TODO: Implement printing logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing feature coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.textGrey),
            onPressed: () {
              // TODO: Implement sharing logic
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _ReceiptView(bill: bill),
      ),
    );
  }
}

// ===========================================================================
// RECEIPT VIEW WIDGET
// ===========================================================================

class _ReceiptView extends StatelessWidget {
  final BillModel bill;
  const _ReceiptView({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          _buildHeader(),
          const SizedBox(height: 24),
          const _DottedDivider(),
          const SizedBox(height: 24),

          // --- Bill & Customer Info ---
          _buildBillInfo(),
          const SizedBox(height: 24),

          // --- Items Table ---
          _buildItemsTable(),
          const SizedBox(height: 24),
          const _DottedDivider(),
          const SizedBox(height: 24),

          // --- Summary ---
          _buildSummary(),
          const SizedBox(height: 24),
          const _DottedDivider(),
          const SizedBox(height: 24),

          // --- Footer ---
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Center(
      child: Column(
        children: [
          Icon(Icons.cut_rounded, color: AppTheme.accent, size: 40),
          SizedBox(height: 8),
          Text(
            'Barber Shop', // Replace with your actual shop name
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '123 Style St, Haircut City, 54321', // Replace with your address
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBillInfo() {
    return Column(
      children: [
        _InfoRow(label: 'Bill Number:', value: bill.billNumber),
        _InfoRow(label: 'Date:', value: DateFormat('MMM d, yyyy').format(bill.createdAt)),
        _InfoRow(label: 'Time:', value: DateFormat('h:mm a').format(bill.createdAt)),
        const SizedBox(height: 16),
        _InfoRow(
          label: 'Billed To:',
          value: bill.customerName?.isNotEmpty == true
              ? bill.customerName!
              : 'Walk-in Customer',
        ),
        if (bill.customerPhone?.isNotEmpty == true)
          _InfoRow(label: 'Phone:', value: bill.customerPhone!),
      ],
    );
  }

  Widget _buildItemsTable() {
    return Column(
      children: [
        // Table Header
        const Row(
          children: [
            Expanded(flex: 3, child: Text('ITEM', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold))),
            Expanded(flex: 1, child: Center(child: Text('QTY', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold)))),
            Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('PRICE', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold)))),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: AppTheme.border),
        const SizedBox(height: 8),
        // Table Rows
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bill.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = bill.items[index];
            return Row(
              children: [
                Expanded(flex: 3, child: Text(item.serviceName, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w500))),
                Expanded(flex: 1, child: Center(child: Text(item.quantity.toString(), style: const TextStyle(color: AppTheme.textGrey)))),
                Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w500)))),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        _SummaryRow(label: 'Subtotal', value: '\$${bill.subtotal.toStringAsFixed(2)}'),
        _SummaryRow(label: 'Tax', value: '\$${bill.taxAmount.toStringAsFixed(2)}'),
        if(bill.discountAmount > 0)
          _SummaryRow(label: 'Discount', value: '- \$${bill.discountAmount.toStringAsFixed(2)}'),
        const SizedBox(height: 12),
        const _DottedDivider(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('TOTAL', style: TextStyle(color: AppTheme.accent, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('\$${bill.total.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.accent, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'Paid via ${bill.paymentMethod.name.toUpperCase()}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thank You For Your Business!',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// HELPER WIDGETS FOR THE RECEIPT
// ===========================================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 15)),
          Text(value, style: const TextStyle(color: AppTheme.textWhite, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppTheme.textMuted),
              ),
            );
          }),
        );
      },
    );
  }
}