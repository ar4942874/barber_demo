import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/service_controller.dart';
import '../model/service_model.dart';
import 'service_form_screen.dart';

/// ===========================================================================
/// 🎨 ENHANCED THEME - BETTER ACCENT COLORS
/// ===========================================================================
class AppTheme {
  // Core Colors
  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardElevated = Color(0xFF273548);
  static const Color inputBg = Color(0xFF0D1420);
  static const Color inputFill = Color(0xFF1A1F2E);

  // Improved Accent - Brighter, more visible gold
  static const Color accent = Color(0xFFFFB800);
  static const Color accentLight = Color(0xFFFFD54F);
  static const Color accentSoft = Color(0x26FFB800);
  static const Color accentGlow = Color(0x4DFFB800);

  // Text
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Borders
  static const Color border = Color(0x1AFFFFFF);
  static const Color borderLight = Color(0x0DFFFFFF);

  // Enhanced Shadows with white glow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.03),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get cardHoverShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 25,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.06),
      blurRadius: 30,
      spreadRadius: 2,
    ),
    BoxShadow(color: accent.withOpacity(0.08), blurRadius: 20, spreadRadius: 0),
  ];

  static List<BoxShadow> get whiteGlowShadow => [
    BoxShadow(
      color: Colors.white.withOpacity(0.08),
      blurRadius: 25,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.04),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: accent.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: accent.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get inputShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get inputFocusShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(color: accent.withOpacity(0.2), blurRadius: 12, spreadRadius: 0),
  ];
}

/// ===========================================================================
/// 📋 SERVICES LIST SCREEN - WITH GRID/LIST TOGGLE
/// ===========================================================================
class ServicesListScreen extends ConsumerStatefulWidget {
  const ServicesListScreen({super.key});

  @override
  ConsumerState<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends ConsumerState<ServicesListScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  bool _isSearchFocused = false;
  bool _isGridView = false;
  int _selectedFilter = 0;

  final List<String> _filters = ['All', 'Active', 'Inactive'];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });

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
    _searchController.dispose();
    _searchFocus.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(serviceControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive layout
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 700 && screenWidth < 1100;
    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);

    // Grid columns based on view mode
    final crossAxisCount = _isGridView
        ? (isDesktop ? 3 : (isTablet ? 2 : 1))
        : 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Header
                _buildHeader(horizontalPadding),

                // Search Bar
                _buildSearchBar(horizontalPadding),

                const SizedBox(height: 16),

                // Filter Chips + View Toggle
                _buildFiltersAndToggle(horizontalPadding),

                const SizedBox(height: 20),

                // Content
                Expanded(
                  child: servicesState.when(
                    loading: () =>
                        _buildLoadingState(crossAxisCount, horizontalPadding),
                    error: (e, _) => _ErrorState(message: e.toString()),
                    data: (services) {
                      var filtered = services
                          .where(
                            (s) => s.name.toLowerCase().contains(
                              _query.toLowerCase(),
                            ),
                          )
                          .toList();

                      // Apply filter
                      if (_selectedFilter == 1) {
                        filtered = filtered.where((s) => s.isActive).toList();
                      } else if (_selectedFilter == 2) {
                        filtered = filtered.where((s) => !s.isActive).toList();
                      }

                      if (filtered.isEmpty) {
                        return const _EmptyState();
                      }

                      return _buildServicesList(
                        filtered,
                        crossAxisCount,
                        horizontalPadding,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// ENHANCED HEADER WITH ICON
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(double padding) {
    final serviceCount = ref
        .watch(serviceControllerProvider)
        .maybeWhen(data: (services) => services.length, orElse: () => 0);

    return Container(
      margin: EdgeInsets.fromLTRB(padding, 20, padding, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.whiteGlowShadow,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: AppTheme.textWhite,
            onPressed: () => Navigator.of(context).pop(),
          ),
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.accent, AppTheme.accentLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.design_services_rounded,
              color: Colors.black,
              size: 26,
            ),
          ),
          const SizedBox(width: 20),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SERVICE MANAGER",
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Services",
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.success.withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$serviceCount active services",
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Add Button
          _AddServiceButton(onTap: () => _navigateToForm()),
        ],
      ),
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// SEARCH BAR
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isSearchFocused
              ? AppTheme.inputFocusShadow
              : AppTheme.inputShadow,
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppTheme.accent,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.inputBg,
            hintText: 'Search services...',
            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isSearchFocused ? AppTheme.accent : AppTheme.textMuted,
              size: 22,
            ),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
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
              borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// FILTER CHIPS + VIEW TOGGLE
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildFiltersAndToggle(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          // Filter Chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final filter = entry.value;
                  final isSelected = index == _selectedFilter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isSelected
                              ? AppTheme.accent
                              : AppTheme.cardDark,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accent
                                : AppTheme.border,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.accent.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black
                                : AppTheme.textGrey,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // View Toggle
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.cardDark,
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                _ViewToggleButton(
                  icon: Icons.view_list_rounded,
                  isActive: !_isGridView,
                  onTap: () => setState(() => _isGridView = false),
                ),
                _ViewToggleButton(
                  icon: Icons.grid_view_rounded,
                  isActive: _isGridView,
                  onTap: () => setState(() => _isGridView = true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// SERVICES LIST/GRID
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildServicesList(
    List<ServiceModel> services,
    int crossAxisCount,
    double padding,
  ) {
    if (!_isGridView) {
      // List View
      return ListView.separated(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _ServiceListCard(
            service: services[index],
            ref: ref,
            index: index,
          );
        },
      );
    }

    // Grid View
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _ServiceGridCard(
          service: services[index],
          ref: ref,
          index: index,
        );
      },
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// LOADING STATE
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildLoadingState(int crossAxisCount, double padding) {
    if (!_isGridView) {
      return ListView.separated(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => const _SkeletonListCard(),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const _SkeletonGridCard(),
    );
  }

  void _navigateToForm([ServiceModel? service]) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ServiceFormScreen(serviceToEdit: service),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

/// ===========================================================================
/// 🔘 VIEW TOGGLE BUTTON
/// ===========================================================================
class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isActive
              ? AppTheme.accent.withOpacity(0.15)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isActive ? AppTheme.accent : AppTheme.textMuted,
          size: 20,
        ),
      ),
    );
  }
}

