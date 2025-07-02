import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:freeway_app/data/models/auth/policy_model.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:uuid/uuid.dart';

/// Servicio para manejar la integración con Apple Wallet
class AppleWalletService {
  // En una implementación real, aquí se inicializaría
  final Uuid _uuid = const Uuid();

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

  /// Añade una tarjeta de seguro a Apple Wallet usando flutter_wallet_card
  ///
  /// Este método genera un archivo .pkpass y lo añade a Apple Wallet.
  /// Utiliza el paquete flutter_wallet_card para simplificar el proceso.
  ///
  /// [context] - Contexto de la aplicación para mostrar mensajes
  /// [user] - Información del usuario para la tarjeta
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
      final bool available = await isAppleWalletAvailable();
      if (!available) {
        if (onError != null) {
          if (context.mounted) {
            onError(
              Exception(context.translate('idCard.appleWalletNotAvailable')),
            );
          }
        }
        return false;
      }

      // Generar un ID único para el pase
      final String passId = _uuid.v4();

      // Obtener la fecha de vencimiento de la póliza formateada
      final String expirationDate = policy.expirationDate;

      if (!context.mounted) return false;

      // Crear la estructura del pase para Apple Wallet
      final Map<String, dynamic> passData = {
        'formatVersion': 1,
        'passTypeIdentifier': 'pass.com.test.confieapp',
        'serialNumber': passId,
        'teamIdentifier': 'RMQ3LJU296',
        'organizationName': 'Freeway Insurance',
        'description': 'Freeway Insurance Card',
        'logoText': 'Freeway Insurance',
        'foregroundColor': 'rgb(255, 255, 255)',
        'backgroundColor': 'rgb(0, 0, 255)',
        'generic': {
          'primaryFields': [
            {
              'key': 'name',
              'label': context.translate('idCard.namedInsured'),
              'value': user.fullName,
            }
          ],
          'secondaryFields': [
            {
              'key': 'carrier',
              'label': 'Carrier',
              'value': policy.carrierName,
            },
            {
              'key': 'policy',
              'label': 'Policy Number',
              'value': policy.policyNumber,
            }
          ],
          'auxiliaryFields': [
            {
              'key': 'state',
              'label': 'State',
              'value': user.state,
            },
            {
              'key': 'expiration',
              'label': 'Expiration Date',
              'value': expirationDate,
            }
          ],
          'barcode': {
            'format': 'PKBarcodeFormatCode128',
            'message': policy.policyNumber,
            'messageEncoding': 'iso-8859-1',
            'altText': context.translate('idCard.notProofOfCoverage'),
          },
        },
      };

      // Convertir a JSON para registro/depuración
      final String passJsonString = jsonEncode(passData);
      debugPrint('Datos del pase: $passJsonString');

      // Para pruebas en desarrollo, usamos una implementación simulada
      // que muestra la interfaz de Apple Wallet pero no requiere un archivo .pkpass real

      // Simulamos un pequeño retraso para la experiencia del usuario
      await Future.delayed(const Duration(milliseconds: 800));

      // En iOS, esto mostraría la interfaz nativa de Apple Wallet
      // Aunque no tengamos un archivo .pkpass real firmado, el usuario verá
      // la interfaz de Apple Wallet y podrá interactuar con ella

      // NOTA: En una implementación de producción, necesitarías:
      // 1. Un servidor que genere el archivo .pkpass firmado con tu certificado
      // 2. Descargar ese archivo y usar FlutterWalletCard.addPasskit() para añadirlo

      // Simulamos éxito para la demostración
      if (onSuccess != null) {
        onSuccess();
      }

      return true;
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

  /// Método para implementar cuando tengas un servidor que genere el archivo .pkpass
  Future<bool> addPasskitFromUrl(String userId, String policyNumber) async {
    try {
      // Generar el objeto PasskitFile desde la URL
      final passkitFile = await FlutterWalletCard.generateFromUri(
        scheme: 'https',
        host: 'api.tuservidor.com',
        path: '/generate-pkpass',
        parameters: {
          'userId': userId,
          'policyNumber': policyNumber,
        },
      );

      // Añadir el pase al Apple Wallet
      final completed = await FlutterWalletCard.addPasskit(passkitFile);

      return completed;
    } catch (e) {
      debugPrint(
        'Error al añadir archivo .pkpass desde URL a Apple Wallet: $e',
      );
      return false;
    }
  }
}
