import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource dataSource;

  LocationRepositoryImpl(this.dataSource);

  @override
  Future<Position> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      debugPrint('LocationRepositoryImpl: Error getting current location: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSortedOffices() async {
    try {
      final position = await getCurrentLocation();

      // Lista de oficinas (hardcoded por ahora, luego se puede mover a un datasource)
      final List<Map<String, dynamic>> offices = [
        {
          'id': '1',
          'name': 'Seguro de auto en Chula Vista',
          'latitude': 32.6024602,
          'longitude': -117.0804273,
          'address': '624 Palomar St Ste 701, CA 91911',
          'phone': '619-399-2387',
        },
        {
          'id': '2',
          'name': 'Seguro de auto en National City',
          'latitude': 32.6773538,
          'longitude': -117.0962897,
          'address': '1401 E Plaza Blvd #E, National City, CA 91950',
          'phone': '619-618-2400',
        },
      ];

      // Calcular distancia para cada oficina
      final List<Map<String, dynamic>> officesWithDistances = [];
      for (var office in offices) {
        final double distance = await calculateDistance(
          Location(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
          Location(
            latitude: office['latitude'],
            longitude: office['longitude'],
          ),
        );

        officesWithDistances.add({
          ...office,
          'distanceInMiles':
              distance * 0.000621371, // Convertir metros a millas
        });
      }

      // Ordenar por distancia
      officesWithDistances.sort(
        (a, b) => (a['distanceInMiles'] as double)
            .compareTo(b['distanceInMiles'] as double),
      );

      return officesWithDistances;
    } catch (e) {
      debugPrint('LocationRepositoryImpl: Error getting sorted offices: $e');
      return [];
    }
  }

  @override
  Future<double> calculateDistance(
    Location source,
    Location destination,
  ) async {
    return Geolocator.distanceBetween(
      source.latitude,
      source.longitude,
      destination.latitude,
      destination.longitude,
    );
  }
}
