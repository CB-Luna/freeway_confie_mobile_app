import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:freeway_app/data/models/auth/policy_model.dart';
import 'package:freeway_app/data/models/wallet/wallet_payload.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Servicio para manejar la integración con Google Wallet
class GoogleWalletService {
  // URL del endpoint para Google Wallet
  static const String _apiUrl =
      'https://confie-wallet-api-np.azurewebsites.net/DownloadGooglePassTask';
  static const String _apiKey = 'GfhGdjdx3rfGBBFkf';

  // Headers para la petición
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'X-API-KEY': _apiKey,
  };

  /// Verifica si Google Wallet está disponible en el dispositivo
  /// En este caso, simplemente verificamos si estamos en Android
  Future<bool> isGoogleWalletApiAvailable() async {
    return true; // Siempre retornamos true ya que usaremos URL para abrir el pase
  }

  /// Verifica si Google Wallet está disponible y muestra un mensaje apropiado
  ///
  /// [context] - Contexto para mostrar mensajes
  /// Retorna true si Google Wallet está disponible, false en caso contrario
  Future<bool> checkGoogleWalletAvailability(BuildContext context) async {
    // Siempre retornamos true ya que usaremos URL para abrir el pase
    return true;
  }

  /// Agrega una tarjeta de seguro a Google Wallet
  ///
  /// [context] - Contexto de la aplicación para mostrar mensajes
  /// [user] - Información del usuario para la tarjeta
  /// [policy] - Información de la póliza para la tarjeta
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
    try {
      developer.log('=== INICIANDO PROCESO DE GOOGLE WALLET ===');
      developer.log('Usuario: ${user.fullName}');
      developer.log('Póliza: ${policy.policyNumber}');

      // Crear la carga útil para el servicio de Google Wallet
      final payload = WalletPayload.fromUserAndPolicy(user, policy);

      // Convertir a JSON para la petición
      final String payloadJson = jsonEncode(payload.toJson());
      developer.log('Payload: $payloadJson');

      // Realizar la petición al servicio
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: _headers,
        body: payloadJson,
      );

      // Verificar la respuesta
      if (response.statusCode == 200) {
        // Decodificar la respuesta
        final responseData = jsonDecode(response.body);
        final walletResponse = GoogleWalletResponse.fromJson(responseData);

        developer.log('Respuesta recibida: ${response.body}');
        developer.log('URL del pase: ${walletResponse.googlePassUrl}');

        // Abrir la URL del pase
        final Uri url = Uri.parse(walletResponse.googlePassUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          if (onSuccess != null) onSuccess();
        } else {
          if (context.mounted) {
            throw Exception(
                '${context.translate('common.error')}: ${context.translate('idCard.cancelToGoogleWallet')}');
          }
        }
      } else {
        // Error en la petición
        developer.log('Error en la petición: ${response.statusCode}');
        developer.log('Respuesta: ${response.body}');
        if (context.mounted) {
          throw Exception(
              '${context.translate('common.error')}: ${response.statusCode} ${response.reasonPhrase}');
        }
      }
    } catch (e, stackTrace) {
      // Manejar errores
      developer
          .log('=== ERROR INESPERADO en addInsuranceCardToGoogleWallet ===');
      developer.log('Error: $e');
      developer.log('Tipo de error: ${e.runtimeType}');
      developer.log('Stack trace: $stackTrace');
      if (onError != null) {
        onError(e);
      }
    } finally {
      developer.log('=== PROCESO DE GOOGLE WALLET FINALIZADO ===');
    }
  }
}
