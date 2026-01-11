// lib/features/appointment/view/appointment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../billing/controller/billing_controller.dart';
import '../../billing/view/walk_in_billing_screen.dart';
import '../../services/controller/service_controller.dart';
import '../controller/appointment_controller.dart';
import '../model/appointment_model.dart';
import 'appointment_form_screen.dart';

// ===========================================================================
// MAIN SCREEN WIDGET
// ===========================================================================

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  
  void _onFilterChanged(int index) {
    setState(() {
      _selectedFilterIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 700 && screenWidth < 1100;
    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _AppTheme.bgDark,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(padding: horizontalPadding),
                const SizedBox(height: 16),
                _DateSelector(padding: horizontalPadding),
                const SizedBox(height: 16),
                _FilterChips(
                  padding: horizontalPadding,
                  selectedIndex: _selectedFilterIndex,
                  onFilterChanged: _onFilterChanged,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _AppointmentsList(
                    padding: horizontalPadding,
                    filterIndex: _selectedFilterIndex,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// HEADER WIDGET
// ===========================================================================

class _Header extends ConsumerWidget {
  final double padding;
  const _Header({required this.padding});
  
  void _navigateToForm(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppointmentFormScreen()),
    ).then((_) {
      ref.invalidate(selectedDateAppointmentsProvider);
      ref.invalidate(appointmentStatsProvider);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(appointmentStatsProvider);

    return Container(
      margin: EdgeInsets.fromLTRB(padding, 20, padding, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _AppTheme.border),
        boxShadow: _AppTheme.whiteGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context), color: _AppTheme.textMuted),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: [_AppTheme.accent, _AppTheme.accentLight]), boxShadow: [BoxShadow(color: _AppTheme.accent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]), child: const Icon(Icons.calendar_month_rounded, color: Colors.black, size: 26)),
              const SizedBox(width: 20),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("APPOINTMENT MANAGER", style: TextStyle(color: _AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2.5)), SizedBox(height: 6), Text("Appointments", style: TextStyle(color: _AppTheme.textWhite, fontSize: 28, fontWeight: FontWeight.bold))])),
              _AddAppointmentButton(onTap: () => _navigateToForm(context, ref)),
            ],
          ),
          const SizedBox(height: 20),
          statsAsync.when(
            data: (stats) => _StatsRow(stats: stats),
            loading: () => const SizedBox(height: 70, child: Center(child: CircularProgressIndicator(color: _AppTheme.accent, strokeWidth: 2))),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: "Today", value: stats['today']?.toString() ?? '0', color: _AppTheme.info, icon: Icons.today_rounded),
        const SizedBox(width: 12),
        _StatCard(label: "Upcoming", value: stats['upcoming']?.toString() ?? '0', color: _AppTheme.warning, icon: Icons.upcoming_rounded),
        const SizedBox(width: 12),
        _StatCard(label: "Completed", value: stats['completed']?.toString() ?? '0', color: _AppTheme.success, icon: Icons.check_circle_outline_rounded),
        const SizedBox(width: 12),
        _StatCard(label: "Total", value: stats['total']?.toString() ?? '0', color: _AppTheme.purple, icon: Icons.calendar_view_month_rounded),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: _AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// DATE AND FILTER WIDGETS
// ===========================================================================

