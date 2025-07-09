import 'package:add_to_google_wallet/add_to_google_wallet.dart';
import 'package:flutter/material.dart';
import 'package:freeway_app/data/models/auth/policy_model.dart';
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
    required PolicyModel policy,
    VoidCallback? onSuccess,
    VoidCallback? onCanceled,
    Function(Object)? onError,
  }) async {
    // Generar un ID único para el pase
    final String passId = const Uuid().v4();

    // Fechas estáticas para demo
    final effectiveDateStr = policy.effectiveDate;
    final expirationDateStr = policy.expirationDate;

    // Crear un JSON simplificado para la tarjeta de seguro
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
            "logo": {
              "sourceUri": {
                "uri": "https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/pass_google_logo.jpg"
              }
            },
            "cardTitle": {
              "defaultValue": {
                "language": "${context.translate('idCard.languageCode')}-${context.translate('idCard.countryCode')}",
                "value": "Freeway Insurance"
              }
            },
            "subheader": {
              "defaultValue": {
                "language": "${context.translate('idCard.languageCode')}-${context.translate('idCard.countryCode')}",
                "value": "Named Insured"
              }
            },
            "header": {
              "defaultValue": {
                "language": "${context.translate('idCard.languageCode')}-${context.translate('idCard.countryCode')}",
                "value": "${policy.insuredName}"
              }
            },
            "textModulesData": [
              {
                "id": "carrier",
                "header": "Carrier",
                "body": "${policy.carrierName}"
              },
              {
                "id": "policy_number",
                "header": "Policy Number",
                "body": "${policy.policyNumber}"
              },
              {
                "id": "state",
                "header": "State",
                "body": "${user.state}"
              },
              {
                "id": "effective_date",
                "header": "Effective Date",
                "body": "$effectiveDateStr"
              },
              {
                "id": "expiration_date",
                "header": "Expiration Date",
                "body": "$expirationDateStr"
              }
            ],
            "barcode": {
              "type": "CODE_128",
              "value": "${policy.policyNumber}",
              "alternateText": "${context.translate('idCard.notProofOfCoverage')}"
            },
            "hexBackgroundColor": "#ffffff",
            "heroImage": {
              "sourceUri": {
                "uri": "https://encycolorpedia.es/0000ff.png"
              }
            }
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
