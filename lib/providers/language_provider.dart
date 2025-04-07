import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor para manejar el idioma de la aplicación
class LanguageProvider with ChangeNotifier {
  // Clave para guardar el idioma en SharedPreferences
  static const String _languageKey = 'app_language';
  
  // Idioma actual
  Locale _currentLocale = const Locale('en', 'US');
  
  // Idiomas soportados
  final List<Locale> _supportedLocales = [
    const Locale('en', 'US'), // Inglés
    const Locale('es', 'ES'), // Español
  ];

  // Nombres de los idiomas para mostrar en la UI
  final Map<String, String> _languageNames = {
    'en_US': 'English',
    'es_ES': 'Español',
  };

  // Getters
  Locale get currentLocale => _currentLocale;
  List<Locale> get supportedLocales => _supportedLocales;
  Map<String, String> get languageNames => _languageNames;

  // Constructor
  LanguageProvider() {
    _loadSavedLanguage();
  }

  // Cargar el idioma guardado en SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage != null) {
      final parts = savedLanguage.split('_');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
        notifyListeners();
      }
    }
  }

  // Cambiar el idioma de la aplicación
  Future<void> changeLanguage(Locale locale) async {
    if (!_isLocaleSupported(locale)) return;
    
    _currentLocale = locale;
    
    // Guardar el idioma seleccionado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, '${locale.languageCode}_${locale.countryCode}');
    
    notifyListeners();
  }

  // Verificar si el idioma está soportado
  bool _isLocaleSupported(Locale locale) {
    return _supportedLocales.any(
      (supportedLocale) => 
        supportedLocale.languageCode == locale.languageCode && 
        supportedLocale.countryCode == locale.countryCode
    );
  }

  // Obtener el nombre del idioma actual
  String getCurrentLanguageName() {
    final localeKey = '${_currentLocale.languageCode}_${_currentLocale.countryCode}';
    return _languageNames[localeKey] ?? 'Unknown';
  }
}
