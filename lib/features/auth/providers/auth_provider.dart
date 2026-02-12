import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/biometric_auth_service.dart';

/// Provider para gestionar el estado de autenticación
/// Expone métodos para login, registro, logout y autenticación biométrica
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final BiometricAuthService _biometricService = BiometricAuthService();

  // Stream subscription
  StreamSubscription<firebase_auth.User?>? _authStateSubscription;

  // Estado
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;

  AuthProvider() {
    _initializeAuth();
  }

  /// Inicializa el provider verificando sesión activa
  Future<void> _initializeAuth() async {
    try {
      // Verificar si hay usuario autenticado
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      }

      // Verificar disponibilidad de biometría
      _isBiometricAvailable = await _biometricService
          .isBiometricAvailableAndConfigured();
      _isBiometricEnabled = await _biometricService.isBiometricEnabled();

      // Escuchar cambios en el estado de autenticación
      _authStateSubscription = _authService.authStateChanges.listen((user) {
        if (user == null) {
          _currentUser = null;
          notifyListeners();
        }
      });

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al inicializar AuthProvider: $e');
      }
    }
  }

  /// Carga los datos del usuario desde Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _currentUser = await _authService.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al cargar datos del usuario: $e');
      }
    }
  }

  /// Inicia sesión con email y password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signIn(email: email, password: password);

      // Verificar si el email está verificado
      final isVerified = await _authService.isEmailVerified();
      if (!isVerified) {
        _setError('Por favor verifica tu email antes de iniciar sesión');
        await _authService.signOut();
        return false;
      }

      // Cargar datos del usuario
      await _loadUserData(user.id);

      // Preguntar si quiere habilitar biometría (si está disponible)
      if (_isBiometricAvailable && !_isBiometricEnabled) {
        // Esto se manejará en la UI mostrando un diálogo
        if (kDebugMode) {
          print('💡 Sugerir habilitar biometría al usuario');
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Registra un nuevo usuario
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    String workshopId =
        'default-workshop', // TODO: Implement workshop selection
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        workshopId: workshopId,
      );

      if (user == null) {
        _setError('Error al registrar usuario');
        return false;
      }

      // Enviar email de verificación
      await _authService.sendEmailVerification();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Cierra sesión
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      // Limpiar credenciales biométricas
      await _biometricService.clearCredentials();

      // Cerrar sesión en Firebase
      await _authService.signOut();

      _currentUser = null;
      _isBiometricEnabled = false;

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Inicia sesión con biometría
  Future<bool> signInWithBiometric() async {
    try {
      _setLoading(true);
      _clearError();

      // Verificar si está habilitada
      if (!_isBiometricEnabled) {
        _setError('Biometría no habilitada');
        _setLoading(false);
        return false;
      }

      // Autenticar con huella
      final authenticated = await _biometricService.authenticate(
        reason: 'Iniciar sesión en AutoPulse',
      );

      if (!authenticated) {
        _setError('Autenticación biométrica fallida');
        _setLoading(false);
        return false;
      }

      // Verificar sesión de Firebase
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
        _setLoading(false);
        return true;
      }

      // Si no hay sesión activa, obtener email guardado
      final savedEmail = await _biometricService.getSavedEmail();
      if (savedEmail != null) {
        // Aquí en producción deberías re-autenticar con un token
        // Por ahora, si la sesión expiró, redirigir a login manual
        _setError('Sesión expirada. Por favor inicia sesión nuevamente.');
        _setLoading(false);
        return false;
      }

      _setError('No se encontraron credenciales guardadas');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Habilita la autenticación biométrica
  Future<bool> enableBiometric() async {
    try {
      _setLoading(true);
      _clearError();

      // Verificar disponibilidad
      if (!_isBiometricAvailable) {
        _setError('Biometría no disponible en este dispositivo');
        _setLoading(false);
        return false;
      }

      // Verificar que hay un usuario activo
      final user = _authService.currentUser;
      if (user == null || user.email == null) {
        _setError('No hay usuario activo');
        _setLoading(false);
        return false;
      }

      // Probar autenticación
      final authenticated = await _biometricService.authenticate(
        reason: 'Habilitar inicio de sesión con huella',
      );

      if (!authenticated) {
        _setError('Autenticación fallida');
        _setLoading(false);
        return false;
      }

      // Guardar credenciales
      await _biometricService.saveCredentials(
        email: user.email!,
        userId: user.uid,
      );
      await _biometricService.setBiometricEnabled(true);

      _isBiometricEnabled = true;
      _setLoading(false);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Deshabilita la autenticación biométrica
  Future<void> disableBiometric() async {
    try {
      _setLoading(true);
      _clearError();

      await _biometricService.clearCredentials();
      _isBiometricEnabled = false;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Envía email de verificación
  Future<bool> sendVerificationEmail() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendEmailVerification();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Verifica si el email está verificado
  Future<bool> checkEmailVerified() async {
    try {
      final isVerified = await _authService.isEmailVerified();
      if (isVerified && _authService.currentUser != null) {
        await _loadUserData(_authService.currentUser!.uid);
      }
      return isVerified;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al verificar email: $e');
      }
      return false;
    }
  }

  /// Restablece la contraseña
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email: email);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Actualiza el perfil del usuario
  Future<bool> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Recargar datos del usuario
      if (_authService.currentUser != null) {
        await _loadUserData(_authService.currentUser!.uid);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Actualiza los datos del usuario en Firestore
  Future<bool> updateUserData(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser == null) {
        _setError('No hay usuario activo');
        _setLoading(false);
        return false;
      }

      await _authService.updateUserData(data);

      // Recargar datos
      await _loadUserData(_currentUser!.id);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Obtiene el mensaje del tipo de biometría disponible
  Future<String> getBiometricTypeMessage() async {
    return await _biometricService.getBiometricTypeMessage();
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
    // Cancelar subscription al stream de autenticación
    _authStateSubscription?.cancel();

    if (kDebugMode) {
      print('✅ AuthProvider: Stream de auth cancelado');
    }

    super.dispose();
  }
}
