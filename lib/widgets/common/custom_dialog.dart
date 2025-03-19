import 'package:flutter/material.dart';

/// Un diálogo personalizado reutilizable que se puede usar en toda la aplicación.
/// 
/// Este widget permite mostrar un diálogo con título, contenido y botones personalizables.
class CustomDialog {
  /// Muestra un diálogo personalizado con opciones configurables.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de construcción actual.
  /// - [title]: El título del diálogo.
  /// - [content]: El contenido o mensaje del diálogo.
  /// - [cancelText]: El texto para el botón de cancelar (opcional, por defecto es 'Cancel').
  /// - [confirmText]: El texto para el botón de confirmar (opcional, por defecto es 'Confirm').
  /// - [onCancel]: Función a ejecutar cuando se presiona el botón cancelar.
  /// - [onConfirm]: Función a ejecutar cuando se presiona el botón confirmar.
  /// - [barrierDismissible]: Si el diálogo se puede cerrar tocando fuera de él (opcional, por defecto es false).
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
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
            content,
            style: const TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      if (onCancel != null) {
                        onCancel();
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      if (onConfirm != null) {
                        onConfirm();
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        color: Color(0xFF0046B9),
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
