// lib/features/appointment/view/appointment_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controller/appointment_controller.dart';
import '../model/appointment_model.dart';
import '../../services/controller/service_controller.dart';
import '../../services/model/service_model.dart';

/// ===========================================================================
/// 🎨 THEME
/// ===========================================================================
class AppTheme {
  static const Color bgDark = Color(0xFF0F172A);
  static const Color green = Colors.green;
  static const Color cardDark = Color(0xFF1E293B);
  static const Color inputBg = Color(0xFF0D1420);

  static const Color accent = Color(0xFFFFB800);
  static const Color accentLight = Color(0xFFFFD54F);

  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  static const Color border = Color(0x1AFFFFFF);

  static List<BoxShadow> get whiteGlowShadow => [
        BoxShadow(
          color: Colors.white.withOpacity(0.08),
          blurRadius: 25,
          spreadRadius: 1,
        ),
      ];
}

/// ===========================================================================
/// 📝 APPOINTMENT FORM SCREEN
/// ===========================================================================
class AppointmentFormScreen extends ConsumerStatefulWidget {
  final AppointmentModel? appointmentToEdit;

  const AppointmentFormScreen({super.key, this.appointmentToEdit});

  @override
  ConsumerState<AppointmentFormScreen> createState() =>
      _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends ConsumerState<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _customerNameController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _notesController;

  // Form State
  List<ServiceModel> _selectedServices = []; // ✅ Support multiple services
  
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '09:00 AM';
  bool _isLoading = false;
  
  // Flag to ensure we only load existing services once in Edit mode
  bool _isDataInitialized = false; 

