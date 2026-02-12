import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'translations/es.dart';
import 'translations/en.dart';

class LocalizationHelper {
  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return _getLocalization(locale);
  }

  static AppLocalizations _getLocalization(String languageCode) {
    switch (languageCode) {
      case 'es':
        return AppLocalizationsEs();
      case 'en':
        return AppLocalizationsEn();
      // TODO: Add more languages when created
      case 'pt':
      case 'fr':
      case 'de':
      case 'it':
      case 'zh':
      case 'ja':
      case 'ru':
        return AppLocalizationsEn(); // Fallback to English
      default:
        return AppLocalizationsEs(); // Default to Spanish
    }
  }

  static List<Locale> get supportedLocales {
    return const [
      Locale('es'), // Spanish
      Locale('en'), // English
      Locale('pt'), // Portuguese
      Locale('fr'), // French
      Locale('de'), // German
      Locale('it'), // Italian
      Locale('zh'), // Chinese
      Locale('ja'), // Japanese
      Locale('ru'), // Russian
    ];
  }
}
