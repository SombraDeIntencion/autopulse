import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../config/constants.dart';

/// Provider para gestionar órdenes de servicio
/// Maneja órdenes avanzadas y de hojalatería con toda su información
class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  // Stream subscription
  StreamSubscription? _ordersSubscription;

  // Estado
  OrderModel? _currentOrder;
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, double> _uploadProgress = {};

  // Getters
  OrderModel? get currentOrder => _currentOrder;
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, double> get uploadProgress => _uploadProgress;

  /// Crea una nueva orden
  Future<bool> createOrder(OrderModel orderModel) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.saveOrder(orderModel);
      _currentOrder = orderModel;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Actualiza una orden existente
  Future<bool> updateOrder(OrderModel orderModel) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.saveOrder(orderModel);

      if (_currentOrder?.id == orderModel.id) {
        _currentOrder = orderModel;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Obtiene una orden por ID
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      _setLoading(true);
      _clearError();

      final order = await _firestoreService.getOrder(orderId);
      _currentOrder = order;

      _setLoading(false);
      return order;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Carga órdenes de un vehículo específico
  void loadOrdersByVehicle(String vehicleId) {
    // Cancelar subscription anterior si existe
    _ordersSubscription?.cancel();

    _ordersSubscription = _firestoreService
        .getOrdersByVehicle(vehicleId)
        .listen((orders) {
          _orders = orders;
          notifyListeners();
        });
  }

  /// Sube fotos para una orden
  Future<List<String>> uploadOrderPhotos({
    required List<File> photos,
    required String orderId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final urls = await _storageService.uploadMultipleImages(
        files: photos,
        path: '${AppConstants.vehiclePhotosPath}/orders/$orderId',
      );

      _setLoading(false);
      return urls;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  /// Sube una foto individual con progreso
  Future<String?> uploadPhotoWithProgress({
    required File photo,
    required String orderId,
    required String photoKey,
  }) async {
    try {
      _uploadProgress[photoKey] = 0.0;
      notifyListeners();

      String? url;

      await for (final progress in _storageService.uploadWithProgress(
        file: photo,
        path: '${AppConstants.vehiclePhotosPath}/orders/$orderId',
      )) {
        _uploadProgress[photoKey] = progress;
        notifyListeners();

        if (progress >= 1.0) {
          // Obtener la URL cuando termina
          url = await _storageService.uploadImage(
            file: photo,
            path: '${AppConstants.vehiclePhotosPath}/orders/$orderId',
          );
        }
      }

      _uploadProgress.remove(photoKey);
      notifyListeners();

      return url;
    } catch (e) {
      _setError(e.toString());
      _uploadProgress.remove(photoKey);
      notifyListeners();
      return null;
    }
  }

  /// Sube documentos (PDFs, etc.)
  Future<List<String>> uploadOrderDocuments({
    required List<File> documents,
    required String orderId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final urls = <String>[];

      for (final doc in documents) {
        final url = await _storageService.uploadDocument(
          file: doc,
          path: '${AppConstants.documentsPath}/orders/$orderId',
          contentType: 'application/pdf',
        );
        urls.add(url);
      }

      _setLoading(false);
      return urls;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  /// Actualiza el estado de la orden
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      _setLoading(true);
      _clearError();

      final order = await _firestoreService.getOrder(orderId);
      if (order == null) {
        _setError('Orden no encontrada');
        _setLoading(false);
        return false;
      }

      final updatedOrder = order.copyWith(status: newStatus);
      await _firestoreService.saveOrder(updatedOrder);

      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Agrega datos al serviceData de la orden
  Future<bool> updateServiceData(
    String orderId,
    Map<String, dynamic> newData,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final order = await _firestoreService.getOrder(orderId);
      if (order == null) {
        _setError('Orden no encontrada');
        _setLoading(false);
        return false;
      }

      final updatedServiceData = {...order.serviceData, ...newData};
      final updatedOrder = order.copyWith(serviceData: updatedServiceData);

      await _firestoreService.saveOrder(updatedOrder);

      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Agrega fotos a la orden
  Future<bool> addPhotosToOrder(String orderId, List<String> photoUrls) async {
    try {
      _setLoading(true);
      _clearError();

      final order = await _firestoreService.getOrder(orderId);
      if (order == null) {
        _setError('Orden no encontrada');
        _setLoading(false);
        return false;
      }

      final updatedPhotos = [...order.photos, ...photoUrls];
      final updatedOrder = order.copyWith(photos: updatedPhotos);

      await _firestoreService.saveOrder(updatedOrder);

      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Agrega documentos a la orden
  Future<bool> addDocumentsToOrder(
    String orderId,
    List<String> documentUrls,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final order = await _firestoreService.getOrder(orderId);
      if (order == null) {
        _setError('Orden no encontrada');
        _setLoading(false);
        return false;
      }

      final updatedDocuments = [...order.documents, ...documentUrls];
      final updatedOrder = order.copyWith(documents: updatedDocuments);

      await _firestoreService.saveOrder(updatedOrder);

      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Elimina una foto de la orden
  Future<bool> removePhotoFromOrder(String orderId, String photoUrl) async {
    try {
      _setLoading(true);
      _clearError();

      // Eliminar de Storage
      await _storageService.deleteFile(photoUrl);

      // Actualizar orden
      final order = await _firestoreService.getOrder(orderId);
      if (order == null) {
        _setError('Orden no encontrada');
        _setLoading(false);
        return false;
      }

      final updatedPhotos = order.photos
          .where((url) => url != photoUrl)
          .toList();
      final updatedOrder = order.copyWith(photos: updatedPhotos);

      await _firestoreService.saveOrder(updatedOrder);

      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Limpia la orden actual
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  /// Obtiene el progreso de subida de una foto específica
  double? getPhotoUploadProgress(String photoKey) {
    return _uploadProgress[photoKey];
  }

  // Métodos auxiliares
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Limpia el mensaje de error
  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _uploadProgress.clear();

    if (kDebugMode) {
      print('✅ OrderProvider: Streams cancelados');
    }

    super.dispose();
  }
}