  // Available time slots
  final List<String> _timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
    '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
    '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM',
  ];

  bool get isEditing => widget.appointmentToEdit != null;

  // Helpers for calculations
  double get _totalPrice => _selectedServices.fold(0, (sum, item) => sum + item.price);
  int get _totalDuration => _selectedServices.fold(0, (sum, item) => sum + item.durationMinutes);

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(
      text: widget.appointmentToEdit?.customerName ?? '',
    );
    _customerPhoneController = TextEditingController(
      text: widget.appointmentToEdit?.customerPhone ?? '',
    );
    _notesController = TextEditingController(
      text: widget.appointmentToEdit?.notes ?? '',
    );

    if (isEditing) {
      _selectedDate = widget.appointmentToEdit!.appointmentDate;
      _selectedTime = widget.appointmentToEdit!.startTime;
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(serviceControllerProvider);
    final bookedSlotsAsync = ref.watch(bookedTimeSlotsProvider(_selectedDate));
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textGrey, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? "EDIT APPOINTMENT" : "NEW APPOINTMENT",
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 12,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : 24,
                  vertical: 24,
                ),
                children: [
                  // Title
                  Text(
                    isEditing ? "Edit Appointment" : "Book Appointment",
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Select one or more services to schedule",
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Main Form Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.whiteGlowShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Info Section
                        _buildSectionHeader("CUSTOMER INFORMATION", Icons.person_outline_rounded),
                        const SizedBox(height: 20),
                        
                        _buildInputField(
                          label: "Customer Name",
                          hint: "Enter customer name",
                          controller: _customerNameController,
                          icon: Icons.person_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter customer name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "Phone Number",
                          hint: "Enter phone number",
                          controller: _customerPhoneController,
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Service Selection Section
                        _buildSectionHeader("SELECT SERVICES", Icons.content_cut_rounded),
                        const SizedBox(height: 20),
                        servicesAsync.when(
                          data: (services) {
                            final activeServices = services.where((s) => s.isActive).toList();
                            
                            // Initialize selected services in Edit Mode (Run once)
                            if (isEditing && !_isDataInitialized && activeServices.isNotEmpty) {
                              final savedIds = widget.appointmentToEdit!.serviceIds; // Now it's a List
                              
                              _selectedServices = activeServices
                                  .where((s) => savedIds.contains(s.id))
                                  .toList();
                              
                              // Mark as initialized so we don't overwrite user changes on rebuild
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    _isDataInitialized = true;
                                  });
                                }
                              });
                            }

                            return _buildServiceSelector(activeServices);
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(color: AppTheme.accent),
                            ),
                          ),
                          error: (e, _) => Text(
                            'Error loading services: $e',
                            style: const TextStyle(color: AppTheme.error),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Date & Time Section
                        _buildSectionHeader("DATE & TIME", Icons.calendar_month_rounded),
                        const SizedBox(height: 20),
                        _buildDatePicker(),
                        const SizedBox(height: 24),
                        bookedSlotsAsync.when(
                          data: (bookedSlots) => _buildTimeSlotPicker(bookedSlots),
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(color: AppTheme.accent),
                            ),
                          ),
                          error: (_, __) => _buildTimeSlotPicker([]),
                        ),

                        const SizedBox(height: 32),

                        // Notes Section
                        _buildSectionHeader("ADDITIONAL NOTES", Icons.note_rounded),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: "Notes (Optional)",
                          hint: "Any special requests or notes...",
                          controller: _notesController,
                          icon: Icons.note_add_rounded,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Summary Card (Show if any service selected)
                  if (_selectedServices.isNotEmpty) _buildSummaryCard(),

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// SERVICE SELECTOR (MULTIPLE)
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildServiceSelector(List<ServiceModel> services) {
    if (services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Center(
          child: Text(
            "No active services available",
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: services.map((service) {
        // Check if this specific service is in the selected list
        final isSelected = _selectedServices.any((s) => s.id == service.id);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedServices.removeWhere((s) => s.id == service.id);
              } else {
                _selectedServices.add(service);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accent.withOpacity(0.15) : AppTheme.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppTheme.accent : AppTheme.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checkbox/Icon visual
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accent
                        : AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.add,
                    size: 16,
                    color: isSelected ? Colors.black : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Service Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.accent : AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${service.durationMinutes} min",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                
                // Price
                Text(
                  "\$${service.price.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.accent : AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// SUMMARY CARD
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    final endTime = _calculateEndTime(_selectedTime, _totalDuration);

    // Create a display string for services (e.g. "Haircut, Beard Trim")
    String serviceNames = _selectedServices.map((s) => s.name).join(", ");
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withOpacity(0.15),
            AppTheme.accentLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Header row remains same) ...
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                "BOOKING SUMMARY",
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Summary Details
          _buildSummaryRow("Services", serviceNames),
          _buildSummaryRow("Date", DateFormat('EEE, MMM d, yyyy').format(_selectedDate)),
          _buildSummaryRow("Time", "$_selectedTime - $endTime"),
          _buildSummaryRow("Duration", "$_totalDuration minutes"),
          
          const SizedBox(height: 16),
          Container(height: 1, color: AppTheme.accent.withOpacity(0.2)),
          const SizedBox(height: 16),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${_selectedServices.length} Service${_selectedServices.length > 1 ? 's' : ''}",
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "\$${_totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ... (Keep other helper widgets: _buildSectionHeader, _buildInputField, _buildDatePicker, _buildTimeSlotPicker, _buildLegendItem, _buildSummaryRow, _buildActionButtons, _calculateEndTime, _showSuccess, _showError - NO CHANGES NEEDED IN THEM) ...

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.accent, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppTheme.accent,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.inputBg,
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, color: AppTheme.textMuted, size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: AppTheme.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SELECTED DATE",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent,
              surface: AppTheme.cardDark,
              onSurface: AppTheme.textWhite,
            ),
            dialogBackgroundColor: AppTheme.bgDark,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      ref.invalidate(bookedTimeSlotsProvider(_selectedDate));
    }
  }

  Widget _buildTimeSlotPicker(List<String> bookedSlots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "SELECT TIME SLOT",
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _buildLegendItem("Available", AppTheme.cardDark),
                const SizedBox(width: 12),
                _buildLegendItem("Booked", AppTheme.error.withOpacity(0.3)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((time) {
            final isSelected = _selectedTime == time;
            final isBooked = bookedSlots.contains(time) &&
                !(isEditing && widget.appointmentToEdit!.startTime == time);

            return GestureDetector(
              onTap: isBooked ? null : () => setState(() => _selectedTime = time),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isBooked
                      ? AppTheme.error.withOpacity(0.1)
                      : isSelected
                          ? AppTheme.accent
                          : AppTheme.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBooked
                        ? AppTheme.error.withOpacity(0.3)
                        : isSelected
                            ? AppTheme.accent
                            : AppTheme.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isBooked
                        ? AppTheme.error.withOpacity(0.6)
                        : isSelected
                            ? Colors.black
                            : AppTheme.textGrey,
                    decoration: isBooked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.border),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Center(
                child: Text(
                  "CANCEL",
                  style: TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _isLoading ? null : _submitForm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: _isLoading
                    ? null
                    : LinearGradient(colors: [AppTheme.accent, AppTheme.accentLight]),
                color: _isLoading ? AppTheme.cardDark : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppTheme.accent,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        isEditing ? "UPDATE APPOINTMENT" : "BOOK APPOINTMENT",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _calculateEndTime(String startTime, int durationMinutes) {
    try {
      final parts = startTime.split(' ');
      final timeParts = parts[0].split(':');
      var hour = int.parse(timeParts[0]);
      var minute = int.parse(timeParts[1]);
      final isPM = parts.length > 1 && parts[1].toUpperCase() == 'PM';

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      final totalMinutes = hour * 60 + minute + durationMinutes;
      var endHour = (totalMinutes ~/ 60) % 24;
      final endMinute = totalMinutes % 60;

      final endPeriod = endHour >= 12 ? 'PM' : 'AM';
      if (endHour > 12) endHour -= 12;
      if (endHour == 0) endHour = 12;

      return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')} $endPeriod';
    } catch (e) {
      return startTime;
    }
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// SUBMIT FORM
  /// ─────────────────────────────────────────────────────────────────────────
  Future<void> _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check services selected
    if (_selectedServices.isEmpty) {
      _showError('Please select at least one service');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(appointmentControllerProvider.notifier);
      final endTime = _calculateEndTime(_selectedTime, _totalDuration);

      // Prepare lists
      final selectedServiceIds = _selectedServices.map((s) => s.id).toList();
      final serviceNames = _selectedServices.map((s) => s.name).join(', ');

      if (isEditing) {
        // Update existing appointment
        final updated = widget.appointmentToEdit!.copyWith(
          customerName: _customerNameController.text.trim(),
          customerPhone: _customerPhoneController.text.trim(),
          serviceName: serviceNames,
          // Since appointment model only stores primary service ID for legacy/compatibility if needed
          // but our repository uses the list, this assignment is less critical for the DB write
          // but good for immediate UI feedback.
          serviceIds: selectedServiceIds,
          appointmentDate: _selectedDate,
          startTime: _selectedTime,
          endTime: endTime,
          durationMinutes: _totalDuration,
          price: _totalPrice,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          updatedAt: DateTime.now(),
        );

        // ✅ Pass the new list of service IDs to update junction table
        await controller.updateAppointment(
          updated,
          newServiceIds: selectedServiceIds, 
        );
        _showSuccess('Appointment updated successfully!');
      } else {
        // Create new appointment
        await controller.addAppointment(
          customerName: _customerNameController.text.trim(),
          customerPhone: _customerPhoneController.text.trim(),
          serviceIds: selectedServiceIds, // ✅ Pass List
          serviceNames: serviceNames,
          appointmentDate: _selectedDate,
          startTime: _selectedTime,
          endTime: endTime,
          durationMinutes: _totalDuration,
          price: _totalPrice,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
        _showSuccess('Appointment booked successfully!');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}