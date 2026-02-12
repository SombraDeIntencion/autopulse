import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/biometric_auth_service.dart';

/// Ejemplo de integración entre Firebase Auth y Biometric Auth
///
/// FLUJO DE AUTENTICACIÓN:
/// 1. Primera vez: Usuario se registra/inicia sesión con email/password
/// 2. Sistema pregunta si quiere habilitar biometría
/// 3. Si acepta, se guardan credenciales y se habilita flag
/// 4. Próximos accesos: Si biometría está habilitada, usa huella directamente
/// 5. Si falla biometría, puede usar email/password como respaldo

class AuthIntegrationExample {
  final AuthService _authService = AuthService();
  final BiometricAuthService _biometricService = BiometricAuthService();

  /// CASO 1: Login inicial con email/password
  /// Después del login exitoso, preguntar si quiere habilitar biometría
  Future<bool> initialLogin({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login con Firebase
      final user = await _authService.signIn(email: email, password: password);

      // 2. Login exitoso - Preguntar si quiere habilitar biometría
      final biometricAvailable = await _biometricService
          .isBiometricAvailableAndConfigured();

      if (biometricAvailable) {
        // Aquí mostrarías un diálogo preguntando al usuario
        // Por ahora, asumimos que acepta
        final userData = await _authService.getCurrentUserData();
        if (userData != null) {
          await _setupBiometricAuth(email, userData.id);
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error en login inicial: $e');
      return false;
    }
  }

  /// CASO 2: Login con biometría (accesos posteriores)
  /// Si está habilitada, intenta autenticar con huella
  Future<bool> biometricLogin() async {
    try {
      // 1. Verificar si biometría está habilitada
      final isEnabled = await _biometricService.isBiometricEnabled();
      if (!isEnabled) {
        if (kDebugMode) print('⚠️ Biometría no habilitada');
        return false;
      }

      // 2. Obtener email guardado
      final savedEmail = await _biometricService.getSavedEmail();
      if (savedEmail == null) {
        if (kDebugMode) print('⚠️ No hay email guardado');
        return false;
      }

      // 3. Autenticar con biometría
      final authenticated = await _biometricService.authenticate(
        reason: 'Iniciar sesión en AutoPulse',
      );

      if (!authenticated) {
        if (kDebugMode) print('❌ Autenticación biométrica fallida');
        return false;
      }

      // 4. Biometría exitosa - Verificar sesión de Firebase
      // Si ya hay sesión activa, solo validamos
      final currentUser = _authService.currentUser;

      if (currentUser != null && currentUser.email == savedEmail) {
        if (kDebugMode) print('✅ Login biométrico exitoso (sesión existente)');
        return true;
      }

      // Si no hay sesión, aquí deberías re-autenticar con Firebase
      // NOTA: Para producción, usa refresh tokens o similar
      if (kDebugMode) print('✅ Login biométrico exitoso');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error en login biométrico: $e');
      return false;
    }
  }

  /// CASO 3: Habilitar biometría después del login
  Future<bool> enableBiometricAuth() async {
    try {
      // 1. Verificar disponibilidad
      final available = await _biometricService
          .isBiometricAvailableAndConfigured();
      if (!available) {
        if (kDebugMode) print('⚠️ Biometría no disponible en este dispositivo');
        return false;
      }

      // 2. Probar autenticación
      final authenticated = await _biometricService.authenticate(
        reason: 'Habilitar inicio de sesión con huella',
      );

      if (!authenticated) {
        if (kDebugMode) print('❌ Autenticación fallida');
        return false;
      }

      // 3. Guardar credenciales
      final user = _authService.currentUser;
      if (user == null || user.email == null) {
        if (kDebugMode) print('⚠️ No hay usuario activo');
        return false;
      }

      await _setupBiometricAuth(user.email!, user.uid);
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error al habilitar biometría: $e');
      return false;
    }
  }

  /// CASO 4: Deshabilitar biometría
  Future<void> disableBiometricAuth() async {
    try {
      await _biometricService.clearCredentials();
      if (kDebugMode) print('✅ Biometría deshabilitada');
    } catch (e) {
      if (kDebugMode) print('❌ Error al deshabilitar biometría: $e');
    }
  }

  /// CASO 5: Logout (limpiar todo)
  Future<void> logout() async {
    try {
      // 1. Limpiar credenciales biométricas
      await _biometricService.clearCredentials();

      // 2. Cerrar sesión de Firebase
      await _authService.signOut();

      if (kDebugMode) print('✅ Sesión cerrada completamente');
    } catch (e) {
      if (kDebugMode) print('❌ Error en logout: $e');
    }
  }

  /// Método auxiliar para configurar biometría
  Future<void> _setupBiometricAuth(String email, String userId) async {
    await _biometricService.saveCredentials(email: email, userId: userId);
    await _biometricService.setBiometricEnabled(true);

    if (kDebugMode) print('✅ Biometría configurada para: $email');
  }

  /// Verifica estado de biometría
  Future<Map<String, dynamic>> checkBiometricStatus() async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    final isAvailable = await _biometricService
        .isBiometricAvailableAndConfigured();
    final savedEmail = await _biometricService.getSavedEmail();
    final biometricType = await _biometricService.getBiometricTypeMessage();

    return {
      'enabled': isEnabled,
      'available': isAvailable,
      'savedEmail': savedEmail,
      'biometricType': biometricType,
    };
  }
}

/// EJEMPLO DE USO EN LA UI:
/// 
/// ```dart
/// // En LoginPage
/// final authIntegration = AuthIntegrationExample();
/// 
/// // Botón de login con email/password
/// onPressed: () async {
///   final success = await authIntegration.initialLogin(
///     email: emailController.text,
///     password: passwordController.text,
///   );
///   if (success) {
///     // Navegar a home
///   }
/// }
/// 
/// // Botón de login con huella (mostrar solo si está habilitada)
/// onPressed: () async {
///   final success = await authIntegration.biometricLogin();
///   if (success) {
///     // Navegar a home
///   } else {
///     // Mostrar login con email/password como respaldo
///   }
/// }
/// 
/// // En Settings
/// // Switch para habilitar/deshabilitar biometría
/// Switch(
///   value: biometricEnabled,
///   onChanged: (value) async {
///     if (value) {
///       await authIntegration.enableBiometricAuth();
///     } else {
///       await authIntegration.disableBiometricAuth();
///     }
///   },
/// )
/// ```
