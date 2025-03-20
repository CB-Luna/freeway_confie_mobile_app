import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/office/office.dart';
import '../models/office/office_request.dart';

class OfficeService {
  static const String baseUrl = 'https://u-n8n.virtalus.cbluna-dev.com';
  static const String officesEndpoint = '/webhook/confie_office_locations';

  /// Busca oficinas cercanas a un código postal específico
  /// 
  /// [zipCode] El código postal para buscar oficinas cercanas
  /// [count] Número máximo de oficinas a devolver (por defecto 5)
  Future<List<Office>> getNearbyOfficesByZipCode(String zipCode, {int count = 5}) async {
    try {
      final request = OfficeRequest(zipCode: zipCode, count: count);

      debugPrint('Buscando oficinas cercanas al código postal: $zipCode');

      final response = await http.post(
        Uri.parse('$baseUrl$officesEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        debugPrint('Respuesta recibida: ${response.body}');

        final List<dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.isEmpty) {
          debugPrint('API devolvió lista vacía para el código postal: $zipCode');
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
  /// [count] Número máximo de oficinas a devolver (por defecto 5)
  Future<List<Office>> getNearbyOfficesByLocation(
    double latitude, 
    double longitude, 
    {int count = 5}
  ) async {
    // TODO: Implementar búsqueda por coordenadas
    // Por ahora, usaremos un código postal ficticio para demostración
    return getNearbyOfficesByZipCode('91911', count: count);
  }
}
