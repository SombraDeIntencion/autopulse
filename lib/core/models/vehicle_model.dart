import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String type;
  final String brand;
  final String model;
  final String year;
  final String plate;
  final String color;
  final String vin;
  final String observations;
  final String client;
  final String technician;
  final String? mileage;
  final String currentTab;
  final String status; // 'active' | 'completed'
  final String orderNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate,
    required this.color,
    required this.vin,
    required this.observations,
    required this.client,
    required this.technician,
    this.mileage,
    this.currentTab = 'reception',
    this.status = 'active',
    required this.orderNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  // From Firestore
  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleModel(
      id: doc.id,
      type: data['type'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? '',
      plate: data['plate'] ?? '',
      color: data['color'] ?? '',
      vin: data['vin'] ?? '',
      observations: data['observations'] ?? '',
      client: data['client'] ?? '',
      technician: data['technician'] ?? '',
      mileage: data['mileage'],
      currentTab: data['currentTab'] ?? 'reception',
      status: data['status'] ?? 'active',
      orderNumber: data['orderNumber'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'brand': brand,
      'model': model,
      'year': year,
      'plate': plate,
      'color': color,
      'vin': vin,
      'observations': observations,
      'client': client,
      'technician': technician,
      'mileage': mileage,
      'currentTab': currentTab,
      'status': status,
      'orderNumber': orderNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with
  VehicleModel copyWith({
    String? id,
    String? type,
    String? brand,
    String? model,
    String? year,
    String? plate,
    String? color,
    String? vin,
    String? observations,
    String? client,
    String? technician,
    String? mileage,
    String? currentTab,
    String? status,
    String? orderNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      color: color ?? this.color,
      vin: vin ?? this.vin,
      observations: observations ?? this.observations,
      client: client ?? this.client,
      technician: technician ?? this.technician,
      mileage: mileage ?? this.mileage,
      currentTab: currentTab ?? this.currentTab,
      status: status ?? this.status,
      orderNumber: orderNumber ?? this.orderNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
