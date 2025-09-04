import 'package:flutter/material.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

/// Utilidad para manejar los logos de las pólizas
class PolicyLogoUtils {
  /// Lista de nombres de logos disponibles en assets/home/idcardicons/logo_type
  static const List<String> availableLogos = [
    'dairyland',
    // Agregar más logos aquí cuando estén disponibles
  ];

  /// Verifica si existe un logo para el nombre del programa dado
  static bool hasLogoForProgram(String programName) {
    final normalizedName = programName.toLowerCase().replaceAll(' ', '_');
    return availableLogos.contains(normalizedName);
  }

  /// Obtiene el widget de imagen para el logo de la póliza
  /// Si no existe un logo específico, devuelve el logo de Freeway
  static Widget getPolicyLogo(
    BuildContext context,
    String? logoUrl, {
    double? width,
    double? height,
  }) {
    if (logoUrl != null) {
      return Image.network(
        logoUrl,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          // Si hay un error al cargar la imagen, mostrar el logo de Freeway
          return Image.asset(
            AppTheme.getFreewayLogoType(context),
            width: width,
            height: height,
          );
        },
      );
    } else {
      // Si no hay logo específico, mostrar el logo de Freeway
      return Image.asset(
        AppTheme.getFreewayLogoType(context),
        width: width,
        height: height,
      );
    }
  }
}
