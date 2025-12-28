import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_pallete.dart';
import '../controller/service_controller.dart';
import '../model/service_model.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  final ServiceModel? serviceToEdit;
  const ServiceFormScreen({super.key, this.serviceToEdit});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;

  bool _isLoading = false;

  // --- HIGH CONTRAST THEME ---
  static const Color _bgDark = Color(0xFF0F172A); // Deep Navy Background
  static const Color _cardDark = Color(0xFF1E293B); // Slate Card
  static const Color _inputBlack =
      Colors.black; // PURE BLACK INPUTS (Fixes the "White" issue)

  static const Color _accent = Color(0xFFF59E0B); // Amber
  static const Color _textWhite = Colors.white; // Bright White
  static const Color _textGrey = Color(0xFF94A3B8); // Grey

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.serviceToEdit?.name ?? '',
    );
    _descController = TextEditingController(
      text: widget.serviceToEdit?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.serviceToEdit?.price.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: widget.serviceToEdit?.durationMinutes.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final description = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final duration = int.tryParse(_durationController.text.trim()) ?? 30;

    try {
      if (widget.serviceToEdit == null) {
        await ref
            .read(serviceControllerProvider.notifier)
            .addService(
              name: name,
              description: description,
              price: price,
              duration: duration,
            );
      } else {
        final updated = widget.serviceToEdit!.copyWith(
          name: name,
          description: description,
          price: price,
          durationMinutes: duration,
        );
        await ref.read(serviceControllerProvider.notifier).editService(updated);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: _textGrey,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "SERVICE MANAGER",
          style: TextStyle(
            color: _textGrey,
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 950;

            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 6, child: _buildFormPanel(isMobile: false)),
                  Expanded(flex: 4, child: _buildPreviewPanel()),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFormPanel(isMobile: true),
                    const SizedBox(height: 20),
                    Container(
                      height: 600,
                      color: Colors.black, // Dark background for preview area
                      child: _buildPreviewPanel(),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LEFT PANEL: EDITOR
  // ---------------------------------------------------------------------------
  Widget _buildFormPanel({required bool isMobile}) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CONFIGURATION",
            style: TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.serviceToEdit != null ? "Edit Service" : "New Service",
            style: const TextStyle(
              color: _textWhite,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          // DARK SLATE CARD
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(-10, 0),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _BlackInput(
                    label: "Service Name",
                    hint: "e.g. Royal Haircut",
                    icon: Icons.cut_rounded,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 24),
                  _BlackInput(
                    label: "Description",
                    hint: "Describe the experience...",
                    icon: Icons.description_outlined,
                    controller: _descController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _BlackInput(
                          label: "Price (RS)",
                          hint: "0.00",
                          icon: Icons.attach_money,
                          controller: _priceController,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _BlackInput(
                          label: "Time (Min)",
                          hint: "30",
                          icon: Icons.timer_outlined,
                          controller: _durationController,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            color: _textGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      _ModernButton(
                        text: "PUBLISH SERVICE",
                        onTap: _isLoading ? null : _saveService,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RIGHT PANEL: PREVIEW
  // ---------------------------------------------------------------------------
  Widget _buildPreviewPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "APP PREVIEW",
            style: TextStyle(
              color: _textGrey,
              letterSpacing: 3,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          ListenableBuilder(
            listenable: Listenable.merge([
              _nameController,
              _descController,
              _priceController,
              _durationController,
            ]),
            builder: (context, child) {
              final name = _nameController.text.isEmpty
                  ? "Service Name"
                  : _nameController.text;
              final desc = _descController.text.isEmpty
                  ? "Description will appear here..."
                  : _descController.text;
              final price = _priceController.text.isEmpty
                  ? "0"
                  : _priceController.text;
              final duration = _durationController.text.isEmpty
                  ? "00"
                  : _durationController.text;

              return Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _bgDark, // Simulate Mobile Dark Mode
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _cardDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 12,
                                color: _textGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "$duration min",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.more_horiz,
                          color: _textGrey.withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(
                        color: _textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: TextStyle(
                        color: _textGrey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            color: _textGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "\$$price",
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGET: BLACK INPUT (Maximum Contrast)
// -----------------------------------------------------------------------------
class _BlackInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isNumber;
  final int maxLines;

  const _BlackInput({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isNumber = false,
    this.maxLines = 1,
  });

  @override
  State<_BlackInput> createState() => _BlackInputState();
}

class _BlackInputState extends State<_BlackInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              color: _isFocused
                  ? _ServiceFormScreenState._accent
                  : _ServiceFormScreenState._textGrey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              // PURE BLACK BACKGROUND
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              // CRISP BORDER
              border: Border.all(
                color: _isFocused
                    ? _ServiceFormScreenState._accent
                    : Colors.white24,
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,

              // PRIMARY TEXT — sharp, confident, readable
              style: const TextStyle(
                // color: Color(0xFF0F172A), // Deep navy (better than pure black)
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),

              keyboardType: widget.isNumber
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,

              inputFormatters: widget.isNumber
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                  : null,

              maxLines: widget.maxLines,
              cursorColor: _ServiceFormScreenState._accent,

              decoration: InputDecoration(
                // IMPORTANT: enable fill
                filled: true,

                // SOFT PREMIUM BACKGROUND (not white, not grey)
                fillColor: Colors.grey.withValues(alpha: 0.3), // Slate-50

                prefixIcon: Icon(
                  widget.icon,
                  size: 20,
                  color: _isFocused
                      ? _ServiceFormScreenState._accent
                      // : const Color(0xFF64748B), // Slate-500
                      : Colors.white,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),

                // SUBTLE FOCUS RING (luxury feel)
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(
                      255,
                      91,
                      79,
                      60,
                    ).withOpacity(0.8),
                    width: 1,
                  ),
                ),

                // ERROR (still classy)
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 1),
                ),

                hintText: widget.hint,

                // HINT — visible but never competing
                hintStyle: const TextStyle(
                  color: Color.fromARGB(255, 240, 242, 244), // Slate-400
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),

              validator: (val) =>
                  (val == null || val.isEmpty) ? 'Required' : null,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGET: MODERN BUTTON
// -----------------------------------------------------------------------------
class _ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ModernButton({
    required this.text,
    required this.onTap,
    required this.isLoading,
  });

  @override
  State<_ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: _ServiceFormScreenState._accent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: _ServiceFormScreenState._accent.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}
