import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freeway_app/data/constants.dart';
import 'package:http/http.dart' as http;

import '../models/office/office.dart';
import '../models/office/office_request.dart';

class OfficeService {
  static const String officesEndpoint = '/api/StoreLocator';

  /// Busca oficinas cercanas a un código postal específico
  ///
  /// [zipCode] El código postal para buscar oficinas cercanas
  /// [radius] Radio de búsqueda en millas (por defecto 100)
  Future<List<Office>> getNearbyOfficesByZipCode(
    String zipCode, {
    int radius = 100,
  }) async {
    try {
      final request = OfficeRequest(zipCode: zipCode, radius: radius);

      debugPrint('Buscando oficinas cercanas al código postal: $zipCode');

      final response = await http.post(
        Uri.parse('$envOffice$officesEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Apikey': apiKeyOffice,
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        debugPrint('Respuesta recibida: ${response.body}');

        final List<dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.isEmpty) {
          debugPrint(
            'API devolvió lista vacía para el código postal: $zipCode',
          );
          return [];
        }

        return jsonResponse.map((office) => Office.fromJson(office)).toList();
      } else {
        debugPrint('Error al buscar oficinas: ${response.statusCode}');
        debugPrint('Respuesta: ${response.body}');
        throw Exception('Error al buscar oficinas: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Excepción al buscar oficinas: $e');
      throw Exception('Error al buscar oficinas: $e');
    }
  }

  /// Busca oficinas cercanas a una ubicación geográfica específica
  ///
  /// [latitude] Latitud de la ubicación
  /// [longitude] Longitud de la ubicación
  /// [radius] Radio de búsqueda en millas (por defecto 100)
  Future<List<Office>> getNearbyOfficesByLocation(
    double latitude,
    double longitude, {
    int radius = 100,
  }) async {
    try {
      final request = OfficeRequest(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      debugPrint(
        'Buscando oficinas cercanas a la ubicación: $latitude, $longitude',
      );

      final response = await http.post(
        Uri.parse('$envOffice$officesEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Apikey': apiKeyOffice,
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        debugPrint('Respuesta recibida: ${response.body}');

        final List<dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.isEmpty) {
          debugPrint(
            'API devolvió lista vacía para la ubicación: $latitude, $longitude',
          );
          return [];
        }

        return jsonResponse.map((office) => Office.fromJson(office)).toList();
      } else {
        debugPrint('Error al buscar oficinas: ${response.statusCode}');
        debugPrint('Respuesta: ${response.body}');
        throw Exception('Error al buscar oficinas: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Excepción al buscar oficinas por ubicación: $e');
      throw Exception('Error al buscar oficinas por ubicación: $e');
    }
  }
}
