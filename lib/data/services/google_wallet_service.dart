import 'package:add_to_google_wallet/add_to_google_wallet.dart';
import 'package:flutter/material.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:uuid/uuid.dart';

/// Servicio para manejar la integración con Google Wallet
class GoogleWalletService {
  // Constantes para Google Wallet
  static const String _passClass = 'googleWalletDemo';
  static const String _issuerId = '3388000000022925653';

  // Instancia de AddToGoogleWallet
  final AddToGoogleWallet _addToGoogleWallet = AddToGoogleWallet();

  /// Verifica si la API de Google Wallet está disponible en el dispositivo
  Future<bool> isGoogleWalletApiAvailable() async {
    return await _addToGoogleWallet.isGoogleWalletApiAvailable;
  }

  /// Agrega una tarjeta de seguro a Google Wallet
  ///
  /// [context] - Contexto de la aplicación para mostrar mensajes
  /// [user] - Información del usuario para la tarjeta
  /// [onSuccess] - Callback cuando la operación es exitosa
  /// [onCanceled] - Callback cuando la operación es cancelada
  /// [onError] - Callback cuando ocurre un error
  Future<void> addInsuranceCardToGoogleWallet({
    required BuildContext context,
    required User user,
    VoidCallback? onSuccess,
    VoidCallback? onCanceled,
    Function(Object)? onError,
  }) async {
    // Generar un ID único para el pase
    final String passId = const Uuid().v4();

    // Crear un JSON con los datos de la tarjeta de seguro
    final String passJson = """
    {
      "iss": "${user.email ?? 'info@freewayinsurance.com'}",
      "aud": "google",
      "typ": "savetowallet",
      "origins": [],
      "payload": {
        "genericObjects": [
          {
            "id": "$_issuerId.$passId",
            "classId": "$_issuerId.$_passClass",
            "genericType": "GENERIC_TYPE_UNSPECIFIED",
            "hexBackgroundColor": "#0066CC",
            "logo": {
              "sourceUri": {
                "uri": "https://danielsuarezracing.com/wp-content/uploads/2021/04/IMG_3217.jpg"
              }
            },
            "cardTitle": {
              "defaultValue": {
                "language": "${user.languageCode ?? 'en'}",
                "value": "Freeway Insurance"
              }
            },
            "subheader": {
              "defaultValue": {
                "language": "${user.languageCode ?? 'en'}",
                "value": "${context.translate('idCard.policyNumberLabel')}"
              }
            },
            "header": {
              "defaultValue": {
                "language": "${user.languageCode ?? 'en'}",
                "value": "${user.policyNumber}"
              }
            },
            "barcode": {
              "type": "QR_CODE",
              "value": "${user.policyNumber}"
            },
            "heroImage": {
              "sourceUri": {
                "uri": "https://danielsuarezracing.com/wp-content/uploads/2021/04/IMG_3217.jpg"
              }
            },
            "textModulesData": [
              {
                "header": "${context.translate('idCard.carrier')}",
                "body": "${user.carrierName ?? 'Freeway Insurance'}",
                "id": "carrier"
              },
              {
                "header": "${context.translate('idCard.state')}",
                "body": "${user.state}",
                "id": "state"
              },
              {
                "header": "${context.translate('idCard.name')}",
                "body": "${user.fullName}",
                "id": "name"
              }
            ]
          }
        ]
      }
    }
    """;

    try {
      // Verificar si Google Wallet API está disponible
      final bool available = await isGoogleWalletApiAvailable();

      if (available) {
        // Agregar a Google Wallet
        await _addToGoogleWallet.saveLoyaltyPass(
          pass: passJson,
          onSuccess: onSuccess,
          onCanceled: onCanceled,
          onError: onError,
        );
      } else {
        // Google Wallet no está disponible
        if (onError != null) {
          onError(
            Exception(
              'Google Wallet no está disponible en este dispositivo',
            ),
          );
        }
      }
    } catch (e) {
      // Manejar errores
      if (onError != null) {
        onError(e);
      }
    }
  }
}
