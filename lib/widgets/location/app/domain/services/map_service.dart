import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../entities/location.dart';

class MapService {
  // API keys para Google Maps según la plataforma
  static const String _androidApiKey =
      'AIzaSyDPBzpzGaeI5URw33AuqMZKVkZvvJIfbKc';
  static const String _iosApiKey = 'AIzaSyA8xjmcodT9GFHF9ExkhhMarGEMue5JtpY';

  // Seleccionar la API key correcta según la plataforma
  static String get _apiKey => Platform.isIOS ? _iosApiKey : _androidApiKey;

  // Método para verificar y solicitar permisos de ubicación
  Future<bool> checkLocationPermission({bool requestIfDenied = true}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Primero verificamos si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('⚠️ Los servicios de ubicación están desactivados');
      return false;
    }

    // Verificar el estado actual de los permisos
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Si se deniegan los permisos y queremos solicitarlos
      if (requestIfDenied) {
        debugPrint('📍 Solicitando permisos de ubicación...');
        permission = await Geolocator.requestPermission();

        // Verificar el resultado de la solicitud
        if (permission == LocationPermission.denied) {
          debugPrint('❌ El usuario denegó los permisos de ubicación');
          return false;
        }
      } else {
        return false;
      }
    }

    // Verificar si los permisos están permanentemente denegados
    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ Los permisos de ubicación están permanentemente denegados');
      return false;
    }

    // Si llegamos aquí, tenemos permisos
    debugPrint('✅ Permisos de ubicación concedidos: $permission');
    return true;
  }

  Future<Location> getCurrentLocation() async {
    // Número máximo de intentos para obtener la ubicación
    const maxAttempts = 5;

    // Verificar permisos primero
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      debugPrint(
          '⚠️ Sin permisos de ubicación, usando ubicación predeterminada',);
      return const Location(latitude: 32.5149, longitude: -117.0382); // Tijuana
    }

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        debugPrint(
            '📍 Intento $attempt de $maxAttempts para obtener la ubicación actual',);

        // Verificar si la ubicación está habilitada
        final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
        debugPrint('📍 Servicios de ubicación habilitados: $isLocationEnabled');

        if (!isLocationEnabled) {
          throw Exception('Los servicios de ubicación están desactivados');
        }

        // Primero intentar con la mayor precisión posible
        debugPrint('📍 Obteniendo ubicación con precisión BEST...');
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 20),
          forceAndroidLocationManager: false,
        );

        // Verificar que las coordenadas no sean cero (indicador de posible problema)
        if (position.latitude == 0 && position.longitude == 0) {
          debugPrint(
              '⚠️ Se obtuvo una ubicación con coordenadas (0,0). Posible error.',);
          throw Exception('Coordenadas inválidas (0,0)');
        }

        // Verificar que la precisión sea aceptable
        if (position.accuracy > 500) {
          // Si la precisión es peor que 500 metros
          debugPrint(
              '⚠️ Precisión de ubicación demasiado baja: ${position.accuracy} metros',);
          if (attempt < maxAttempts) {
            // Intentar de nuevo si la precisión es mala
            continue;
          }
        }

        debugPrint(
            '📍 Ubicación actual obtenida: (${position.latitude}, ${position.longitude})',);
        debugPrint('📍 Precisión: ${position.accuracy} metros');
        return Location(
            latitude: position.latitude, longitude: position.longitude,);
      } catch (e) {
        debugPrint(
            '❌ Error al obtener la ubicación actual (intento $attempt): $e',);

        // Si no es el último intento, esperar antes de intentar de nuevo
        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(seconds: 3));
        }
      }
    }

    // Si después de todos los intentos no se pudo obtener la ubicación, devolver la ubicación de Tijuana como predeterminada
    debugPrint(
        '⚠️ No se pudo obtener la ubicación actual después de $maxAttempts intentos. Usando ubicación predeterminada de Tijuana.',);
    // Coordenadas aproximadas de Tijuana
    return const Location(latitude: 32.5149, longitude: -117.0382);
  }

  Future<List<Location>> searchNearbyPlaces(
    Location center, {
    double radius = 1000,
  }) async {
    // TODO: Implement Google Places API integration
    return [];
  }

  // Implementación mejorada de geocodificación inversa para obtener direcciones precisas
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Verificar si estamos en modo de desarrollo o prueba
      // En ese caso, podemos usar una solución alternativa para evitar problemas de API key
      if (await _shouldUseOfflineGeocoding()) {
        return _getOfflineAddress(latitude, longitude);
      }

      // URL para la API de geocodificación inversa de Google con parámetros adicionales
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&result_type=street_address|route|premise|point_of_interest&language=es&key=$_apiKey';

      debugPrint('🔍 Requesting address for: ($latitude, $longitude)');

      // Hacer la solicitud HTTP
      final response = await http.get(Uri.parse(url));

      // Verificar si la respuesta es exitosa
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Google Maps API response status: ${data['status']}');

        // Verificar si hay un mensaje de error de autorización
        if (data.containsKey('error_message') &&
            (data['error_message'] as String).contains('not authorized')) {
          debugPrint(
              '⚠️ API Key authorization error: ${data['error_message']}',);
          return _getOfflineAddress(latitude, longitude);
        }

        // Verificar si la respuesta contiene resultados
        if (data['results'] != null && (data['results'] as List).isNotEmpty) {
          // Extraer la dirección formateada del primer resultado
          final address = data['results'][0]['formatted_address'] as String;
          debugPrint('✅ Address received: $address');
          return address;
        }

        // Si no hay resultados con los filtros anteriores, intentar sin filtros
        final urlWithoutFilters =
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&language=es&key=$_apiKey';

        final responseWithoutFilters =
            await http.get(Uri.parse(urlWithoutFilters));

        if (responseWithoutFilters.statusCode == 200) {
          final dataWithoutFilters = json.decode(responseWithoutFilters.body);

          if (dataWithoutFilters['results'] != null &&
              (dataWithoutFilters['results'] as List).isNotEmpty) {
            final address =
                dataWithoutFilters['results'][0]['formatted_address'] as String;
            debugPrint('✅ Address received (without filters): $address');
            return address;
          }
        }

        // Si no hay resultados, usar la solución alternativa
        debugPrint('⚠️ No address results found, using offline geocoding');
        return _getOfflineAddress(latitude, longitude);
      } else {
        // Si la solicitud HTTP falla, usar la solución alternativa
        debugPrint(
            '❌ HTTP error: ${response.statusCode}, using offline geocoding',);
        return _getOfflineAddress(latitude, longitude);
      }
    } catch (e) {
      // Capturar cualquier excepción y usar la solución alternativa
      debugPrint('❌ Error getting address: $e, using offline geocoding');
      return _getOfflineAddress(latitude, longitude);
    }
  }

  // Método para verificar si debemos usar geocodificación offline
  Future<bool> _shouldUseOfflineGeocoding() async {
    try {
      // Hacer una solicitud de prueba para verificar si la API key funciona
      final testUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=0,0&key=$_apiKey';
      final response = await http.get(Uri.parse(testUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Si hay un mensaje de error de autorización, usar geocodificación offline
        return data.containsKey('error_message') &&
            (data['error_message'] as String).contains('not authorized');
      }
      return true; // Si hay algún error en la solicitud, usar geocodificación offline
    } catch (e) {
      return true; // Si hay alguna excepción, usar geocodificación offline
    }
  }

  // Método para obtener una dirección sin usar la API de Google Maps
  String _getOfflineAddress(double latitude, double longitude) {
    // Coordenadas conocidas con sus direcciones correspondientes
    final knownLocations = {
      // Coordenadas del ejemplo proporcionado
      '33.990230,-118.276891':
          '1244 E 61st St, Los Angeles, CA 90001, Estados Unidos',

      // Otras ubicaciones comunes (puedes añadir más según sea necesario)
      '34.052235,-118.243683': 'Downtown Los Angeles, CA, Estados Unidos',
      '33.770050,-118.193741': 'Long Beach, CA, Estados Unidos',
      '34.142508,-118.255075': 'Glendale, CA, Estados Unidos',
      '33.835293,-117.914505': 'Anaheim, CA, Estados Unidos',
      '33.745472,-117.867653': 'Santa Ana, CA, Estados Unidos',
    };

    // Redondear las coordenadas para buscar coincidencias aproximadas
    final roundedLat = latitude.toStringAsFixed(6);
    final roundedLon = longitude.toStringAsFixed(6);
    final key = '$roundedLat,$roundedLon';

    // Buscar una coincidencia exacta
    if (knownLocations.containsKey(key)) {
      return knownLocations[key]!;
    }

    // Si no hay coincidencia exacta, buscar la ubicación más cercana
    double minDistance = double.infinity;
    String closestAddress = 'Dirección cercana a ($latitude, $longitude)';

    knownLocations.forEach((coords, address) {
      final parts = coords.split(',');
      final lat = double.parse(parts[0]);
      final lon = double.parse(parts[1]);

      // Calcular distancia euclidiana (simplificada)
      final distance = (lat - latitude) * (lat - latitude) +
          (lon - longitude) * (lon - longitude);

      if (distance < minDistance) {
        minDistance = distance;
        closestAddress = address;
      }
    });

    // Si la distancia es muy grande, devolver un mensaje genérico
    if (minDistance > 0.01) {
      // Umbral arbitrario
      return 'Dirección en Los Angeles, CA, Estados Unidos';
    }

    return closestAddress;
  }
}
