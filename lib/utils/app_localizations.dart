import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clase para manejar las traducciones de la aplicación
class AppLocalizations {
  final Locale locale;
  Map<String, dynamic> _localizedStrings = {};

  AppLocalizations(this.locale);

  // Método estático para obtener la instancia de AppLocalizations
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Método para cargar los archivos de traducción
  Future<bool> load() async {
    // Cargar el archivo JSON correspondiente al idioma
    final jsonString = await rootBundle.loadString('assets/i18n/${locale.languageCode}_${locale.countryCode}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap;
    return true;
  }

  // Método para obtener una traducción por clave
  String translate(String key) {
    // Dividir la clave por puntos para acceder a objetos anidados
    final keys = key.split('.');
    dynamic value = _localizedStrings;

    // Navegar por el objeto JSON para encontrar la traducción
    for (var k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Devolver la clave si no se encuentra la traducción
      }
    }

    return value.toString();
  }

  // Método para obtener una traducción con parámetros
  String translateWithParams(String key, Map<String, String> params) {
    String translation = translate(key);
    
    // Reemplazar los parámetros en la traducción
    params.forEach((paramKey, paramValue) {
      translation = translation.replaceAll('{$paramKey}', paramValue);
    });
    
    return translation;
  }

  // Método para obtener una traducción con parámetros posicionales
  String translateWithArgs(String key, List<String> args) {
    String translation = translate(key);
    
    // Reemplazar los parámetros posicionales en la traducción
    for (int i = 0; i < args.length; i++) {
      translation = translation.replaceAll('{$i}', args[i]);
    }
    
    return translation;
  }
}

/// Delegado para cargar las traducciones
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  // Verificar si el idioma está soportado
  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  // Cargar las traducciones
  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  // Recargar cuando cambie el idioma
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

// Instancia estática del delegado para facilitar su uso
const AppLocalizationsDelegate delegate = AppLocalizationsDelegate();
