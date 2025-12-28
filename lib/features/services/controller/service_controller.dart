import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/service_model.dart';
import '../repository/service_repository.dart';

final serviceControllerProvider = AsyncNotifierProvider<ServiceController, List<ServiceModel>>(() {
  return ServiceController();
});

class ServiceController extends AsyncNotifier<List<ServiceModel>> {
  
  // 1. Build initial state
  @override
  FutureOr<List<ServiceModel>> build() async {
    return _fetchServices();
  }

 Future<List<ServiceModel>> _fetchServices() async {
  try {
    final repository = ref.read(serviceRepositoryProvider);
    return await repository.getServices();
  } catch (e, stack) {
    // Log error internally
    print("Error fetching services: $e");
    // Pass error to UI
    throw Exception("Database Error: $e"); 
  }
}

  // 2. Add Service
  Future<void> addService({
    required String name,
    required String description,
    required double price,
    required int duration,
  }) async {
    final repository = ref.read(serviceRepositoryProvider);
    
    // Optimistic Update or Loading State? Let's use Loading for safety.
    state = const AsyncValue.loading();

    final newService = ServiceModel.create(
      name: name,
      description: description,
      price: price,
      durationMinutes: duration,
    );

    state = await AsyncValue.guard(() async {
      await repository.addService(newService);
      return _fetchServices(); // Refresh list
    });
  }

  // 3. Delete Service
  Future<void> deleteService(String id) async {
    final repository = ref.read(serviceRepositoryProvider);
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await repository.deleteService(id);
      return _fetchServices();
    });
  }

  // 4. Update Service (Optional Phase 1)
  Future<void> editService(ServiceModel service) async {
    final repository = ref.read(serviceRepositoryProvider);
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await repository.updateService(service);
      return _fetchServices();
    });
  }
}