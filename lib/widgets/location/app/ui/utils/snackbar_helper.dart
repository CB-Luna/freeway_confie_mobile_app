import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showBlueSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  /// Muestra un mensaje de error fatal en rojo
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      duration: duration,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  /// Muestra un mensaje de advertencia en amarillo
  static void showWarningSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.amber,
      textColor:
          Colors.black87, // Texto oscuro para mejor contraste en fondo amarillo
      duration: duration,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.black87),
    );
  }

  /// Método privado para mostrar SnackBar con configuraciones personalizadas
  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    Widget? icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    // Cerrar cualquier SnackBar que esté mostrándose actualmente
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }
}
