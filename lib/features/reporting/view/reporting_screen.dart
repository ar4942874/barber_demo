// lib/features/reporting/view/reporting_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart'; // Assuming you have AppTheme here
import '../controller/reporting_controller.dart';
import '../model/reporting_model.dart';

// ===========================================================================
// MAIN SCREEN WIDGET
// ===========================================================================

class ReportingScreen extends ConsumerWidget {
  const ReportingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportingControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: reportAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                error: (error, stack) => _ErrorState(error: error.toString()),
                data: (reportData) => _DashboardView(reportData: reportData, ref: ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// HEADER WIDGET (with Date Picker)
// ===========================================================================

class _Header extends ConsumerWidget {
  const _Header();

  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final currentRange = ref.read(reportDateRangeProvider);
    final newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: currentRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent,
              onPrimary: Colors.black,
              surface: AppTheme.cardDark,
              onSurface: AppTheme.textWhite,
            ),
            dialogBackgroundColor: AppTheme.bgDark,
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      ref.read(reportDateRangeProvider.notifier).state = newRange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(reportDateRangeProvider);
    final formattedRange =
        '${DateFormat.yMMMd().format(dateRange.start)} - ${DateFormat.yMMMd().format(dateRange.end)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textGrey),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Dashboard',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Material(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _selectDateRange(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppTheme.textMuted, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      formattedRange,
                      style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// MAIN DASHBOARD VIEW
// ===========================================================================

class _DashboardView extends StatelessWidget {
  final ReportData reportData;
  const _DashboardView({required this.reportData, required this.ref});
  final WidgetRef ref;  
  @override
  Widget build(BuildContext context, ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(reportingControllerProvider.notifier).getReportData(),
      color: AppTheme.accent,
      backgroundColor: AppTheme.cardDark,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          _KpiGrid(reportData: reportData),
          const SizedBox(height: 20),
          _RevenueChart(dailyRevenue: reportData.dailyRevenue),
          const SizedBox(height: 20),
          _TopServicesList(topServices: reportData.topServices),
          const SizedBox(height: 20),
          _PaymentBreakdown(distribution: reportData.paymentMethodDistribution),
        ],
      ),
    );
  }
}

// ===========================================================================
// DASHBOARD COMPONENTS
// ===========================================================================

class _KpiGrid extends StatelessWidget {
  final ReportData reportData;
  const _KpiGrid({required this.reportData});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _KpiCard(
          title: 'Total Revenue',
          value: '\$${reportData.totalRevenue.toStringAsFixed(2)}',
          icon: Icons.monetization_on_outlined,
          color: AppTheme.green,
        ),
        _KpiCard(
          title: 'Total Bills',
          value: reportData.billCount.toString(),
          icon: Icons.receipt_long_rounded,
          color: AppTheme.blue,
        ),
        _KpiCard(
          title: 'Avg. Bill Value',
          value: '\$${reportData.averageBillValue.toStringAsFixed(2)}',
          icon: Icons.show_chart_rounded,
          color: AppTheme.purple,
        ),
        _KpiCard(
          title: 'Top Service',
          value: reportData.topServices.isNotEmpty ? reportData.topServices.first.serviceName : 'N/A',
          icon: Icons.cut_rounded,
          color: AppTheme.accent,
          isSmallText: reportData.topServices.isNotEmpty && reportData.topServices.first.serviceName.length > 10,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isSmallText;

  const _KpiCard({required this.title, required this.value, required this.icon, required this.color, this.isSmallText = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: isSmallText ? 24 : 32,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<ChartDataPoint> dailyRevenue;
  const _RevenueChart({required this.dailyRevenue});

  @override
  Widget build(BuildContext context) {
    if (dailyRevenue.isEmpty) {
      return const SizedBox.shrink(); // Don't show the chart if there's no data
    }
    
    final maxRevenue = dailyRevenue.fold<double>(0, (max, p) => p.value > max ? p.value : max);

    return _DashboardCard(
      title: 'Daily Revenue',
      icon: Icons.bar_chart_rounded,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxRevenue * 1.2, // Give some space at the top
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                // tooltipBgColor: AppTheme.accent,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final date = dailyRevenue[group.x.toInt()].date;
                  return BarTooltipItem(
                    '${DateFormat.MMMEd().format(date)}\n',
                    const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                        text: '\$${rod.toY.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final date = dailyRevenue[value.toInt()].date;
                    return SideTitleWidget(
                      meta: meta,
                      // axisSide: meta.axisSide,
                      child: Text(DateFormat.E().format(date), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
            barGroups: List.generate(dailyRevenue.length, (index) {
              final point = dailyRevenue[index];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: point.value,
                    color: AppTheme.accent,
                    width: 16,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TopServicesList extends StatelessWidget {
  final List<ServicePerformance> topServices;
  const _TopServicesList({required this.topServices});

  @override
  Widget build(BuildContext context) {
    if (topServices.isEmpty) {
      return const SizedBox.shrink();
    }
    return _DashboardCard(
      title: 'Top Services by Revenue',
      icon: Icons.star_border_rounded,
      child: Column(
        children: topServices.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
            child: Row(
              children: [
                Text('${index + 1}.', style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(child: Text(service.serviceName, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w500, fontSize: 15))),
                Text('\$${service.totalRevenue.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PaymentBreakdown extends StatelessWidget {
  final Map<String, int> distribution;
  const _PaymentBreakdown({required this.distribution});

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) {
      return const SizedBox.shrink();
    }
    return _DashboardCard(
      title: 'Payment Methods',
      icon: Icons.payment_rounded,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PaymentStat(label: 'Cash', count: distribution['cash'] ?? 0, color: AppTheme.green),
          _PaymentStat(label: 'Card', count: distribution['card'] ?? 0, color: AppTheme.blue),
          _PaymentStat(label: 'UPI', count: distribution['upi'] ?? 0, color: AppTheme.purple),
        ],
      ),
    );
  }
}

class _PaymentStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _PaymentStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ===========================================================================
// SHARED HELPER WIDGETS
// ===========================================================================

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _DashboardCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.textMuted, size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
          const SizedBox(height: 16),
          const Text('An Error Occurred', style: TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(color: AppTheme.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}