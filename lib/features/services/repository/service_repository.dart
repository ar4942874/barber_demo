import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/service_local_ds.dart';
import '../model/service_model.dart';

// 1. Define the Provider
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(ServiceLocalDataSource());
});

// 2. Define the Class
class ServiceRepository {
  final ServiceLocalDataSource _localDataSource;

  ServiceRepository(this._localDataSource);

  Future<List<ServiceModel>> getServices() async {
    return _localDataSource.getAllServices();
  }

  Future<void> addService(ServiceModel service) async {
    // In future: Add sync logic here
    await _localDataSource.insertService(service);
  }

  Future<void> updateService(ServiceModel service) async {
    // Mark as unsynced for future sync
    final updatedService = service.copyWith(
      isSynced: false, 
      lastUpdated: DateTime.now()
    );
    await _localDataSource.updateService(updatedService);
  }

  Future<void> deleteService(String id) async {
    await _localDataSource.deleteService(id);
  }
}