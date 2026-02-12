import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';

/// Provider para gestionar configuraciones de la app
/// Maneja idioma, tema y otras preferencias del usuario
class SettingsProvider extends ChangeNotifier {
  Locale _locale = const Locale('es'); // Español por defecto
  bool _isDarkMode = true; // Siempre dark mode (requerimiento)

  // Getters
  Locale get locale => _locale;
  bool get isDarkMode => _isDarkMode;
  String get languageCode => _locale.languageCode;

  SettingsProvider() {
    _loadSettings();
  }

  /// Carga las configuraciones guardadas
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar idioma
      final savedLanguage = prefs.getString(AppConstants.languageKey);
      if (savedLanguage != null) {
        _locale = Locale(savedLanguage);
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al cargar configuraciones: $e');
      }
    }
  }

  /// Cambia el idioma de la aplicación
  Future<void> changeLanguage(String languageCode) async {
    try {
      if (!AppConstants.supportedLanguages.contains(languageCode)) {
        if (kDebugMode) {
          print('⚠️ Idioma no soportado: $languageCode');
        }
        return;
      }

      _locale = Locale(languageCode);

      // Guardar preferencia
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.languageKey, languageCode);

      notifyListeners();

      if (kDebugMode) {
        print('✅ Idioma cambiado a: $languageCode');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al cambiar idioma: $e');
      }
    }
  }

  /// Obtiene el nombre del idioma en su propio idioma
  String getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ru':
        return 'Русский';
      default:
        return code;
    }
  }

  /// Obtiene todos los idiomas soportados con sus nombres
  Map<String, String> getSupportedLanguages() {
    return {
      for (var code in AppConstants.supportedLanguages)
        code: getLanguageName(code),
    };
  }

  /// Restablece configuraciones a valores por defecto
  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.languageKey);

      _locale = const Locale('es');
      _isDarkMode = true;

      notifyListeners();

      if (kDebugMode) {
        print('✅ Configuraciones restablecidas');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al restablecer configuraciones: $e');
      }
    }
  }
}