class _DateSelector extends ConsumerWidget {
  final double padding;
  const _DateSelector({required this.padding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: _HorizontalDatePicker(
        selectedDate: selectedDate,
        onDateSelected: (date) => ref.read(selectedDateProvider.notifier).state = date,
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final double padding;
  final int selectedIndex;
  final ValueChanged<int> onFilterChanged;
  
  final List<String> _filters = const ['All', 'Scheduled', 'Confirmed', 'In Progress', 'Completed', 'Cancelled'];

  const _FilterChips({required this.padding, required this.selectedIndex, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            final isSelected = index == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => onFilterChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected ? _AppTheme.accent : _AppTheme.cardDark,
                    border: Border.all(color: isSelected ? _AppTheme.accent : _AppTheme.border),
                    boxShadow: isSelected ? [BoxShadow(color: _AppTheme.accent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))] : null,
                  ),
                  child: Text(filter, style: TextStyle(color: isSelected ? Colors.black : _AppTheme.textGrey, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ===========================================================================
// APPOINTMENTS LIST WIDGET
// ===========================================================================

class _AppointmentsList extends ConsumerWidget {
  final double padding;
  final int filterIndex;
  final List<String> _filters = const ['All', 'Scheduled', 'Confirmed', 'In Progress', 'Completed', 'Cancelled'];

  const _AppointmentsList({required this.padding, required this.filterIndex});
  
  AppointmentStatus? _getStatusFromFilter(int index) {
    switch (index) {
      case 1: return AppointmentStatus.scheduled;
      case 2: return AppointmentStatus.confirmed;
      case 3: return AppointmentStatus.inProgress;
      case 4: return AppointmentStatus.completed;
      case 5: return AppointmentStatus.cancelled;
      default: return null;
    }
  }

  void _navigateToForm(BuildContext context, WidgetRef ref, [AppointmentModel? appointment]) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentFormScreen(appointmentToEdit: appointment))).then((_) {
      ref.invalidate(selectedDateAppointmentsProvider);
      ref.invalidate(appointmentStatsProvider);
    });
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AppointmentModel appointment) async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => _DeleteConfirmDialog(customerName: appointment.customerName));
    if (confirm == true) {
      await ref.read(appointmentControllerProvider.notifier).deleteAppointment(appointment.id);
    }
  }

  Future<void> _updateStatus(WidgetRef ref, String id, AppointmentStatus status) async {
    await ref.read(appointmentControllerProvider.notifier).updateStatus(id, status);
  }

  Future<void> _completeAndNavigateToBilling(BuildContext context, WidgetRef ref, AppointmentModel appointment) async {
    try {
      final allServices = await ref.read(serviceControllerProvider.future);
      final appointmentServices = allServices.where((s) => appointment.serviceIds.contains(s.id)).toList();
      
      if (appointmentServices.isEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Services for this appointment not found.')));
        return;
      }
      
      ref.read(billingControllerProvider.notifier).populateBillFromAppointment(appointment, appointmentServices);
      
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalkInBillingScreen()));
      }
    } catch (e, st) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error preparing bill: $e')));
      }
    }
  }

  void _showAppointmentDetails(BuildContext context, WidgetRef ref, AppointmentModel appointment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AppointmentDetailsSheet(
        appointment: appointment,
        onEdit: () {
          Navigator.pop(context);
          _navigateToForm(context, ref, appointment);
        },
        onDelete: () async {
          Navigator.pop(context);
          await _confirmDelete(context, ref, appointment);
        },
        onStatusChange: (status) async {
          Navigator.pop(context);
          if (status == AppointmentStatus.completed) {
            await _completeAndNavigateToBilling(context, ref, appointment);
          } else {
            await _updateStatus(ref, appointment.id, status);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(selectedDateAppointmentsProvider);

    return appointmentsAsync.when(
      data: (appointments) {
        var filtered = appointments;
        if (filterIndex > 0) {
          final statusFilter = _getStatusFromFilter(filterIndex);
          if (statusFilter != null) {
            filtered = appointments.where((a) => a.status == statusFilter).toList();
          }
        }
        if (filtered.isEmpty) {
          return _EmptyState(message: filterIndex == 0 ? "No appointments for this date" : "No ${_filters[filterIndex].toLowerCase()} appointments");
        }
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final appointment = filtered[index];
            return _AppointmentCard(
              appointment: appointment,
              onTap: () => _showAppointmentDetails(context, ref, appointment),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: _AppTheme.accent)),
      error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, color: _AppTheme.error, size: 48), const SizedBox(height: 16), const Text("Error loading appointments", style: TextStyle(color: _AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Text(e.toString(), style: const TextStyle(color: _AppTheme.textMuted, fontSize: 14), textAlign: TextAlign.center)])),
    );
  }
}

// ===========================================================================
// All other self-contained widgets follow
// ===========================================================================

