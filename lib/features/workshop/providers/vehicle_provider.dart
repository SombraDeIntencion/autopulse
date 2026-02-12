import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/models/vehicle_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../config/constants.dart';

/// Provider para gestionar el estado de los vehículos
/// Maneja el flujo completo del workshop (7 tabs)
class VehicleProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  // Stream subscriptions para cancelar en dispose
  final List<StreamSubscription> _subscriptions = [];
  StreamSubscription? _vehicleOrdersSubscription;

  // Estado
  final List<VehicleModel> _vehicles = [];
  List<VehicleModel> _receptionVehicles = [];
  List<VehicleModel> _diagnosisVehicles = [];
  List<VehicleModel> _partsVehicles = [];
  List<VehicleModel> _approvalVehicles = [];
  List<VehicleModel> _repairVehicles = [];
  List<VehicleModel> _controlVehicles = [];
  List<VehicleModel> _deliveryVehicles = [];

  VehicleModel? _selectedVehicle;
  String _currentTab = AppConstants.tabReception;
  bool _isLoading = false;
  String? _errorMessage;
  List<OrderModel> _vehicleOrders = [];

  // Getters
  List<VehicleModel> get vehicles => _vehicles;
  List<VehicleModel> get receptionVehicles => _receptionVehicles;
  List<VehicleModel> get diagnosisVehicles => _diagnosisVehicles;
  List<VehicleModel> get partsVehicles => _partsVehicles;
  List<VehicleModel> get approvalVehicles => _approvalVehicles;
  List<VehicleModel> get repairVehicles => _repairVehicles;
  List<VehicleModel> get controlVehicles => _controlVehicles;
  List<VehicleModel> get deliveryVehicles => _deliveryVehicles;

  VehicleModel? get selectedVehicle => _selectedVehicle;
  String get currentTab => _currentTab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderModel> get vehicleOrders => _vehicleOrders;

  /// Obtiene vehículos del tab activo
  List<VehicleModel> get currentTabVehicles {
    switch (_currentTab) {
      case AppConstants.tabReception:
        return _receptionVehicles;
      case AppConstants.tabDiagnosis:
        return _diagnosisVehicles;
      case AppConstants.tabParts:
        return _partsVehicles;
      case AppConstants.tabApproval:
        return _approvalVehicles;
      case AppConstants.tabRepair:
        return _repairVehicles;
      case AppConstants.tabControl:
        return _controlVehicles;
      case AppConstants.tabDelivery:
        return _deliveryVehicles;
      default:
        return [];
    }
  }

  /// Inicializa listeners para todos los tabs
  void initializeListeners() {
    _listenToTab(AppConstants.tabReception);
    _listenToTab(AppConstants.tabDiagnosis);
    _listenToTab(AppConstants.tabParts);
    _listenToTab(AppConstants.tabApproval);
    _listenToTab(AppConstants.tabRepair);
    _listenToTab(AppConstants.tabControl);
    _listenToTab(AppConstants.tabDelivery);
  }

  /// Escucha cambios en un tab específico
  void _listenToTab(String tabId) {
    final subscription = _firestoreService.getVehiclesByTab(tabId).listen((
      vehicles,
    ) {
      switch (tabId) {
        case AppConstants.tabReception:
          _receptionVehicles = vehicles;
          break;
        case AppConstants.tabDiagnosis:
          _diagnosisVehicles = vehicles;
          break;
        case AppConstants.tabParts:
          _partsVehicles = vehicles;
          break;
        case AppConstants.tabApproval:
          _approvalVehicles = vehicles;
          break;
        case AppConstants.tabRepair:
          _repairVehicles = vehicles;
          break;
        case AppConstants.tabControl:
          _controlVehicles = vehicles;
          break;
        case AppConstants.tabDelivery:
          _deliveryVehicles = vehicles;
          break;
      }
      notifyListeners();
    });
    _subscriptions.add(subscription);
  }

  /// Cambia el tab activo
  void setCurrentTab(String tabId) {
    _currentTab = tabId;
    notifyListeners();
  }

  /// Selecciona un vehículo
  Future<void> selectVehicle(String vehicleId) async {
    try {
      _setLoading(true);
      _clearError();

      _selectedVehicle = await _firestoreService.getVehicle(vehicleId);

      if (_selectedVehicle != null) {
        // Cargar órdenes del vehículo
        _loadVehicleOrders(vehicleId);
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Carga las órdenes de un vehículo
  void _loadVehicleOrders(String vehicleId) {
    // Cancelar subscription anterior si existe
    _vehicleOrdersSubscription?.cancel();

    _vehicleOrdersSubscription = _firestoreService
        .getOrdersByVehicle(vehicleId)
        .listen((orders) {
          _vehicleOrders = orders;
          notifyListeners();
        });
  }

  /// Deselecciona el vehículo actual
  void clearSelectedVehicle() {
    _selectedVehicle = null;
    _vehicleOrders = [];
    notifyListeners();
  }

  /// Crea o actualiza un vehículo
  Future<bool> saveVehicle(VehicleModel vehicleModel) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.saveVehicle(vehicleModel);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Mueve un vehículo al siguiente tab
  Future<bool> moveVehicleToNextTab(String vehicleId) async {
    try {
      _setLoading(true);
      _clearError();

      final vehicle = await _firestoreService.getVehicle(vehicleId);
      if (vehicle == null) {
        _setError('Vehículo no encontrado');
        _setLoading(false);
        return false;
      }

      // Determinar siguiente tab
      final nextTab = _getNextTab(vehicle.currentTab);
      if (nextTab == null) {
        _setError('Este vehículo ya está en el último tab');
        _setLoading(false);
        return false;
      }

      // Actualizar tab
      await _firestoreService.updateVehicleTab(vehicleId, nextTab);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Mueve un vehículo a un tab específico
  Future<bool> moveVehicleToTab(String vehicleId, String targetTab) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.updateVehicleTab(vehicleId, targetTab);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Elimina un vehículo (soft delete)
  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.deleteVehicle(vehicleId);

      if (_selectedVehicle?.id == vehicleId) {
        clearSelectedVehicle();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Busca vehículos por texto
  Future<List<VehicleModel>> searchVehicles(String query) async {
    try {
      _setLoading(true);
      _clearError();

      final results = await _firestoreService.searchVehicles(query);

      _setLoading(false);
      return results;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  /// Sube una foto del vehículo
  Future<String?> uploadVehiclePhoto(File photo, String vehicleId) async {
    try {
      _setLoading(true);
      _clearError();

      final url = await _storageService.uploadImage(
        file: photo,
        path: '${AppConstants.vehiclePhotosPath}/$vehicleId',
      );

      _setLoading(false);
      return url;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Sube múltiples fotos del vehículo
  Future<List<String>> uploadVehiclePhotos(
    List<File> photos,
    String vehicleId,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final urls = await _storageService.uploadMultipleImages(
        files: photos,
        path: '${AppConstants.vehiclePhotosPath}/$vehicleId',
      );

      _setLoading(false);
      return urls;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }

  /// Crea una orden para un vehículo
  Future<bool> createOrder(OrderModel OrderModel) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.saveOrder(OrderModel);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Obtiene el siguiente número de orden disponible
  Future<int> getNextOrderNumber() async {
    try {
      final lastNumber = await _firestoreService.getLastOrderNumber();
      return lastNumber + 1;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener siguiente número de orden: $e');
      }
      return 1;
    }
  }

  /// Determina el siguiente tab en el flujo
  String? _getNextTab(String currentTab) {
    switch (currentTab) {
      case AppConstants.tabReception:
        return AppConstants.tabDiagnosis;
      case AppConstants.tabDiagnosis:
        return AppConstants.tabParts;
      case AppConstants.tabParts:
        return AppConstants.tabApproval;
      case AppConstants.tabApproval:
        return AppConstants.tabRepair;
      case AppConstants.tabRepair:
        return AppConstants.tabControl;
      case AppConstants.tabControl:
        return AppConstants.tabDelivery;
      case AppConstants.tabDelivery:
        return null; // Ya está en el último tab
      default:
        return null;
    }
  }

  /// Obtiene el tab anterior en el flujo
  String? getPreviousTab(String currentTab) {
    switch (currentTab) {
      case AppConstants.tabDelivery:
        return AppConstants.tabControl;
      case AppConstants.tabControl:
        return AppConstants.tabRepair;
      case AppConstants.tabRepair:
        return AppConstants.tabApproval;
      case AppConstants.tabApproval:
        return AppConstants.tabParts;
      case AppConstants.tabParts:
        return AppConstants.tabDiagnosis;
      case AppConstants.tabDiagnosis:
        return AppConstants.tabReception;
      case AppConstants.tabReception:
        return null; // Ya está en el primer tab
      default:
        return null;
    }
  }

  /// Obtiene el índice del tab actual (0-6)
  int getCurrentTabIndex() {
    const tabs = [
      AppConstants.tabReception,
      AppConstants.tabDiagnosis,
      AppConstants.tabParts,
      AppConstants.tabApproval,
      AppConstants.tabRepair,
      AppConstants.tabControl,
      AppConstants.tabDelivery,
    ];
    return tabs.indexOf(_currentTab);
  }

  /// Obtiene el total de vehículos en todos los tabs
  int getTotalVehiclesCount() {
    return _receptionVehicles.length +
        _diagnosisVehicles.length +
        _partsVehicles.length +
        _approvalVehicles.length +
        _repairVehicles.length +
        _controlVehicles.length +
        _deliveryVehicles.length;
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
    // Cancelar todas las subscripciones a streams
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _vehicleOrdersSubscription?.cancel();

    if (kDebugMode) {
      print('✅ VehicleProvider: Streams cancelados');
    }

    super.dispose();
  }
}

