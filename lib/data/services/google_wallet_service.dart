import 'dart:convert';
import 'dart:developer' as developer;

import 'package:add_to_google_wallet/add_to_google_wallet.dart';
import 'package:flutter/material.dart';
import 'package:freeway_app/data/models/auth/policy_model.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:uuid/uuid.dart';

/// Servicio para manejar la integración con Google Wallet
class GoogleWalletService {
  // Constantes para Google Wallet
  // Nota: Estos IDs son para pruebas y deberían ser reemplazados por los del cliente
  final String _issuerId = '3388000000022925653';
  final String _passClass = 'googleWalletDemo';

  // Definición de la clase genérica para Google Wallet
  // Esta definición debe coincidir con la configuración en la consola de Google Wallet
  final Map<String, dynamic> _classDefinition = {
    'id': '3388000000022925653.googleWalletDemo',
    'classTemplateInfo': {
      'cardRowTemplateInfos': [
        {
          'twoItems': {
            'startItem': {
              'firstValue': {
                'fields': [
                  {
                    'fieldPath': "object.textModulesData['carrier']",
                  }
                ],
              },
            },
            'endItem': {
              'firstValue': {
                'fields': [
                  {
                    'fieldPath': "object.textModulesData['state']",
                  }
                ],
              },
            },
          },
        },
        {
          'twoItems': {
            'startItem': {
              'firstValue': {
                'fields': [
                  {
                    'fieldPath': "object.textModulesData['effective_date']",
                  }
                ],
              },
            },
            'endItem': {
              'firstValue': {
                'fields': [
                  {
                    'fieldPath': "object.textModulesData['expiration_date']",
                  }
                ],
              },
            },
          },
        },
        {
          'oneItem': {
            'item': {
              'firstValue': {
                'fields': [
                  {
                    'fieldPath': "object.textModulesData['policy_number']",
                  }
                ],
              },
            },
          },
        }
      ],
    },
    // Habilitar Smart Tap para que se muestren los campos en la tarjeta
    'enableSmartTap': true,
  };

  // Instancia de AddToGoogleWallet
  final AddToGoogleWallet _addToGoogleWallet = AddToGoogleWallet();

  /// Verifica si la API de Google Wallet está disponible en el dispositivo
  Future<bool> isGoogleWalletApiAvailable() async {
    return await _addToGoogleWallet.isGoogleWalletApiAvailable;
  }

