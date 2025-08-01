import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:freeway_app/data/models/auth/policy_model.dart';
import 'package:freeway_app/data/models/wallet/wallet_payload.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Servicio para manejar la integración con Apple Wallet
class AppleWalletService {
  // URL del endpoint para Apple Wallet
  static const String _apiUrl =
      'https://confie-wallet-api-np.azurewebsites.net/DownloadApplePassTask';
  static const String _apiKey = 'GfhGdjdx3rfGBBFkf';

  // Headers para la petición
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'X-API-KEY': _apiKey,
  };

  /// Verifica si Apple Wallet está disponible en el dispositivo
  Future<bool> isAppleWalletAvailable() async {
    if (!Platform.isIOS) return false;

    try {
      // FlutterWalletCard no tiene un método directo para verificar disponibilidad
      // Asumimos que está disponible en iOS 9.0+ (requisito del paquete)
      return true;
    } catch (e) {
      debugPrint('Error al verificar disponibilidad de Apple Wallet: $e');
      return false;
    }
  }

  /// Añade una tarjeta de seguro a Apple Wallet usando el nuevo endpoint
  ///
  /// Este método llama al endpoint para generar un archivo .pkpass y lo añade a Apple Wallet.
  ///
  /// [context] - Contexto de la aplicación para mostrar mensajes
  /// [user] - Información del usuario para la tarjeta
  /// [policy] - Información de la póliza para la tarjeta
  /// [onSuccess] - Callback cuando la operación es exitosa
  /// [onCanceled] - Callback cuando la operación es cancelada
  /// [onError] - Callback cuando ocurre un error
  Future<bool> addInsuranceCardToAppleWallet({
    required BuildContext context,
    required User user,
    required PolicyModel policy,
    VoidCallback? onSuccess,
    VoidCallback? onCanceled,
    Function(Object)? onError,
  }) async {
    try {
      debugPrint('=== INICIANDO PROCESO DE APPLE WALLET ===');
      debugPrint('Usuario: ${user.fullName}');
      debugPrint('Póliza: ${policy.policyNumber}');

      // Verificar disponibilidad
      final bool available = await isAppleWalletAvailable();
      if (!available) {
        if (onError != null && context.mounted) {
          onError(
              Exception(context.translate('idCard.appleWalletNotAvailable')));
        }
        return false;
      }

      // Crear la carga útil para el servicio de Apple Wallet
      final payload = WalletPayload.fromUserAndPolicy(user, policy);

      // Convertir a JSON para la petición
      final String payloadJson = jsonEncode(payload.toJson());
      debugPrint('Payload: $payloadJson');

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
        final walletResponse = AppleWalletResponse.fromJson(responseData);

        debugPrint('Respuesta recibida: ${response.body}');

        // Obtener el contenido base64 del archivo .pkpass
        final String base64Content = walletResponse.applePassData.fileContents;

        // Decodificar el contenido base64 a bytes
        final List<int> bytes = base64Decode(base64Content);

        // Guardar los bytes en un archivo temporal
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/freeway_insurance.pkpass');
        await file.writeAsBytes(bytes);

        // Generar el objeto PasskitFile desde el archivo
        final passkitFile = await FlutterWalletCard.generateFromFile(
          id: 'freeway-insurance-card',
          file: file,
        );

        // Añadir el pase al Apple Wallet
        final completed = await FlutterWalletCard.addPasskit(passkitFile);

        if (completed) {
          if (onSuccess != null) onSuccess();
          return true;
        } else {
          if (context.mounted) {
            throw Exception(
                context.translate('idCard.canceledAddingToAppleWallet'));
          }
          return false;
        }
      } else {
        // Error en la petición
        debugPrint('Error en la petición: ${response.statusCode}');
        debugPrint('Respuesta: ${response.body}');

        if (context.mounted) {
          throw Exception(
              '${context.translate('common.error')}: ${response.statusCode} ${response.reasonPhrase}');
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error añadiendo tarjeta a Apple Wallet: $e');
      if (onError != null) {
        onError(e);
      }
      return false;
    }
  }

  /// Método para implementar cuando tengas un archivo .pkpass disponible
  Future<bool> addPasskitFromFile(File pkpassFile) async {
    try {
      // Generar el objeto PasskitFile desde el archivo
      final passkitFile = await FlutterWalletCard.generateFromFile(
        id: 'freeway-insurance-card',
        file: pkpassFile,
      );

      // Añadir el pase al Apple Wallet
      final completed = await FlutterWalletCard.addPasskit(passkitFile);

      return completed;
    } catch (e) {
      debugPrint('Error al añadir archivo .pkpass a Apple Wallet: $e');
      return false;
    }
  }
}
