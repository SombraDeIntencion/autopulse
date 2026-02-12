import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String vehicleId;
  final String orderNumber;
  final String type; // 'advanced' | 'bodywork'
  final String currentPhase; // reception, diagnosis, etc.
  final Map<String, dynamic> serviceData;
  final List<Map<String, dynamic>> admissionReasons;
  final Map<String, dynamic> vehicleState;
  final List<String> photos;
  final List<String> documents;
  final String status; // 'pending' | 'in_progress' | 'completed' | 'delivered'
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.vehicleId,
    required this.orderNumber,
    required this.type,
    this.currentPhase = 'reception',
    this.serviceData = const {},
    this.admissionReasons = const [],
    this.vehicleState = const {},
    this.photos = const [],
    this.documents = const [],
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  // From Firestore
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      vehicleId: data['vehicleId'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      type: data['type'] ?? 'advanced',
      currentPhase: data['currentPhase'] ?? 'reception',
      serviceData: Map<String, dynamic>.from(data['serviceData'] ?? {}),
      admissionReasons: List<Map<String, dynamic>>.from(
        (data['admissionReasons'] ?? []).map(
          (x) => Map<String, dynamic>.from(x),
        ),
      ),
      vehicleState: Map<String, dynamic>.from(data['vehicleState'] ?? {}),
      photos: List<String>.from(data['photos'] ?? []),
      documents: List<String>.from(data['documents'] ?? []),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'vehicleId': vehicleId,
      'orderNumber': orderNumber,
      'type': type,
      'currentPhase': currentPhase,
      'serviceData': serviceData,
      'admissionReasons': admissionReasons,
      'vehicleState': vehicleState,
      'photos': photos,
      'documents': documents,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  // Copy with
  OrderModel copyWith({
    String? id,
    String? vehicleId,
    String? orderNumber,
    String? type,
    String? currentPhase,
    Map<String, dynamic>? serviceData,
    List<Map<String, dynamic>>? admissionReasons,
    Map<String, dynamic>? vehicleState,
    List<String>? photos,
    List<String>? documents,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      orderNumber: orderNumber ?? this.orderNumber,
      type: type ?? this.type,
      currentPhase: currentPhase ?? this.currentPhase,
      serviceData: serviceData ?? this.serviceData,
      admissionReasons: admissionReasons ?? this.admissionReasons,
      vehicleState: vehicleState ?? this.vehicleState,
      photos: photos ?? this.photos,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
