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

        final List<Office> offices =
            jsonResponse.map((office) => Office.fromJson(office)).toList();

        // Ordenar las oficinas por distancia (más cercana primero)
        offices
            .sort((a, b) => a.distanceObj.value.compareTo(b.distanceObj.value));

        return offices;
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

  /// Busca oficinas con llamados incrementales hasta encontrar al menos una
  /// Empieza con el radio inicial y va incrementando de 500 en 500 millas
  /// hasta encontrar oficinas o alcanzar el límite de 5500 millas (11 intentos)
  Future<List<Office>> getNearbyOfficesWithIncrementalRadius(
    String zipCode, {
    int initialRadius = 100,
  }) async {
    const int radiusIncrement = 500; // Incremento de 500 millas
    const int maxRadius = 6000; // Límite máximo de 6000 millas
    const int maxAttempts = 15; // Máximo 15 intentos

    int currentRadius = initialRadius;
    int attempts = 0;

    debugPrint(
      '🔍 Iniciando búsqueda incremental para ZIP code: $zipCode (radio inicial: $initialRadius millas)',
    );

    while (attempts < maxAttempts && currentRadius <= maxRadius) {
      attempts++;
      debugPrint(
        '📡 Intento $attempts/$maxAttempts - Buscando con radio: $currentRadius millas',
      );

      try {
        final offices = await getNearbyOfficesByZipCode(
          zipCode,
          radius: currentRadius,
        );

        if (offices.isNotEmpty) {
          debugPrint(
            '✅ ¡Oficinas encontradas! Total: ${offices.length} oficinas con radio de $currentRadius millas',
          );
          debugPrint(
            '📍 Oficina más cercana: ${offices.first.distanceObj.value} millas',
          );
          return offices;
        }

        debugPrint(
          '❌ No se encontraron oficinas con radio de $currentRadius millas',
        );

        // Incrementar el radio para el siguiente intento
        currentRadius += radiusIncrement;
      } catch (e) {
        debugPrint('⚠️ Error en intento $attempts: $e');
        // Continuar con el siguiente intento
        currentRadius += radiusIncrement;
      }
    }

    debugPrint(
      '❌ No se encontraron oficinas después de $attempts intentos (radio máximo: ${currentRadius - radiusIncrement} millas)',
    );
    return [];
  }

  /// Busca oficinas por ubicación con llamados incrementales
  Future<List<Office>> getNearbyOfficesByLocationWithIncrementalRadius(
    double latitude,
    double longitude, {
    int initialRadius = 100,
  }) async {
    const int radiusIncrement = 500; // Incremento de 500 millas
    const int maxRadius = 6000; // Límite máximo de 6000 millas
    const int maxAttempts = 15; // Máximo 15 intentos

    int currentRadius = initialRadius;
    int attempts = 0;

    debugPrint(
      '🔍 Iniciando búsqueda incremental para ubicación: $latitude, $longitude (radio inicial: $initialRadius millas)',
    );

    while (attempts < maxAttempts && currentRadius <= maxRadius) {
      attempts++;
      debugPrint(
        '📡 Intento $attempts/$maxAttempts - Buscando con radio: $currentRadius millas',
      );

      try {
        final offices = await getNearbyOfficesByLocation(
          latitude,
          longitude,
          radius: currentRadius,
        );

        if (offices.isNotEmpty) {
          debugPrint(
            '✅ ¡Oficinas encontradas! Total: ${offices.length} oficinas con radio de $currentRadius millas',
          );
          return offices;
        }

        debugPrint(
          '❌ No se encontraron oficinas con radio de $currentRadius millas',
        );

        // Incrementar el radio para el siguiente intento
        currentRadius += radiusIncrement;
      } catch (e) {
        debugPrint('⚠️ Error en intento $attempts: $e');
        // Continuar con el siguiente intento
        currentRadius += radiusIncrement;
      }
    }

    debugPrint(
      '❌ No se encontraron oficinas después de $attempts intentos (radio máximo: ${currentRadius - radiusIncrement} millas)',
    );
    return [];
  }
}
