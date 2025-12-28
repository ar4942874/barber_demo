import 'package:uuid/uuid.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes; // Critical for calendar blocking
  final bool isActive;       // Soft delete (don't delete from DB, just hide)
  final bool isSynced;       // 0 = Pending Sync, 1 = Synced
  final DateTime lastUpdated;

  ServiceModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.durationMinutes,
    this.isActive = true,
    this.isSynced = false,
    required this.lastUpdated,
  });

  // Factory for creating a NEW service from UI
  factory ServiceModel.create({
    required String name,
    String description = '',
    required double price,
    required int durationMinutes,
  }) {
    return ServiceModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      price: price,
      durationMinutes: durationMinutes,
      isActive: true,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
  }

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'isActive': isActive ? 1 : 0, // SQLite stores bools as 0/1
      'isSynced': isSynced ? 1 : 0,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Create from Map (SQLite)
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      durationMinutes: (map['durationMinutes'] as num).toInt(),
      isActive: map['isActive'] == 1,
      isSynced: map['isSynced'] == 1,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  // CopyWith for Riverpod updates
  ServiceModel copyWith({
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    bool? isActive,
    bool? isSynced,
    DateTime? lastUpdated,
  }) {
    return ServiceModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
      isSynced: isSynced ?? this.isSynced,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}