class _HorizontalDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const _HorizontalDatePicker({required this.selectedDate, required this.onDateSelected});

  @override
  State<_HorizontalDatePicker> createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<_HorizontalDatePicker> {
  late ScrollController _scrollController;
  late List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _generateDates();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDate());
  }

  void _generateDates() {
    final now = DateTime.now();
    _dates = List.generate(60, (index) => now.add(Duration(days: index - 14)));
  }

  void _scrollToSelectedDate() {
    final index = _dates.indexWhere((d) => d.year == widget.selectedDate.year && d.month == widget.selectedDate.month && d.day == widget.selectedDate.day);
    if (index != -1 && _scrollController.hasClients) {
      _scrollController.animateTo(index * 72.0 - 100, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void didUpdateWidget(_HorizontalDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) _scrollToSelectedDate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = date.year == widget.selectedDate.year && date.month == widget.selectedDate.month && date.day == widget.selectedDate.day;
          final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => widget.onDateSelected(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isSelected ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_AppTheme.accent, _AppTheme.accentLight]) : null,
                  color: isSelected ? null : _AppTheme.cardDark,
                  border: Border.all(color: isToday && !isSelected ? _AppTheme.accent.withOpacity(0.5) : isSelected ? Colors.transparent : _AppTheme.border, width: isToday && !isSelected ? 2 : 1),
                  boxShadow: isSelected ? [BoxShadow(color: _AppTheme.accent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('EEE').format(date).toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.black : _AppTheme.textMuted)),
                    const SizedBox(height: 6),
                    Text(date.day.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : _AppTheme.textWhite)),
                    const SizedBox(height: 2),
                    Text(DateFormat('MMM').format(date), style: TextStyle(fontSize: 10, color: isSelected ? Colors.black54 : _AppTheme.textMuted)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatefulWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;

  const _AppointmentCard({required this.appointment, required this.onTap});

  @override
  State<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<_AppointmentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = _AppTheme.getStatusColor(widget.appointment.status);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -2.0 : 0.0),
        decoration: BoxDecoration(color: _AppTheme.cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: _isHovered ? statusColor.withOpacity(0.5) : _AppTheme.border), boxShadow: _isHovered ? _AppTheme.cardHoverShadow : _AppTheme.cardShadow),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(color: _AppTheme.inputBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _AppTheme.border)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [Text(widget.appointment.startTime.split(' ')[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _AppTheme.textWhite)), Text(widget.appointment.startTime.split(' ').length > 1 ? widget.appointment.startTime.split(' ')[1] : '', style: const TextStyle(fontSize: 11, color: _AppTheme.textMuted))]),
                  ),
                  const SizedBox(width: 16),
                  Container(width: 4, height: 55, decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: statusColor.withOpacity(0.4), blurRadius: 8)])),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.appointment.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _AppTheme.textWhite), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(children: [const Icon(Icons.content_cut, size: 13, color: _AppTheme.textMuted), const SizedBox(width: 4), Expanded(child: Text(widget.appointment.serviceName, style: const TextStyle(fontSize: 13, color: _AppTheme.textMuted), overflow: TextOverflow.ellipsis))]),
                        const SizedBox(height: 4),
                        Row(children: [const Icon(Icons.schedule, size: 13, color: _AppTheme.textMuted), const SizedBox(width: 4), Text("${widget.appointment.durationMinutes} min", style: const TextStyle(fontSize: 12, color: _AppTheme.textMuted)), const SizedBox(width: 12), const Icon(Icons.phone_outlined, size: 13, color: _AppTheme.textMuted), const SizedBox(width: 4), Text(widget.appointment.customerPhone, style: const TextStyle(fontSize: 12, color: _AppTheme.textMuted))]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColor.withOpacity(0.3))), child: Text(widget.appointment.statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor))),
                      const SizedBox(height: 10),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), gradient: LinearGradient(colors: [_AppTheme.accent.withOpacity(0.15), _AppTheme.accentLight.withOpacity(0.08)])), child: Text("\$${widget.appointment.price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _AppTheme.accent))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddAppointmentButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddAppointmentButton({required this.onTap});

  @override
  State<_AddAppointmentButton> createState() => _AddAppointmentButtonState();
}

class _AddAppointmentButtonState extends State<_AddAppointmentButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_AppTheme.accent, _AppTheme.accentLight]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered ? [BoxShadow(color: _AppTheme.accent.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))] : [BoxShadow(color: _AppTheme.accent.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_rounded, color: Colors.black, size: 18), SizedBox(width: 8), Text("NEW BOOKING", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8))]),
        ),
      ),
    );
  }
}

