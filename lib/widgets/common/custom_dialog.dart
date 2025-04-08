import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';

/// Un diálogo personalizado reutilizable que se puede usar en toda la aplicación.
/// 
/// Este widget permite mostrar un diálogo con título, contenido y botones personalizables.
class CustomDialog {
  /// Muestra un diálogo personalizado con opciones configurables.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de construcción actual.
  /// - [title]: El título del diálogo.
  /// - [message]: El contenido o mensaje del diálogo.
  /// - [positiveButtonText]: El texto para el botón positivo (por defecto es 'OK').
  /// - [negativeButtonText]: El texto para el botón negativo (opcional).
  /// - [barrierDismissible]: Si el diálogo se puede cerrar tocando fuera de él (opcional, por defecto es false).
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String positiveButtonText = 'OK',
    String? negativeButtonText,
    bool barrierDismissible = false,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: <Widget>[
            if (negativeButtonText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  negativeButtonText,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                positiveButtonText,
                style: const TextStyle(
                  color: Color(0xFF0046B9),
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
