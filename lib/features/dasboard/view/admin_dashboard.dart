// lib/features/dashboard/view/admin_dashboard_screen.dart

import 'package:barber_demo/features/billing/view/bill_histroy/bill_history_screen.dart';
import 'package:barber_demo/features/billing/view/walk_in_billing_screen.dart';
import 'package:barber_demo/features/reporting/view/reporting_screen.dart';
import 'package:barber_demo/features/services/view/services_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../appointment/view/appointment_screen.dart';
import '../../appointment/view/appointment_form_screen.dart';
import '../../appointment/controller/appointment_controller.dart';
import '../../services/view/service_form_screen.dart';
import '../controller/dashboard_controller.dart';
import '../../appointment/model/appointment_model.dart';

/// ===========================================================================
/// 🎨 APP THEME (Unified from your palette)
/// ===========================================================================
class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // 🌙 BACKGROUNDS (From AppPallete)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color bgDark = Color(0xFF0F172A); // midnightStart
  static const Color cardDark = Color(0xFF1E293B); // midnightEnd
  static const Color inputBg = Color(0xFF0D1420);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌟 ACCENT (Gold Theme)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color accent = Color(0xFFFFD700); // gold
  static const Color accentDim = Color(0xFFC5A059); // goldDim
  static const Color accentLight = Color(0xFFFFA000);

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 TEXT
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDark = Color(0xFF1E293B);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚦 STATUS COLORS (From AdminDashboardColor)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color blue = Color(0xFF3B82F6); // blueIconColor
  static const Color blueBg = Color(0xFFE4EDFF); // bluebackGroundColor

  static const Color green = Color(0xFF22C55E); // greenIcon
  static const Color greenBg = Color(0xFFDFFCE5); // greenBackgroundColor

  static const Color purple = Color(0xFF9333EA); // purpleIcon
  static const Color purpleBg = Color(0xFFF2E7FE); // purpleBackgroundColor
  static const Color purpleLight = Color(0xFF8B5CF6);

  static const Color orange = Color(0xFFF97316); // orangeIconColor
  static const Color orangeBg = Color(0xFFFFEDD5); // orangeBackgroundColor

  static const Color error = Color(0xFFEF4444);
  static const Color cyan = Color(0xFF06B6D4); // accentCyan
  static const Color pink = Color(0xFFEC4899);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔲 BORDER
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color border = Color(0x1AFFFFFF);
  static const Color glassBorder = Colors.white24;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌈 GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDark, cardDark],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF536CE4), Color(0xFF8045D8)],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌟 SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════
  static List<BoxShadow> get whiteGlowShadow => [
    BoxShadow(
      color: Colors.white.withOpacity(0.08),
      blurRadius: 25,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];
}

