import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';

/// Servicio para autenticación biométrica (huella digital, Face ID)
/// Permite acceso rápido después del login inicial con email/password
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Verifica si el dispositivo tiene capacidad biométrica
  Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      return canCheck && isDeviceSupported;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al verificar biometría: $e');
      }
      return false;
    }
  }

  /// Obtiene la lista de biometrías disponibles en el dispositivo
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (kDebugMode) {
        print('✅ Biometrías disponibles: $availableBiometrics');
      }

      return availableBiometrics;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener biometrías: $e');
      }
      return [];
    }
  }

  /// Autentica al usuario usando biometría
  /// [reason] - Mensaje mostrado al usuario (ej: "Iniciar sesión en AutoPulse")
  /// Retorna true si la autenticación fue exitosa
  Future<bool> authenticate({required String reason}) async {
    try {
      // Verificar capacidad biométrica
      final canAuthenticate = await canCheckBiometrics();
      if (!canAuthenticate) {
        if (kDebugMode) {
          print('⚠️ Dispositivo no soporta biometría');
        }
        return false;
      }

      // Intentar autenticación
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true, // Mantener diálogo hasta que usuario responda
          biometricOnly: true, // Solo biometría, no PIN/patrón
        ),
      );

      if (kDebugMode) {
        print(
          authenticated
              ? '✅ Autenticación biométrica exitosa'
              : '❌ Autenticación biométrica fallida',
        );
      }

      return authenticated;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('❌ Error en autenticación biométrica: ${e.message}');
      }

      // Manejar códigos de error específicos
      switch (e.code) {
        case 'NotAvailable':
          if (kDebugMode) print('⚠️ Biometría no disponible');
          break;
        case 'NotEnrolled':
          if (kDebugMode)
            print('⚠️ No hay biometría registrada en el dispositivo');
          break;
        case 'LockedOut':
          if (kDebugMode) print('⚠️ Biometría bloqueada temporalmente');
          break;
        case 'PermanentlyLockedOut':
          if (kDebugMode) print('⚠️ Biometría bloqueada permanentemente');
          break;
        default:
          if (kDebugMode) print('⚠️ Error desconocido: ${e.code}');
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado en autenticación biométrica: $e');
      }
      return false;
    }
  }

  /// Verifica si el usuario tiene habilitada la autenticación biométrica
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al verificar biometría habilitada: $e');
      }
      return false;
    }
  }

  /// Habilita o deshabilita la autenticación biométrica
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.biometricEnabledKey, enabled);

      if (kDebugMode) {
        print('✅ Biometría ${enabled ? "habilitada" : "deshabilitada"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al configurar biometría: $e');
      }
    }
  }

  /// Guarda las credenciales del usuario para uso con biometría
  /// IMPORTANTE: Solo para desarrollo. En producción usar Keychain/Keystore
  Future<void> saveCredentials({
    required String email,
    required String userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.savedEmailKey, email);
      await prefs.setString(AppConstants.savedUserIdKey, userId);

      if (kDebugMode) {
        print('✅ Credenciales guardadas para biometría');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al guardar credenciales: $e');
      }
    }
  }

  /// Obtiene el email guardado
  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.savedEmailKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener email guardado: $e');
      }
      return null;
    }
  }

  /// Obtiene el userId guardado
  Future<String?> getSavedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.savedUserIdKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener userId guardado: $e');
      }
      return null;
    }
  }

  /// Elimina las credenciales guardadas (al cerrar sesión)
  Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.savedEmailKey);
      await prefs.remove(AppConstants.savedUserIdKey);
      await prefs.remove(AppConstants.biometricEnabledKey);

      if (kDebugMode) {
        print('✅ Credenciales biométricas eliminadas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al eliminar credenciales: $e');
      }
    }
  }

  /// Obtiene un mensaje localizado según el tipo de biometría disponible
  Future<String> getBiometricTypeMessage() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.isEmpty) {
      return 'Autenticación biométrica';
    }

    if (biometrics.contains(BiometricType.face)) {
      return 'Reconocimiento facial';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Huella digital';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Escaneo de iris';
    } else {
      return 'Autenticación biométrica';
    }
  }

  /// Verifica si la biometría está disponible y configurada en el dispositivo
  Future<bool> isBiometricAvailableAndConfigured() async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) return false;

      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al verificar biometría: $e');
      }
      return false;
    }
  }

  /// Solicita configurar biometría (muestra diálogo del sistema si no está configurada)
  Future<bool> requestBiometricSetup() async {
    try {
      final isAvailable = await isBiometricAvailableAndConfigured();

      if (!isAvailable) {
        if (kDebugMode) {
          print(
            '⚠️ Solicitar al usuario configurar biometría en ajustes del dispositivo',
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al solicitar configuración biométrica: $e');
      }
      return false;
    }
  }
}
