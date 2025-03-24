import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? textColor;

  const LoadingView({
    super.key,
    this.message = 'Cargando...',
    this.backgroundColor,
    this.indicatorColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              indicatorColor ?? Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          if (message.isNotEmpty)
            Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor ?? Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Muestra un overlay con un indicador de carga
  ///
  /// Retorna un OverlayEntry que debe ser removido cuando se complete la operación
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final overlay = LoadingView.showOverlay(context, message: 'Cargando...');
  /// // ... realizar operación ...
  /// overlay.remove(); // Remover el overlay cuando termine
  /// ```
  static OverlayEntry showOverlay(
    BuildContext context, {
    String message = 'Cargando...',
    Color overlayColor = Colors.black54,
    Color? indicatorColor,
    Color? backgroundColor = Colors.white,
    Color? textColor = Colors.black87,
  }) {
    final overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: overlayColor,
        child: LoadingView(
          message: message,
          backgroundColor: backgroundColor,
          indicatorColor: indicatorColor ?? Colors.blue,
          textColor: textColor,
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }
}