/// ===========================================================================
/// 📊 ADMIN DASHBOARD SCREEN
/// ===========================================================================
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final todayAppointmentsAsync = ref.watch(todaysAppointmentsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 32),

                // Stats Grid
                _buildStatsGrid(statsAsync, isDesktop),
                const SizedBox(height: 32),

                // Quick Actions
                _buildSectionTitle("Quick Actions"),
                const SizedBox(height: 16),
                _buildQuickActions(context, isDesktop),
                const SizedBox(height: 32),

                // Today's Schedule
                _buildSectionTitle("Today's Schedule"),
                const SizedBox(height: 16),
                _buildTodaySchedule(context, todayAppointmentsAsync),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// HEADER
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardDark, Color(0xFF243045)],
        ),
        boxShadow: AppTheme.whiteGlowShadow,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Welcome Text
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              // Notification Button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.accent,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Date Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppTheme.accent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// STATS GRID
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatsGrid(
    AsyncValue<DashboardStats> statsAsync,
    bool isDesktop,
  ) {
    return statsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error loading stats: $e',
                style: const TextStyle(color: AppTheme.error),
              ),
            ),
          ],
        ),
      ),
      data: (stats) {
        final cards = [
          _StatCardData(
            title: "Total Appointments",
            value: stats.totalAppointments.toString(),
            icon: Icons.calendar_month_rounded,
            color: AppTheme.blue,
          ),
          _StatCardData(
            title: "Total Revenue",
            value: "\$${stats.totalRevenue.toStringAsFixed(0)}",
            icon: Icons.attach_money_rounded,
            color: AppTheme.green,
          ),
          _StatCardData(
            title: "Pending",
            value: stats.pendingAppointments.toString(),
            icon: Icons.pending_actions_rounded,
            color: AppTheme.orange,
          ),
          _StatCardData(
            title: "Today's Bookings",
            value: stats.todayAppointments.toString(),
            icon: Icons.today_rounded,
            color: AppTheme.purple,
          ),
        ];

        if (isDesktop) {
          return Row(
            children: cards.asMap().entries.map((entry) {
              final isLast = entry.key == cards.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 16),
                  child: _StatCard(data: entry.value),
                ),
              );
            }).toList(),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: cards.map((data) => _StatCard(data: data)).toList(),
        );
      },
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// QUICK ACTIONS
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context, bool isDesktop) {
    final actions = [
      // _QuickActionData(
      //   title: "New Appointment",
      //   subtitle: "Book a new slot",
      //   icon: Icons.add_circle_outline_rounded,
      //   color: AppTheme.accent,
      //   onTap: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (_) => const AppointmentFormScreen()),
      //   ),
      // ),
      _QuickActionData(
        title: "Manage Appointments",
        subtitle: "View calendar & bookings",
        icon: Icons.calendar_month_rounded,
        color: AppTheme.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AppointmentScreen()),
        ),
      ),
      // _QuickActionData(
      //   title: "Add New Service",
      //   subtitle: "Create a new service",
      //   icon: Icons.add_business_rounded,
      //   color: AppTheme.purple,
      //   onTap: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (_) => const ServiceFormScreen()),
      //   ),
      // ),
      _QuickActionData(
        title: "Services Management",
        subtitle: "Manage all services",
        icon: Icons.content_cut_rounded,
        color: AppTheme.cyan,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ServicesListScreen()),
        ),
      ),
      _QuickActionData(
        title: "Walk-in Billing",
        subtitle: "Create quick invoice",
        icon: Icons.point_of_sale_rounded,
        color: AppTheme.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalkInBillingScreen()),
        ),
      ),
      _QuickActionData(
        title: "Bill Management",
        subtitle: "View & manage bills",
        icon: Icons.receipt_long_rounded,
        color: AppTheme.pink,
        onTap: () =>Navigator.of( context).push(MaterialPageRoute(builder: (context) => BillHistoryScreen(),)),
      ),
      _QuickActionData(
        title: "Reports & Analysis",
        subtitle: "View analytics & reports",
        icon: Icons.analytics_rounded,
        color: AppTheme.purpleLight,
        onTap: () => Navigator.of( context).push(MaterialPageRoute(builder: (context) => ReportingScreen(),)),
      ),
      // _QuickActionData(
      //   title: "Branch Management",
      //   subtitle: "Manage branches",
      //   icon: Icons.store_rounded,
      //   color: AppTheme.orange,
      //   onTap: () => _showComingSoon(context, "Branch Management"),
      // ),
    ];

    int crossAxisCount = isDesktop ? 4 : 2;
    double aspectRatio = isDesktop ? 2.0 : 1.5;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _QuickActionCard(data: actions[index]),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text('$feature coming soon!'),
          ],
        ),
        backgroundColor: AppTheme.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// TODAY'S SCHEDULE
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildTodaySchedule(
    BuildContext context,
    AsyncValue<List<AppointmentModel>> appointmentsAsync,
  ) {
    return appointmentsAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppTheme.error),
            SizedBox(width: 12),
            Text(
              "Failed to load schedule",
              style: TextStyle(color: AppTheme.error),
            ),
          ],
        ),
      ),
      data: (appointments) {
        if (appointments.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_available,
                    size: 40,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No appointments for today",
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your schedule is clear!",
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _AppointmentTile(appointment: appointments[index]);
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// ===========================================================================
/// 📊 STAT CARD DATA
/// ===========================================================================
class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// ===========================================================================
/// 📊 STAT CARD WIDGET
/// ===========================================================================
class _StatCard extends StatelessWidget {
  final _StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.whiteGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 24),
          ),

          // Value & Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.title,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// ⚡ QUICK ACTION DATA
/// ===========================================================================
class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// ===========================================================================
/// ⚡ QUICK ACTION CARD WIDGET
/// ===========================================================================
class _QuickActionCard extends StatelessWidget {
  final _QuickActionData data;

  const _QuickActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: data.color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: data.color.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon with gradient background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.color.withOpacity(0.2),
                      data.color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: data.color.withOpacity(0.2)),
                ),
                child: Icon(data.icon, color: data.color, size: 22),
              ),

              // Title & Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// 📅 APPOINTMENT TILE WIDGET
/// ===========================================================================
class _AppointmentTile extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentTile({required this.appointment});

  Color get _statusColor {
    switch (appointment.status) {
      case AppointmentStatus.scheduled:
        return AppTheme.blue;
      case AppointmentStatus.confirmed:
        return AppTheme.accent;
      case AppointmentStatus.inProgress:
        return AppTheme.orange;
      case AppointmentStatus.completed:
        return AppTheme.green;
      case AppointmentStatus.cancelled:
        return AppTheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          // Time Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              appointment.startTime,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Customer & Service Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.customerName,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.serviceName,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _statusColor.withOpacity(0.3)),
            ),
            child: Text(
              appointment.statusText,
              style: TextStyle(
                color: _statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