/// ===========================================================================
/// 🔘 ADD SERVICE BUTTON
/// ===========================================================================
class _AddServiceButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddServiceButton({required this.onTap});

  @override
  State<_AddServiceButton> createState() => _AddServiceButtonState();
}

class _AddServiceButtonState extends State<_AddServiceButton> {
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.accent, AppTheme.accentLight],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? AppTheme.buttonShadow
                : [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.black, size: 18),
              SizedBox(width: 8),
              Text(
                "ADD SERVICE",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// 💳 SERVICE LIST CARD - NO EXPANDED/SPACER (FIXED)
/// ===========================================================================
class _ServiceListCard extends StatefulWidget {
  final ServiceModel service;
  final WidgetRef ref;
  final int index;

  const _ServiceListCard({
    required this.service,
    required this.ref,
    required this.index,
  });

  @override
  State<_ServiceListCard> createState() => _ServiceListCardState();
}

class _ServiceListCardState extends State<_ServiceListCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 50)),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: FadeTransition(
        opacity: _scaleAnim,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(0.0, _isHovered ? -4.0 : 0.0),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isHovered
                    ? AppTheme.accent.withOpacity(0.4)
                    : AppTheme.border,
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: _isHovered
                  ? AppTheme.cardHoverShadow
                  : AppTheme.cardShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _navigateToEdit(),
                splashColor: AppTheme.accent.withOpacity(0.1),
                highlightColor: AppTheme.accent.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ✅ FIXED: Use min size
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ServiceIcon(serviceName: widget.service.name),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.service.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textWhite,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.service.description.isEmpty
                                      ? "No description provided"
                                      : widget.service.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          _ActionMenu(
                            onEdit: () => _navigateToEdit(),
                            onDelete: () => _showDeleteDialog(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Tags Row
                      Row(
                        children: [
                          _CategoryTag(
                            text: _extractCategory(widget.service.name),
                          ),
                          const SizedBox(width: 10),
                          _DurationBadge(
                            duration: widget.service.durationMinutes,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Container(height: 1, color: AppTheme.border),

                      const SizedBox(height: 14),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatusBadge(isActive: widget.service.isActive),
                          _PriceTag(price: widget.service.price),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceFormScreen(serviceToEdit: widget.service),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(
        serviceName: widget.service.name,
        onConfirm: () {
          widget.ref
              .read(serviceControllerProvider.notifier)
              .deleteService(widget.service.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  String _extractCategory(String name) {
    if (name.contains(' ')) {
      return name.split(' ').last.toUpperCase();
    }
    return 'SERVICE';
  }
}

/// ===========================================================================
/// 💳 SERVICE GRID CARD - WITH EXPANDED (HAS BOUNDED HEIGHT)
/// ===========================================================================
class _ServiceGridCard extends StatefulWidget {
  final ServiceModel service;
  final WidgetRef ref;
  final int index;

  const _ServiceGridCard({
    required this.service,
    required this.ref,
    required this.index,
  });

  @override
  State<_ServiceGridCard> createState() => _ServiceGridCardState();
}

class _ServiceGridCardState extends State<_ServiceGridCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 50)),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: FadeTransition(
        opacity: _scaleAnim,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(0.0, _isHovered ? -4.0 : 0.0),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isHovered
                    ? AppTheme.accent.withOpacity(0.4)
                    : AppTheme.border,
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: _isHovered
                  ? AppTheme.cardHoverShadow
                  : AppTheme.cardShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _navigateToEdit(),
                splashColor: AppTheme.accent.withOpacity(0.1),
                highlightColor: AppTheme.accent.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ServiceIcon(
                            serviceName: widget.service.name,
                            size: 44,
                          ),
                          const Spacer(), // ✅ OK here because GridView provides bounded height
                          _StatusBadge(
                            isActive: widget.service.isActive,
                            compact: true,
                          ),
                          const SizedBox(width: 4),
                          _ActionMenu(
                            onEdit: () => _navigateToEdit(),
                            onDelete: () => _showDeleteDialog(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Title
                      Text(
                        widget.service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Description - Expanded to take remaining space
                      Expanded(
                        child: Text(
                          widget.service.description.isEmpty
                              ? "No description"
                              : widget.service.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Divider
                      Container(height: 1, color: AppTheme.border),

                      const SizedBox(height: 12),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DurationBadge(
                            duration: widget.service.durationMinutes,
                            compact: true,
                          ),
                          _PriceTag(price: widget.service.price, compact: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceFormScreen(serviceToEdit: widget.service),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(
        serviceName: widget.service.name,
        onConfirm: () {
          widget.ref
              .read(serviceControllerProvider.notifier)
              .deleteService(widget.service.id);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// ===========================================================================
/// 🎯 SERVICE ICON
/// ===========================================================================
class _ServiceIcon extends StatelessWidget {
  final String serviceName;
  final double size;

  const _ServiceIcon({required this.serviceName, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withOpacity(0.2),
            AppTheme.accentLight.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _getIconForService(serviceName),
        color: AppTheme.accent,
        size: size * 0.5,
      ),
    );
  }

  IconData _getIconForService(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('hair') || lower.contains('cut'))
      return Icons.content_cut;
    if (lower.contains('spa') || lower.contains('massage')) return Icons.spa;
    if (lower.contains('nail')) return Icons.brush;
    if (lower.contains('facial') || lower.contains('skin'))
      return Icons.face_retouching_natural;
    if (lower.contains('makeup') || lower.contains('beauty'))
      return Icons.auto_awesome;
    return Icons.design_services;
  }
}

/// ===========================================================================
/// 🏷️ CATEGORY TAG
/// ===========================================================================
class _CategoryTag extends StatelessWidget {
  final String text;

  const _CategoryTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.2),
            AppTheme.accentLight.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: AppTheme.accent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.accent,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// ===========================================================================
/// ⏱️ DURATION BADGE
/// ===========================================================================
class _DurationBadge extends StatelessWidget {
  final int duration;
  final bool compact;

  const _DurationBadge({required this.duration, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.inputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: compact ? 12 : 14,
            color: AppTheme.textGrey,
          ),
          const SizedBox(width: 4),
          Text(
            "$duration min",
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// 🟢 STATUS BADGE
/// ===========================================================================
class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final bool compact;

  const _StatusBadge({required this.isActive, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.success.withOpacity(0.15)
            : AppTheme.textMuted.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.success.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppTheme.success : AppTheme.textMuted,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.success.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 5),
            Text(
              isActive ? "Active" : "Inactive",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? AppTheme.success : AppTheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ===========================================================================
/// 💰 PRICE TAG
/// ===========================================================================
class _PriceTag extends StatelessWidget {
  final double price;
  final bool compact;

  const _PriceTag({required this.price, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.15),
            AppTheme.accentLight.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        "\$${price.toStringAsFixed(0)}",
        style: TextStyle(
          fontSize: compact ? 18 : 22,
          fontWeight: FontWeight.w800,
          color: AppTheme.accent,
          shadows: [
            Shadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// ⚙️ ACTION MENU
/// ===========================================================================
class _ActionMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppTheme.textMuted,
        size: 18,
      ),
      color: AppTheme.cardElevated,
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.border),
      ),
      offset: const Offset(0, 40),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        _buildMenuItem(
          'edit',
          Icons.edit_outlined,
          'Edit Service',
          AppTheme.textWhite,
        ),
        const PopupMenuDivider(height: 1),
        _buildMenuItem(
          'delete',
          Icons.delete_outline_rounded,
          'Delete',
          AppTheme.error,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// 💀 SKELETON LIST CARD - NO EXPANDED/SPACER (FIXED)
/// ===========================================================================
class _SkeletonListCard extends StatefulWidget {
  const _SkeletonListCard();

  @override
  State<_SkeletonListCard> createState() => _SkeletonListCardState();
}

class _SkeletonListCardState extends State<_SkeletonListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ✅ FIXED
            children: [
              Row(
                children: [
                  _buildShimmer(48, 48, 12),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmer(double.infinity, 16, 6),
                        const SizedBox(height: 8),
                        _buildShimmer(120, 12, 6),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildShimmer(70, 24, 6),
                  const SizedBox(width: 10),
                  _buildShimmer(60, 24, 6),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: AppTheme.border),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildShimmer(60, 20, 6), _buildShimmer(50, 24, 6)],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmer(double width, double height, double radius) {
    final shimmerValue = (_controller.value * 2 - 1).abs();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [
            AppTheme.inputBg,
            AppTheme.cardElevated.withOpacity(0.5 + shimmerValue * 0.3),
            AppTheme.inputBg,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// 💀 SKELETON GRID CARD - WITH EXPANDED (HAS BOUNDED HEIGHT)
/// ===========================================================================
class _SkeletonGridCard extends StatefulWidget {
  const _SkeletonGridCard();

  @override
  State<_SkeletonGridCard> createState() => _SkeletonGridCardState();
}

class _SkeletonGridCardState extends State<_SkeletonGridCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildShimmer(44, 44, 12),
                  const Spacer(), // ✅ OK - Grid has bounded height
                  _buildShimmer(40, 20, 6),
                ],
              ),
              const SizedBox(height: 14),
              _buildShimmer(double.infinity, 16, 6),
              const SizedBox(height: 6),
              Expanded(child: _buildShimmer(100, 12, 6)),
              Container(height: 1, color: AppTheme.border),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildShimmer(50, 20, 6), _buildShimmer(45, 22, 6)],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmer(double width, double height, double radius) {
    final shimmerValue = (_controller.value * 2 - 1).abs();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [
            AppTheme.inputBg,
            AppTheme.cardElevated.withOpacity(0.5 + shimmerValue * 0.3),
            AppTheme.inputBg,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// 🗑️ DELETE DIALOG
/// ===========================================================================
class _DeleteDialog extends StatelessWidget {
  final String serviceName;
  final VoidCallback onConfirm;

  const _DeleteDialog({required this.serviceName, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.03),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.error.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.error,
                size: 26,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Delete Service",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textWhite,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Are you sure you want to delete "$serviceName"? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppTheme.border),
                      ),
                    ),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.error.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "DELETE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// 📭 EMPTY STATE
/// ===========================================================================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.whiteGlowShadow,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 40,
              color: AppTheme.accent.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No services found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Create your first service or adjust filters",
            style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// ❌ ERROR STATE
/// ===========================================================================
class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.error.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: 20),
            const Text(
              "Something went wrong",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
