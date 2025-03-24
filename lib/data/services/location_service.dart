import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

/// Servicio para manejar operaciones relacionadas con la ubicación
class LocationService {
  /// Realiza un reverse geocoding para obtener el código postal a partir de coordenadas
  ///
  /// Utiliza el paquete geocoding que funciona con los servicios nativos de cada plataforma
  /// sin necesidad de una API key
  Future<String?> getZipCodeFromCoordinates(
      double latitude, double longitude) async {
    try {
      debugPrint('Obteniendo código postal para: $latitude, $longitude');
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final String? postalCode = placemarks.first.postalCode;
        debugPrint('Código postal obtenido: $postalCode');
        return postalCode;
      }

      return null;
    } catch (e) {
      debugPrint('Error al obtener código postal: $e');
      return null;
    }
  }

  /// Valida un código postal utilizando la API de Zippopotam.us
  ///
  /// Retorna un mapa con la información del lugar si el código postal es válido,
  /// o null si no es válido o hay un error.
  Future<Map<String, dynamic>?> validateZipCode(String zipCode) async {
    try {
      debugPrint('Validando código postal: $zipCode');
      final response = await http.get(
        Uri.parse('https://api.zippopotam.us/us/$zipCode'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Información del código postal: $data');

        if (data['places'] != null && data['places'].isNotEmpty) {
          return {
            'placeName': data['places'][0]['place name'],
            'stateAbbreviation': data['places'][0]['state abbreviation'],
            'state': data['places'][0]['state'],
            'latitude': data['places'][0]['latitude'],
            'longitude': data['places'][0]['longitude'],
          };
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error al validar código postal: $e');
      return null;
    }
  }
}
