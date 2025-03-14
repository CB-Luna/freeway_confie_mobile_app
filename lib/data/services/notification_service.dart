import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/notification_model.dart';

class NotificationService {
  static const String _baseUrl =
      'https://u-n8n.virtalus.cbluna-dev.com/webhook/confie_notifications';

  // Método para obtener las notificaciones desde la API
  Future<List<NotificationModel>> getNotifications(int customerId) async {
    debugPrint(
        'NotificationService - Iniciando solicitud para customerId: $customerId',);
    debugPrint('NotificationService - URL: $_baseUrl');

    try {
      final requestBody = jsonEncode({'customer_id': customerId});
      debugPrint('NotificationService - Request body: $requestBody');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      debugPrint('NotificationService - Status code: ${response.statusCode}');
      debugPrint('NotificationService - Response headers: ${response.headers}');

      // Imprimir la respuesta completa para depuración
      debugPrint(
          'NotificationService - Response body COMPLETO: ${response.body}',);

      // Imprimir los primeros 500 caracteres de la respuesta para depuración
      final responsePreview = response.body.length > 500
          ? '${response.body.substring(0, 500)}...'
          : response.body;
      debugPrint(
          'NotificationService - Response body preview: $responsePreview',);

      if (response.statusCode == 200) {
        debugPrint('NotificationService - Respuesta exitosa (200 OK)');

        // Corregir el formato de la respuesta si es necesario
        String responseBody = response.body;

        // Verificar si la respuesta comienza con un objeto JSON válido
        if (!responseBody.trim().startsWith('{') &&
            !responseBody.trim().startsWith('[')) {
          debugPrint(
              'NotificationService - Formato de respuesta incorrecto, intentando corregir',);
          // Buscar el primer '{' o '[' en la respuesta
          final containsBrace = responseBody.contains('{');
          final containsBracket = responseBody.contains('[');

          int startIndex = -1;
          if (containsBrace) {
            startIndex = responseBody.indexOf('{');
          } else if (containsBracket) {
            startIndex = responseBody.indexOf('[');
          }

          if (startIndex != -1) {
            responseBody = responseBody.substring(startIndex);
            debugPrint(
                'NotificationService - Respuesta corregida: ${responseBody.substring(0, math.min(100, responseBody.length))}...',);
          }
        }

        // Intentar decodificar la respuesta
        List<dynamic> notificationsJson = [];

        try {
          // Verificar si la respuesta es un array o un objeto
          if (responseBody.trim().startsWith('[')) {
            // Es un array directamente
            notificationsJson = jsonDecode(responseBody);
            debugPrint(
                'NotificationService - Respuesta decodificada como array: ${notificationsJson.length} elementos',);

            // Imprimir los primeros elementos para depuración
            if (notificationsJson.isNotEmpty) {
              debugPrint(
                  'NotificationService - Primer elemento: ${notificationsJson[0]}',);
              if (notificationsJson.length > 1) {
                debugPrint(
                    'NotificationService - Segundo elemento: ${notificationsJson[1]}',);
              }
            }
          } else {
            // Es un objeto, buscar la clave 'notifications'
            final Map<String, dynamic> data = jsonDecode(responseBody);
            debugPrint(
                'NotificationService - Claves en la respuesta: ${data.keys.toList()}',);

            if (data.containsKey('notifications') &&
                data['notifications'] is List) {
              notificationsJson = data['notifications'];
              debugPrint(
                  'NotificationService - Notificaciones encontradas en la clave "notifications"',);
            } else {
              // Si no hay una clave 'notifications', usar todo el objeto como una lista de un solo elemento
              debugPrint(
                  'NotificationService - No se encontró la clave "notifications", usando todo el objeto',);
              notificationsJson = [data];
            }
          }

          debugPrint(
              'NotificationService - Número de notificaciones encontradas: ${notificationsJson.length}',);

          final notifications = notificationsJson.map((json) {
            debugPrint('NotificationService - Procesando notificación: $json');
            return NotificationModel.fromJson(json);
          }).toList();

          debugPrint(
              'NotificationService - Notificaciones procesadas correctamente: ${notifications.length}',);
          return notifications;
        } catch (e) {
          debugPrint('NotificationService - Error al decodificar JSON: $e');
          throw Exception('Error al procesar la respuesta: $e');
        }
      } else {
        debugPrint('NotificationService - Error HTTP: ${response.statusCode}');
        debugPrint(
            'NotificationService - Cuerpo de respuesta de error: ${response.body}',);
        throw Exception(
            'Error al cargar notificaciones: ${response.statusCode}',);
      }
    } catch (e) {
      debugPrint('NotificationService - Error durante la solicitud: $e');
      debugPrint('NotificationService - Tipo de error: ${e.runtimeType}');
      throw Exception('Error de conexión: $e');
    }
  }
}
