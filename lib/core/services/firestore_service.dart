import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../config/constants.dart';
import '../models/vehicle_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

/// Servicio para operaciones CRUD en Firestore
/// Gestiona vehículos, órdenes y usuarios
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== VEHÍCULOS ====================

  /// Crea o actualiza un vehículo
  Future<void> saveVehicle(VehicleModel vehicleModel) async {
    try {
      await _firestore
          .collection(AppConstants.vehiclesCollection)
          .doc(vehicleModel.id)
          .set(vehicleModel.toFirestore());

      if (kDebugMode) {
        print('✅ Vehículo guardado: ${vehicleModel.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al guardar vehículo: $e');
      }
      throw Exception('Error al guardar vehículo: $e');
    }
  }

  /// Obtiene un vehículo por ID
  Future<VehicleModel?> getVehicle(String vehicleId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.vehiclesCollection)
          .doc(vehicleId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return VehicleModel.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener vehículo: $e');
      }
      throw Exception('Error al obtener vehículo: $e');
    }
  }

  /// Stream de vehículos filtrados por tab actual
  Stream<List<VehicleModel>> getVehiclesByTab(String tabId) {
    try {
      return _firestore
          .collection(AppConstants.vehiclesCollection)
          .where('currentTab', isEqualTo: tabId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => VehicleModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener vehículos por tab: $e');
      }
      return Stream.value([]);
    }
  }

  /// Stream de todos los vehículos activos
  Stream<List<VehicleModel>> getAllActiveVehicles() {
    try {
      return _firestore
          .collection(AppConstants.vehiclesCollection)
          .where('status', isEqualTo: 'active')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => VehicleModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener vehículos activos: $e');
      }
      return Stream.value([]);
    }
  }

  /// Busca vehículos por placa, marca o modelo
  Future<List<VehicleModel>> searchVehicles(String query) async {
    try {
      final queryLower = query.toLowerCase();

      // Búsqueda por placa
      final plateQuery = await _firestore
          .collection(AppConstants.vehiclesCollection)
          .where('plate', isGreaterThanOrEqualTo: queryLower)
          .where('plate', isLessThanOrEqualTo: '$queryLower\uf8ff')
          .limit(20)
          .get();

      // Búsqueda por marca
      final brandQuery = await _firestore
          .collection(AppConstants.vehiclesCollection)
          .where('brand', isGreaterThanOrEqualTo: queryLower)
          .where('brand', isLessThanOrEqualTo: '$queryLower\uf8ff')
          .limit(20)
          .get();

      // Combinar resultados y eliminar duplicados
      final vehicles = <String, VehicleModel>{};

      for (final doc in [...plateQuery.docs, ...brandQuery.docs]) {
        final vehicle = VehicleModel.fromFirestore(doc);
        vehicles[vehicle.id] = vehicle;
      }

      return vehicles.values.toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al buscar vehículos: $e');
      }
      return [];
    }
  }

  /// Actualiza el tab actual del vehículo
  Future<void> updateVehicleTab(String vehicleId, String newTab) async {
    try {
      await _firestore
          .collection(AppConstants.vehiclesCollection)
          .doc(vehicleId)
          .update({
            'currentTab': newTab,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (kDebugMode) {
        print('✅ Tab actualizado: $vehicleId -> $newTab');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al actualizar tab: $e');
      }
      throw Exception('Error al actualizar tab: $e');
    }
  }

  /// Elimina un vehículo (soft delete)
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _firestore
          .collection(AppConstants.vehiclesCollection)
          .doc(vehicleId)
          .update({
            'status': 'deleted',
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (kDebugMode) {
        print('✅ Vehículo eliminado: $vehicleId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al eliminar vehículo: $e');
      }
      throw Exception('Error al eliminar vehículo: $e');
    }
  }

  // ==================== ÓRDENES ====================

  /// Crea o actualiza una orden
  Future<void> saveOrder(OrderModel orderModel) async {
    try {
      await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderModel.id)
          .set(orderModel.toFirestore());

      if (kDebugMode) {
        print('✅ Orden guardada: ${orderModel.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al guardar orden: $e');
      }
      throw Exception('Error al guardar orden: $e');
    }
  }

  /// Obtiene una orden por ID
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(orderId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return OrderModel.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener orden: $e');
      }
      throw Exception('Error al obtener orden: $e');
    }
  }

  /// Stream de órdenes de un vehículo específico
  Stream<List<OrderModel>> getOrdersByVehicle(String vehicleId) {
    try {
      return _firestore
          .collection(AppConstants.ordersCollection)
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => OrderModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener órdenes del vehículo: $e');
      }
      return Stream.value([]);
    }
  }

  /// Obtiene el último número de orden asignado
  Future<int> getLastOrderNumber() async {
    try {
      final query = await _firestore
          .collection(AppConstants.ordersCollection)
          .orderBy('orderNumber', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return 0;
      }

      return query.docs.first.data()['orderNumber'] as int? ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener último número de orden: $e');
      }
      return 0;
    }
  }

  // ==================== USUARIOS ====================

  /// Crea o actualiza un usuario
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toFirestore());

      if (kDebugMode) {
        print('✅ Usuario guardado: ${user.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al guardar usuario: $e');
      }
      throw Exception('Error al guardar usuario: $e');
    }
  }

  /// Obtiene un usuario por ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener usuario: $e');
      }
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Stream de un usuario específico
  Stream<UserModel?> getUserStream(String uid) {
    try {
      return _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) {
              return null;
            }
            return UserModel.fromFirestore(doc);
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener stream de usuario: $e');
      }
      return Stream.value(null);
    }
  }

  /// Obtiene todos los técnicos del taller
  Future<List<UserModel>> getTechnicians(String workshopId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where('workshopId', isEqualTo: workshopId)
          .where('role', isEqualTo: 'technician')
          .get();

      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener técnicos: $e');
      }
      return [];
    }
  }

  // ==================== UTILIDADES ====================

  /// Ejecuta una transacción batch para múltiples operaciones
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String;
        final data = operation['data'] as Map<String, dynamic>;
        final type = operation['type'] as String; // 'set', 'update', 'delete'

        final ref = _firestore.collection(collection).doc(docId);

        switch (type) {
          case 'set':
            batch.set(ref, data);
            break;
          case 'update':
            batch.update(ref, data);
            break;
          case 'delete':
            batch.delete(ref);
            break;
        }
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ Batch ejecutado: ${operations.length} operaciones');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en batch: $e');
      }
      throw Exception('Error en operación batch: $e');
    }
  }
}
