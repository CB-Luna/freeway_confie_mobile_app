import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar las preferencias relacionadas con los diálogos web
class WebDialogService {
  static const String _webDialogShownKey = 'web_dialog_shown';

  /// Verifica si el diálogo web ya se ha mostrado
  Future<bool> hasWebDialogBeenShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_webDialogShownKey) ?? false;
    } catch (e) {
      debugPrint('Error al obtener preferencia de diálogo web: $e');
      return false;
    }
  }

  /// Marca el diálogo web como mostrado
  Future<bool> setWebDialogShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_webDialogShownKey, true);
    } catch (e) {
      debugPrint('Error al guardar preferencia de diálogo web: $e');
      return false;
    }
  }

  /// Reinicia el estado del diálogo web (para pruebas)
  Future<bool> resetWebDialogShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_webDialogShownKey, false);
    } catch (e) {
      debugPrint('Error al reiniciar preferencia de diálogo web: $e');
      return false;
    }
  }
}