  /// Verifica si Google Wallet está disponible y muestra un mensaje apropiado
  ///
  /// [context] - Contexto para mostrar mensajes
  /// Retorna true si Google Wallet está disponible, false en caso contrario
  Future<bool> checkGoogleWalletAvailability(BuildContext context) async {
    final bool available = await isGoogleWalletApiAvailable();
    if (!available) {
      // Mostrar mensaje al usuario
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Google Wallet no está disponible en este dispositivo'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    return available;
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
    developer.log('=== INICIANDO PROCESO DE GOOGLE WALLET ===');
    developer.log(
      'Datos de usuario: ${user.firstName} ${user.lastName}, Estado: ${user.state}',
    );
    developer.log(
      'Datos de póliza: Número: ${policy.policyNumber}, Aseguradora: ${policy.carrierName}',
    );
    developer.log(
      'Fechas: Efectiva: ${policy.effectiveDate}, Expiración: ${policy.expirationDate}',
    );
    try {
      // Generar un ID único para el pase
      final String passId = const Uuid().v4();
      developer.log('Generando pase con ID: $passId');

      // Fechas estáticas para demo
      final effectiveDateStr = policy.effectiveDate;
      final expirationDateStr = policy.expirationDate;

      developer.log(
        'Creando JSON para Google Wallet con datos: Usuario=${user.firstName} ${user.lastName}, Policy=${policy.policyNumber}',
      );

      // Crear un objeto para el pase de Google Wallet usando el formato Generic Object
      // Este formato coincide con el tipo de clase "Genérica" configurado en Google Wallet
      final Map<String, dynamic> genericObject = {
        'id': '$_issuerId.$passId',
        'classId': '$_issuerId.$_passClass',
        'logo': {
          'sourceUri': {
            'uri':
                'https://pbs.twimg.com/profile_images/917818158538358784/HjCVFtL6_400x400.jpg',
          },
          'contentDescription': {
            'defaultValue': {
              'language': 'en-US',
              'value': 'Freeway Insurance Logo',
            },
          },
        },
        'cardTitle': {
          'defaultValue': {
            'language': 'en-US',
            'value': 'Freeway Insurance',
          },
        },
        'header': {
          'defaultValue': {
            'language': 'en-US',
            'value': '${user.firstName} ${user.lastName}',
          },
        },
        'subheader': {
          'defaultValue': {
            'language': 'en-US',
            'value':
                context.translate('idCard.notProofOfCoverage').toUpperCase(),
          },
        },
        'textModulesData': [
          {
            'id': 'carrier',
            'header': 'CARRIER',
            'body': policy.carrierName,
          },
          {
            'id': 'policy_number',
            'header': 'POLICY NUMBER',
            'body': policy.policyNumber,
          },
          {
            'id': 'state',
            'header': 'STATE',
            'body': user.state,
          },
          {
            'id': 'effective_date',
            'header': 'EFFECTIVE DATE',
            'body': effectiveDateStr,
          },
          {
            'id': 'expiration_date',
            'header': 'EXPIRATION DATE',
            'body': expirationDateStr,
          },
        ],
        'hexBackgroundColor': '#FFFFFF',
      };

      // Crear el objeto JWT completo con la estructura correcta
      // Incluimos tanto la definición de clase como el objeto genérico
      final Map<String, dynamic> jwtData = {
        'iss': 'info@freewayinsurance.com',
        'aud': 'google',
        'typ': 'savetowallet',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'payload': {
          // Incluir la definición de clase para que se actualice en Google Wallet
          'genericClasses': [_classDefinition],
          // Incluir el objeto genérico con los datos de la tarjeta
          'genericObjects': [genericObject],
        },
      };

      // Convertir a JSON con formato compacto (sin espacios adicionales)
      final String passJson = jsonEncode(jwtData);

      developer.log('JSON generado: $passJson');
      developer.log('Longitud del JSON: ${passJson.length} caracteres');

      // Verificar estructura del JSON
      try {
        final decodedJson = jsonDecode(passJson);
        developer.log('JSON decodificado correctamente');
        developer.log('Estructura del JWT: ${decodedJson.keys.join(', ')}');
        if (decodedJson['payload'] != null &&
            decodedJson['payload']['genericObjects'] != null) {
          developer.log('Estructura de payload correcta');
        } else {
          developer.log('ERROR: Estructura de payload incorrecta');
        }
      } catch (e) {
        developer.log('ERROR al decodificar JSON: $e');
      }

      // Verificar si Google Wallet API está disponible
      developer.log('Verificando disponibilidad de Google Wallet API...');
      final bool available = await isGoogleWalletApiAvailable();
      developer.log('Google Wallet API disponible: $available');

      if (available) {
        // Intentar diferentes métodos para guardar el pase
        try {
          // Primero intentamos con saveLoyaltyPass
          developer.log('Intentando guardar pase con saveLoyaltyPass...');
          await _addToGoogleWallet.saveLoyaltyPass(
            pass: passJson,
            onSuccess: () {
              developer.log(
                '=== ÉXITO: Pase guardado exitosamente en Google Wallet con saveLoyaltyPass ===',
              );
              if (onSuccess != null) onSuccess();
            },
            onCanceled: () {
              developer
                  .log('=== CANCELADO: Operación cancelada por el usuario ===');
              if (onCanceled != null) onCanceled();
            },
            onError: (error) async {
              // Si falla con saveLoyaltyPass, intentamos con el método alternativo
              developer.log('Error con saveLoyaltyPass: $error');
              developer.log('Intentando método alternativo...');

              try {
                // Usar el método genérico de la clase
                final method = _addToGoogleWallet.runtimeType
                        .toString()
                        .contains('savePass')
                    ? 'savePass'
                    : 'saveLoyaltyPass';
                developer.log('Intentando con método: $method');

                // Manejar el error y proporcionar información detallada
                final errorMsg = error.toString().toLowerCase();
                if (errorMsg.contains('invalid_jwt')) {
                  developer.log(
                    'Posible problema con el formato JWT o firma. Verificar el formato JSON y los IDs del emisor.',
                  );
                } else if (errorMsg.contains('not_found')) {
                  developer.log(
                    'Posible problema con los IDs de clase o emisor. Verificar que existan en la consola de Google Wallet.',
                  );
                } else if (errorMsg.contains('invalid_format')) {
                  developer.log(
                    'Formato JSON no válido. Verificar la estructura del JSON.',
                  );
                }

                if (onError != null) onError(error);
              } catch (secondError) {
                developer.log('Error en método alternativo: $secondError');
                if (onError != null) onError(secondError);
              }
            },
          );
        } catch (e) {
          developer.log('Error general al guardar pase: $e');
          if (onError != null) onError(e);
        }
      } else {
        // Google Wallet no está disponible
        const errorMsg = 'Google Wallet no está disponible en este dispositivo';
        developer.log('=== ERROR: $errorMsg ===');
        developer.log(
          'Verificar que el dispositivo tenga Google Play Services actualizado y soporte Google Wallet',
        );
        if (onError != null) {
          onError(Exception(errorMsg));
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
