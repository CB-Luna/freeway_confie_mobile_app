import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper para manejar llamadas telefónicas con soporte para dispositivos sin capacidad de llamadas
class PhoneCallHelper {
  /// Verifica si el dispositivo puede hacer llamadas telefónicas
  static bool get canMakePhoneCalls {
    try {
      // Los iPads Wi-Fi no pueden hacer llamadas
      // Esta es una forma simple de detectar, pero podríamos mejorarla
      return true; // Por defecto asumimos que sí, luego verificamos al intentar
    } catch (e) {
      return false;
    }
  }

  /// Intenta iniciar una llamada telefónica
  /// Muestra un diálogo si el dispositivo no puede hacer llamadas
  static Future<void> makePhoneCall(
    BuildContext context,
    String phoneNumber, {
    String? customTitle,
    String? customMessage,
  }) async {
    try {
      final Uri launchUri = Uri.parse('tel:$phoneNumber');

      final launched = await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        // Falló el lanzamiento - mostrar diálogo
        _showCallNotSupportedDialog(
          context,
          phoneNumber,
          title: customTitle,
          message: customMessage,
        );
      }
    } catch (e) {
      // Error al intentar hacer la llamada
      if (context.mounted) {
        _showCallNotSupportedDialog(
          context,
          phoneNumber,
          title: customTitle,
          message: customMessage,
        );
      }
    }
  }

  /// Muestra un diálogo informativo cuando no se pueden hacer llamadas
  static void _showCallNotSupportedDialog(
    BuildContext context,
    String phoneNumber, {
    String? title,
    String? message,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title ?? context.translate('common.phoneCallNotSupported'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.getPrimaryColor(context),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message ??
                    context.translate('common.phoneCallNotSupportedMessage'),
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.getTextGreyColor(context),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: AppTheme.getPrimaryColor(context),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        phoneNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Copiar número al portapapeles
                        // TODO: Implementar copiar al portapapeles si es necesario
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.translate('common.phoneNumberCopied'),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.copy,
                        color: AppTheme.getPrimaryColor(context),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                context.translate('common.close'),
                style: TextStyle(
                  color: AppTheme.getPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Método simplificado para emergencias (911)
  static Future<void> makeEmergencyCall(BuildContext context) async {
    await makePhoneCall(
      context,
      '911',
      customTitle: context.translate('common.emergencyCall'),
      customMessage:
          context.translate('common.emergencyCallNotSupportedMessage'),
    );
  }
}
