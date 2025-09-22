// En un archivo utils/snackbar_helper.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';

// Método para calcular el offset adecuado según el dispositivo
double _calculateBottom(BuildContext context) {
  if (Platform.isIOS) {
    // En iOS, usamos un offset fijo
    return 5.0;
  } else {
    // En Android, calculamos el offset basado en MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final viewInsets = mediaQuery.viewInsets.bottom;
    final deviceHeight = mediaQuery.size.height;

    // Detectar si es un dispositivo con navegación por gestos
    final hasGestureNavigation = bottomPadding > 15;

    // Ajustar el offset según el tipo de navegación
    if (hasGestureNavigation) {
      // Si tiene navegación por gestos, necesitamos un offset mayor
      return 35.0;
    } else if (viewInsets > 0) {
      // Si el teclado está visible
      return 45.0;
    } else if (deviceHeight > 700) {
      // Para dispositivos grandes
      return 35.0;
    } else {
      // Para dispositivos más pequeños
      return 30.0;
    }
  }
}

void showAppSnackBar(
  BuildContext context,
  String message,
  Duration? duration, {
  Color? backgroundColor,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontSize: responsiveFontSizes.snackBarText(context),
        ),
      ),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: _calculateBottom(context),
      ),
      duration: duration ?? const Duration(seconds: 1),
      backgroundColor: backgroundColor,
    ),
  );
}
