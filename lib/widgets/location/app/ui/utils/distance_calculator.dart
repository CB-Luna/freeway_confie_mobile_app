import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class DistanceCalculator {
  /// Calculates the distance between two coordinates in miles using the Haversine formula
  static double calculateDistanceInMiles(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Earth's radius in miles
    const double earthRadius = 3958.8;

    // Convert degrees to radians
    final double lat1Rad = _degreesToRadians(lat1);
    final double lon1Rad = _degreesToRadians(lon1);
    final double lat2Rad = _degreesToRadians(lat2);
    final double lon2Rad = _degreesToRadians(lon2);

    // Haversine formula
    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;

    final double a =
        pow(sin(dLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
  
  /// Calcula la distancia entre dos coordenadas en millas
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return calculateDistanceInMiles(
      lat1,
      lon1,
      lat2,
      lon2,
    );
  }
  
  /// Calcula la distancia desde la ubicación actual del dispositivo a una coordenada específica
  static Future<double> calculateDistanceFromCurrentLocation(double targetLat, double targetLon) async {
    try {
      // Verificar si los servicios de ubicación están habilitados
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados');
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de ubicación denegado');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permiso de ubicación denegado permanentemente');
      }

      // Obtener la ubicación actual
      final Position position = await Geolocator.getCurrentPosition();

      // Calcular la distancia
      return calculateDistanceInMiles(
        position.latitude,
        position.longitude,
        targetLat,
        targetLon,
      );
    } catch (e) {
      developer.log('Error al calcular la distancia: $e', name: 'DistanceCalculator');
      return -1; // Valor de error
    }
  }

  /// Finds the nearest office from a list based on coordinates
  static Map<String, dynamic> findNearestOffice(
    double userLat,
    double userLon,
    List<Map<String, dynamic>> officesList,
  ) {
    if (officesList.isEmpty) {
      throw Exception('Office list is empty');
    }

    double minDistance = double.infinity;
    late Map<String, dynamic> nearestOffice;

    for (final office in officesList) {
      final double officeLat = office['latitude'] as double;
      final double officeLon = office['longitude'] as double;

      final double distance = calculateDistanceInMiles(
        userLat,
        userLon,
        officeLat,
        officeLon,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestOffice = {...office, 'distanceInMiles': distance};
      }
    }

    return nearestOffice;
  }
  
  /// Calcula las distancias de todas las oficinas desde la ubicación actual del dispositivo
  /// Retorna una lista de mapas con las oficinas y sus distancias calculadas
  static Future<List<Map<String, dynamic>>> calculateDistancesFromCurrentLocation(
    List<Map<String, dynamic>> offices,
  ) async {
    try {
      // Verificar si los servicios de ubicación están habilitados
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados');
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de ubicación denegado');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permiso de ubicación denegado permanentemente');
      }

      // Obtener la ubicación actual
      final Position position = await Geolocator.getCurrentPosition();
      
      final List<Map<String, dynamic>> officesWithDistances = [];
      
      // Calcular distancias para cada oficina
      for (final office in offices) {
        final double officeLat = office['latitude'] as double;
        final double officeLon = office['longitude'] as double;
        
        final double distance = calculateDistanceInMiles(
          position.latitude,
          position.longitude,
          officeLat,
          officeLon,
        );
        
        // Agregar la oficina con su distancia calculada
        officesWithDistances.add({
          ...office,
          'distanceInMiles': distance,
        });
      }
      
      // Ordenar por distancia (la más cercana primero)
      officesWithDistances.sort((a, b) => 
        (a['distanceInMiles'] as double).compareTo(b['distanceInMiles'] as double),
      );
      
      return officesWithDistances;
    } catch (e) {
      developer.log('Error al calcular distancias: $e', name: 'DistanceCalculator');
      // Devolver la lista original sin distancias calculadas
      return offices.map((office) => {
        ...office,
        'distanceInMiles': -1.0, // Valor de error
      },).toList();
    }
  }

  /// Helper method to convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
  
  /// Método de prueba para calcular y mostrar las distancias de las oficinas
  /// desde la ubicación actual del dispositivo
  static Future<void> testOfficeDistances(List<Map<String, dynamic>> offices) async {
    try {
      debugPrint('Calculando distancias para ${offices.length} oficinas...');
      
      final List<Map<String, dynamic>> officesWithDistances = 
          await calculateDistancesFromCurrentLocation(offices);
      
      debugPrint('\nResultados de cálculo de distancias:');
      debugPrint('-------------------------------------');
      
      for (final office in officesWithDistances) {
        final String id = office['id'] as String;
        final double distance = office['distanceInMiles'] as double;
        final String address = office['address'] as String;
        
        debugPrint('Oficina: $id');
        debugPrint('Dirección: $address');
        debugPrint('Distancia: ${distance.toStringAsFixed(2)} millas');
        debugPrint('-------------------------------------');
      }
      
      debugPrint('\nOficina más cercana: ${officesWithDistances.first['id']}');
      debugPrint('Distancia: ${(officesWithDistances.first['distanceInMiles'] as double).toStringAsFixed(2)} millas');
      
    } catch (e) {
      developer.log('Error al probar distancias: $e', name: 'DistanceCalculator');
    }
  }
}
