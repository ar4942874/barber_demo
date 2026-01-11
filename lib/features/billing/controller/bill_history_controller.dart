// lib/features/billing/controller/bill_history_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/billing_model.dart';
import '../repository/billing_repository.dart';

// ===========================================================================
// STATE DEFINITION
// ===========================================================================

/// Defines the different time-based filters the user can apply.
enum BillHistoryFilter { all, today, thisWeek, thisMonth }

/// Represents the state of the Bill History screen.
/// It holds all data and user selections needed for the UI.
class BillHistoryState {
  /// True when bills are being fetched from the database.
  final bool isLoading;
  
  /// The complete, unfiltered list of all bills fetched from the repository.
  final List<BillModel> allBills;
  
  /// The currently active time filter selected by the user.
  final BillHistoryFilter activeFilter;
  
  /// The current text entered in the search bar by the user.
  final String searchQuery;

  const BillHistoryState({
    this.isLoading = true,
    this.allBills = const [],
    this.activeFilter = BillHistoryFilter.all,
    this.searchQuery = '',
  });

  /// A computed property that returns a filtered and searched list of bills.
  /// This is what the UI will actually display. The logic is encapsulated here.
  List<BillModel> get filteredBills {
    List<BillModel> billsToDisplay;
    final now = DateTime.now();

    // 1. Apply the time filter
    switch (activeFilter) {
      case BillHistoryFilter.today:
        billsToDisplay = allBills.where((bill) {
          final billDate = bill.createdAt;
          return billDate.year == now.year && billDate.month == now.month && billDate.day == now.day;
        }).toList();
        break;
      case BillHistoryFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        billsToDisplay = allBills.where((bill) => bill.createdAt.isAfter(startOfWeek)).toList();
        break;
      case BillHistoryFilter.thisMonth:
        billsToDisplay = allBills.where((bill) => bill.createdAt.year == now.year && bill.createdAt.month == now.month).toList();
        break;
      case BillHistoryFilter.all:
      default:
        billsToDisplay = List.from(allBills);
        break;
    }

    // 2. Apply the search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      billsToDisplay = billsToDisplay.where((bill) {
        final customerNameMatch = bill.customerName?.toLowerCase().contains(query) ?? false;
        final billNumberMatch = bill.billNumber.toLowerCase().contains(query);
        return customerNameMatch || billNumberMatch;
      }).toList();
    }

    return billsToDisplay;
  }

  BillHistoryState copyWith({
    bool? isLoading,
    List<BillModel>? allBills,
    BillHistoryFilter? activeFilter,
    String? searchQuery,
  }) {
    return BillHistoryState(
      isLoading: isLoading ?? this.isLoading,
      allBills: allBills ?? this.allBills,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// ===========================================================================
// CONTROLLER (StateNotifier)
// ===========================================================================

class BillHistoryController extends StateNotifier<BillHistoryState> {
  final BillingRepository _repository;

  BillHistoryController(this._repository) : super(const BillHistoryState()) {
    // Fetch bills immediately when the controller is created.
    fetchBills();
  }

  /// Fetches all bills from the repository and updates the state.
  Future<void> fetchBills() async {
    state = state.copyWith(isLoading: true);
    try {
      final bills = await _repository.getBills();
      state = state.copyWith(allBills: bills, isLoading: false);
    } catch (e) {
      // In a real app, you might want to handle this error more gracefully.
      print('Failed to fetch bills: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Updates the active filter and lets the state's computed property do the work.
  void setFilter(BillHistoryFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  /// Updates the search query and lets the state's computed property do the work.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

// ===========================================================================
// PROVIDER
// ===========================================================================

/// The main provider for the Bill History feature.
/// The UI will watch this provider to get the current state and rebuild.
final billHistoryControllerProvider = StateNotifierProvider<BillHistoryController, BillHistoryState>((ref) {
  final repository = ref.watch(billingRepositoryProvider);
  return BillHistoryController(repository);
});