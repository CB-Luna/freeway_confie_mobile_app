import 'package:flutter/material.dart';
import 'app_localizations.dart';

/// Extensión para facilitar el uso de traducciones en BuildContext
extension LocalizationExtension on BuildContext {
  /// Obtiene la instancia de AppLocalizations
  AppLocalizations get tr => AppLocalizations.of(this);
  
  /// Traduce una clave
  String translate(String key) => AppLocalizations.of(this).translate(key);
  
  /// Traduce una clave con parámetros
  String translateWithParams(String key, Map<String, String> params) => 
      AppLocalizations.of(this).translateWithParams(key, params);
      
  /// Traduce una clave con parámetros posicionales
  String translateWithArgs(String key, {List<String>? args}) => 
      args != null ? AppLocalizations.of(this).translateWithArgs(key, args) : translate(key);
}