class _AppointmentDetailsSheet extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(AppointmentStatus) onStatusChange;

  const _AppointmentDetailsSheet({required this.appointment, required this.onEdit, required this.onDelete, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final statusColor = _AppTheme.getStatusColor(appointment.status);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _AppTheme.cardDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: _AppTheme.border), boxShadow: _AppTheme.whiteGlowShadow),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: _AppTheme.textMuted, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.person_rounded, color: statusColor, size: 28)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(appointment.customerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _AppTheme.textWhite)), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(appointment.statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)))])), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: LinearGradient(colors: [_AppTheme.accent.withOpacity(0.2), _AppTheme.accentLight.withOpacity(0.1)])), child: Text("\$${appointment.price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _AppTheme.accent)))]),
                const SizedBox(height: 28),
                _DetailRow(icon: Icons.content_cut_rounded, label: "Service", value: appointment.serviceName),
                _DetailRow(icon: Icons.calendar_today_rounded, label: "Date", value: appointment.formattedDate),
                _DetailRow(icon: Icons.schedule_rounded, label: "Time", value: "${appointment.startTime} - ${appointment.endTime}"),
                _DetailRow(icon: Icons.timer_outlined, label: "Duration", value: "${appointment.durationMinutes} minutes"),
                _DetailRow(icon: Icons.phone_rounded, label: "Phone", value: appointment.customerPhone),
                if (appointment.notes?.isNotEmpty == true) _DetailRow(icon: Icons.note_rounded, label: "Notes", value: appointment.notes!),
                const SizedBox(height: 24),
                if (!appointment.isCompleted && !appointment.isCancelled) ...[
                  const Text("UPDATE STATUS", style: TextStyle(color: _AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (appointment.isScheduled) _StatusButton(label: "Confirm", color: _AppTheme.purple, icon: Icons.check_rounded, onTap: () => onStatusChange(AppointmentStatus.confirmed)),
                      if (appointment.isScheduled || appointment.isConfirmed) _StatusButton(label: "Start", color: _AppTheme.warning, icon: Icons.play_arrow_rounded, onTap: () => onStatusChange(AppointmentStatus.inProgress)),
                      if (appointment.isInProgress) _StatusButton(label: "Complete & Bill", color: _AppTheme.success, icon: Icons.receipt_long_rounded, onTap: () => onStatusChange(AppointmentStatus.completed)),
                      if (!appointment.isInProgress) _StatusButton(label: "Complete", color: _AppTheme.success, icon: Icons.check_circle_rounded, onTap: () => onStatusChange(AppointmentStatus.completed)),
                      _StatusButton(label: "Cancel", color: _AppTheme.error, icon: Icons.close_rounded, onTap: () => onStatusChange(AppointmentStatus.cancelled)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                Row(children: [Expanded(child: OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 18), label: const Text("Edit"), style: OutlinedButton.styleFrom(foregroundColor: _AppTheme.textWhite, side: const BorderSide(color: _AppTheme.border), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))), const SizedBox(width: 12), Expanded(child: ElevatedButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, size: 18), label: const Text("Delete"), style: ElevatedButton.styleFrom(backgroundColor: _AppTheme.error, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _AppTheme.inputBg, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: _AppTheme.textMuted)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _AppTheme.textMuted, fontSize: 12)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: _AppTheme.textWhite, fontSize: 15, fontWeight: FontWeight.w500))])),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _StatusButton({required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))]),
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  final String customerName;
  const _DeleteConfirmDialog({required this.customerName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: _AppTheme.cardDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: _AppTheme.border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 20))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(color: _AppTheme.error.withOpacity(0.12), shape: BoxShape.circle), child: const Icon(Icons.delete_outline_rounded, color: _AppTheme.error, size: 28)),
            const SizedBox(height: 20),
            const Text("Delete Appointment", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _AppTheme.textWhite)),
            const SizedBox(height: 12),
            Text('Are you sure you want to delete the appointment for "$customerName"? This action cannot be undone.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: _AppTheme.textMuted, height: 1.5)),
            const SizedBox(height: 28),
            Row(children: [Expanded(child: TextButton(onPressed: () => Navigator.pop(context, false), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: _AppTheme.border))), child: const Text("CANCEL", style: TextStyle(color: _AppTheme.textGrey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)))), const SizedBox(width: 16), Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: _AppTheme.error, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("DELETE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5))))]),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 100, height: 100, decoration: BoxDecoration(color: _AppTheme.cardDark, shape: BoxShape.circle, border: Border.all(color: _AppTheme.border), boxShadow: _AppTheme.whiteGlowShadow), child: Icon(Icons.event_busy_rounded, size: 45, color: _AppTheme.accent.withOpacity(0.7))),
          const SizedBox(height: 24),
          Text(message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _AppTheme.textWhite), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text("Tap the button above to add a new appointment", style: TextStyle(fontSize: 14, color: _AppTheme.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AppTheme {
  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color inputBg = Color(0xFF0D1420);
  static const Color accent = Color(0xFFFFB800);
  static const Color accentLight = Color(0xFFFFD54F);
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color border = Color(0x1AFFFFFF);
  static List<BoxShadow> get cardHoverShadow => [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 12)), BoxShadow(color: Colors.white.withOpacity(0.06), blurRadius: 30, spreadRadius: 2)];
  static List<BoxShadow> get cardShadow => [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)), BoxShadow(color: Colors.white.withOpacity(0.03), blurRadius: 20)];
  static List<BoxShadow> get whiteGlowShadow => [BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 25, spreadRadius: 1)];
  static Color getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled: return info;
      case AppointmentStatus.confirmed: return purple;
      case AppointmentStatus.inProgress: return warning;
      case AppointmentStatus.completed: return success;
      case AppointmentStatus.cancelled: return error;
    }
  }
}