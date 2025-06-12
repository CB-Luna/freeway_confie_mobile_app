import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

class LoadingView extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? textColor;

  const LoadingView({
    super.key,
    this.message = 'Loading...',
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
          Stack(
            alignment: Alignment.center,
            children: [
              // Círculo base blanco
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      backgroundColor ?? AppTheme.getBackgroundColor(context),
                  shape: BoxShape.circle,
                ),
              ),
              // Animación de onda azul
              SpinKitWaveSpinner(
                color: AppTheme.getPrimaryColor(context),
                trackColor: AppTheme.getGreenColor(context),
                waveColor: AppTheme.getGreenColor(context),
                curve: Curves.decelerate,
                size: 60.0,
                duration: const Duration(milliseconds: 1500),
              ),
              // Imagen del logo
              Image.asset(
                'assets/loading/freeway_logo.png',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (message.isNotEmpty)
            Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor ?? AppTheme.getTitleTextColor(context),
                    fontSize: responsiveFontSizes.bodyMedium(context),
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
    Color? indicatorColor = Colors.blue,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: overlayColor,
        child: LoadingView(
          message: message,
          backgroundColor: backgroundColor,
          indicatorColor: indicatorColor,
          textColor: AppTheme.getTitleTextColor(context),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }
}
