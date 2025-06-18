import 'dart:io' show Platform;

import 'package:flutter/material.dart';

/// Clase utilitaria para manejar tamaños de fuente responsivos en toda la aplicación.
/// Ajusta automáticamente los tamaños de fuente basados en el ancho de la pantalla
/// y las preferencias de accesibilidad del usuario (textScaler).
class ResponsiveFontSizes {
  /// Singleton para acceso global
  static final ResponsiveFontSizes _instance = ResponsiveFontSizes._internal();
  factory ResponsiveFontSizes() => _instance;
  ResponsiveFontSizes._internal();

  /// Calcula el tamaño de fuente responsivo basado en el ancho de la pantalla y el textScaler
  /// [context] Contexto de Flutter para acceder a MediaQuery
  /// [minSize] Tamaño mínimo permitido después del escalado
  /// [maxSize] Tamaño máximo permitido después del escalado
  double getResponsiveFontSize(
    BuildContext context, {
    required double minSize,
    required double maxSize,
  }) {
    // Obtener el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Determinar el tamaño base según el ancho de la pantalla
    final baseFontSize = screenWidth <= 360 ? minSize : maxSize;

    // Obtener el factor de escala de texto del dispositivo
    var scaledSize = MediaQuery.of(context).textScaler.scale(1);

    var fontSize = baseFontSize;

    // Limitar el factor de escala a un máximo de 1.5
    if (scaledSize > 1.5) {
      scaledSize = 1.5;

      // Aplicar el factor de escala al tamaño base de la fuente según la plataforma
      if (Platform.isAndroid) {
        fontSize = baseFontSize / 1.1;
      } else if (Platform.isIOS) {
        fontSize = baseFontSize / 1.5;
      } else {
        // Para otras plataformas (web, desktop, etc.)
        fontSize = baseFontSize / 1.1;
      }
    }

    // Limitar el tamaño dentro del rango especificado
    return fontSize;
  }

  double getResponsiveFontSizeHold(
    BuildContext context, {
    required double minSize,
    required double maxSize,
  }) {
    // Obtener el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Obtener el TextScaler del dispositivo
    final textScaler = MediaQuery.of(context).textScaler;

    // Determinar el tamaño base según el ancho de la pantalla
    final baseFontSize = screenWidth <= 360 ? minSize : maxSize;

    // Ajustar el tamaño de fuente según el textScaler
    final scaledSize = textScaler.scale(baseFontSize);

    // // Esto maneja correctamente el escalado lineal y no lineal.
    final adjustedFontSizeFactor = scaledSize / baseFontSize;

    // Asignar el valor final a fontSize para usarlo en el widget Text
    final fontSize = baseFontSize / adjustedFontSizeFactor;

    // Limitar el tamaño dentro del rango especificado
    return fontSize;
  }

  // Tamaños predefinidos para diferentes elementos de la UI

  /// Tamaño para títulos principales
  double avatarName(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 28.0,
      maxSize: 32.0,
    );
  }

  /// Tamaño para títulos principales
  double avatarIcon(BuildContext context) {
    return getResponsiveFontSizeHold(
      context,
      minSize: 12.0,
      maxSize: 13.0,
    );
  }

  /// Tamaño para títulos de la cabecera
  double titleHeader(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 20.0,
      maxSize: 22.0,
    );
  }

  /// Tamaño para títulos de la cabecera
  double backText(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 16.0,
      maxSize: 18.0,
    );
  }

  /// Tamaño para títulos principales
  double titleLarge(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 20.0,
      maxSize: 22.0,
    );
  }

  /// Tamaño para subtítulos
  double titleMedium(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 18.0,
      maxSize: 20.0,
    );
  }

  /// Tamaño para títulos pequeños
  double titleSmall(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 14.0,
      maxSize: 16.0,
    );
  }

  /// Tamaño para texto de cuerpo grande
  double bodyLarge(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 14.0,
      maxSize: 16.0,
    );
  }

  /// Tamaño para texto de cuerpo normal
  double bodyMedium(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 12.0,
      maxSize: 14.0,
    );
  }

  /// Tamaño para texto de cuerpo pequeño
  double bodySmall(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 10.0,
      maxSize: 12.0,
    );
  }

  /// Tamaño para botones
  double button(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 12.0,
      maxSize: 14.0,
    );
  }

  /// Tamaño para botones pequeños
  double buttonSmall(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 10.0,
      maxSize: 12.0,
    );
  }

  /// Tamaño para etiquetas
  double label(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 10.0,
      maxSize: 12.0,
    );
  }

  /// Tamaño para etiquetas
  double labelMedium(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 11.0,
      maxSize: 13.0,
    );
  }

  /// Tamaño para etiquetas
  double labelLarge(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 12.0,
      maxSize: 14.0,
    );
  }

  /// Tamaño para texto de barra de navegación
  double navBar(BuildContext context) {
    return getResponsiveFontSizeHold(
      context,
      minSize: 9.0,
      maxSize: 11.0,
    );
  }

  /// Tamaño para tarjetas de póliza - título
  double policyCardTitle(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 13.0,
      maxSize: 15.0,
    );
  }

  /// Tamaño para tarjetas de póliza - subtítulo
  double policyCardSubtitle(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 11.0,
      maxSize: 13.0,
    );
  }

  /// Tamaño para tarjetas de póliza - botones
  double policyCardButton(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 9.0,
      maxSize: 11.0,
    );
  }

  /// Tamaño para tarjetas de póliza - botones
  double policyCardButtonBig(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 11.0,
      maxSize: 13.0,
    );
  }

  double bodyTextLocation(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 12.0,
      maxSize: 14.0,
    );
  }

  double buttonTextLocation(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 12.0,
      maxSize: 14.0,
    );
  }

  double buttonTextLocationMedium(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 12.0,
      maxSize: 14.0,
    );
  }

  double snackBarText(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 12.0,
      maxSize: 14.0,
    );
  }

  double helperText(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 11.0,
      maxSize: 13.0,
    );
  }

  double errorText(BuildContext context) {
    return getResponsiveFontSize(
      context,
      minSize: 11.0,
      maxSize: 13.0,
    );
  }
}

/// Acceso global a la instancia de ResponsiveFontSizes
final responsiveFontSizes = ResponsiveFontSizes();
